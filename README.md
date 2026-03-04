# terraform-azurelocal-modules

Reusable Terraform modules for **Azure Local (Azure Stack HCI)** using the [AzAPI provider](https://registry.terraform.io/providers/azure/azapi/latest).

The root module wires all child modules together and is the primary entry point for deployments. Each child module can also be consumed standalone.

---

## Modules

| Module | Resource Type | API Version |
|--------|--------------|-------------|
| [`logical-network`](modules/logical-network/) | `Microsoft.AzureStackHCI/logicalNetworks` | `2024-01-01` |
| [`network-interface`](modules/network-interface/) | `Microsoft.AzureStackHCI/networkInterfaces` | `2024-01-01` |
| [`windows-vm`](modules/windows-vm/) | `Microsoft.AzureStackHCI/virtualMachineInstances` | `2024-01-01` |
| [`linux-vm`](modules/linux-vm/) | `Microsoft.AzureStackHCI/virtualMachineInstances` | `2024-01-01` |
| [`virtual-data-disk`](modules/virtual-data-disk/) | `Microsoft.AzureStackHCI/virtualHardDisks` | `2024-01-01` |
| [`aks-cluster`](modules/aks-cluster/) | `Microsoft.Kubernetes/connectedClusters` + `Microsoft.HybridContainerService/provisionedClusterInstances` | `2024-01-01` |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.7.0` |
| `azure/azapi` | `>= 2.0.0, < 3.0.0` |
| `hashicorp/tls` | `>= 4.0` |

---

## Authentication

Credentials are provided via environment variables — no secrets are committed to the repository.

```bash
export ARM_CLIENT_ID="<service-principal-client-id>"
export ARM_CLIENT_SECRET="<service-principal-secret>"
export ARM_TENANT_ID="<tenant-id>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
```

Two additional values are injected at runtime:

```bash
export TF_VAR_resource_group_name="<resource-group>"
export TF_VAR_custom_location_id="<custom-location-resource-id>"
```

Use [`tools/create-deploy-identity.ps1`](tools/create-deploy-identity.ps1) (or the bash equivalent) to create a service principal with the required permissions.

---

## Usage

### 1. Configure non-sensitive values

Edit [`terraform.tfvars`](terraform.tfvars) with your location, network, VM, and AKS definitions. The file is committed — do **not** put secrets here.

### 2. Set sensitive values

Create a `secrets.auto.tfvars` (gitignored) for passwords:

```hcl
# secrets.auto.tfvars — never commit this file

virtual_machines = [
  {
    name           = "windowsvm01.corp.local"
    image_id       = "/subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image>"
    computer_name  = "windowsvm01"
    admin_password = "..."
  },
]

linux_vms = [
  {
    name           = "linuxvm01.corp.local"
    image_id       = "/subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image>"
    computer_name  = "linuxvm01"
    admin_password = "..."
    # ssh_public_key is generated automatically — private key stored in Key Vault
  },
]
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

---

## Root Variables

### Shared

| Name | Description | Required |
|------|-------------|:--------:|
| `location` | Azure region (e.g. `westeurope`) | yes |
| `resource_group_name` | Resource group for all resources | yes |
| `custom_location_id` | Custom Location resource ID of the Azure Local cluster | yes |
| `vm_switch_name` | VM switch name on the cluster | yes |
| `key_vault_id` | Key Vault resource ID — SSH private keys for Linux VMs and AKS nodes are stored here | yes |
| `tags` | Tags applied to all resources | no |

### Logical Networks (`var.networks`)

Each entry creates a `logical-network` module instance. Subnets are embedded in the logical network body.

```hcl
networks = [
  {
    name                 = "lnet-prod-weu-001"
    address_space        = ["10.10.0.0/24"]
    subnet_name          = "snet-workload"
    vlan                 = 100
    ip_allocation_method = "Static"
    ip_pool_start        = "10.10.0.10"
    ip_pool_end          = "10.10.0.250"
    default_gateway      = "10.10.0.254"
    dns_servers          = ["10.10.0.4"]
  },
]
```

### Network Interfaces (`var.network_interfaces`)

Each entry creates a `network-interface` module instance. `logical_network_name` must match a name in `var.networks`.

```hcl
network_interfaces = [
  {
    name                 = "nic-prod-001"
    logical_network_name = "lnet-prod-weu-001"
    private_ip_address   = "10.10.0.20"
  },
]
```

### Windows VMs (`var.virtual_machines`)

Each entry creates a `windows-vm` module instance. The module creates both the Arc machine (`Microsoft.HybridCompute/machines`) and the VM instance. Set `admin_password` in `secrets.auto.tfvars`.

```hcl
virtual_machines = [
  {
    name                    = "windowsvm01.corp.local"
    image_id                = "/subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image>"
    network_interface_names = ["nic-prod-001"]
    computer_name           = "windowsvm01"   # max 15 chars, no dots
    vm_size                 = "Standard_A4_v2"
    admin_password          = "..."           # use secrets.auto.tfvars
  },
]
```

### Linux VMs (`var.linux_vms`)

Each entry creates a `linux-vm` module instance. An SSH key pair is generated automatically per VM — the private key is stored as a Key Vault secret (`ssh-<vm-name>`). Set `admin_password` in `secrets.auto.tfvars`.

```hcl
linux_vms = [
  {
    name                    = "linuxvm01.corp.local"
    image_id                = "/subscriptions/<sub>/resourceGroups/<rg>/providers/microsoft.azurestackhci/marketplacegalleryimages/<image>"
    network_interface_names = ["nic-prod-001"]
    computer_name           = "linuxvm01"
    vm_size                 = "Standard_A4_v2"
    admin_password          = "..."   # use secrets.auto.tfvars
  },
]
```

Retrieve the SSH private key:

```bash
az keyvault secret show \
  --vault-name <kv-name> \
  --name ssh-<vm-name> \
  --query value -o tsv > ~/.ssh/<vm-name>.pem
chmod 600 ~/.ssh/<vm-name>.pem
ssh azureuser@<vm-ip> -i ~/.ssh/<vm-name>.pem
```

### AKS Arc Clusters (`var.aks_clusters`)

Each entry creates an AKS Arc cluster (`connectedClusters` + `provisionedClusterInstances`). An SSH key pair is generated automatically per cluster — the private key is stored as a Key Vault secret (`ssh-aks-<cluster-name>`).

```hcl
aks_clusters = [
  {
    name                 = "aks-prod-001"
    logical_network_name = "lnet-prod-weu-001"   # or use logical_network_id for externally-managed networks

    control_plane_ip      = "10.10.0.20"          # static IP for the API server, from the pool
    control_plane_count   = 1
    control_plane_vm_size = "Standard_A4_v2"

    # kubernetes_version omitted — API uses cluster default
    # az aksarc get-versions --custom-location <custom-location-id> --output table

    node_pools = [
      {
        name    = "nodepool1"
        count   = 2
        vm_size = "Standard_A4_v2"
        os_sku  = "CBLMariner"
      },
    ]
  },
]
```

Retrieve the node SSH private key:

```bash
az keyvault secret show \
  --vault-name <kv-name> \
  --name ssh-aks-<cluster-name> \
  --query value -o tsv
```

### Virtual Data Disks (`var.data_disks`)

Each entry creates a `virtual-data-disk` module instance (`Microsoft.AzureStackHCI/virtualHardDisks`).

```hcl
data_disks = [
  {
    name         = "vhd-prod-data-001"
    disk_size_gb = 256
  },
]
```

---

## Sensitive Values

| Value | How to provide |
|-------|---------------|
| `admin_password` | `secrets.auto.tfvars` (gitignored) or `TF_VAR_*` |
| `resource_group_name` | `TF_VAR_resource_group_name` env var |
| `custom_location_id` | `TF_VAR_custom_location_id` env var |
| `ARM_*` credentials | Environment variables or GitHub Secrets |

SSH private keys (Linux VMs and AKS nodes) are generated by Terraform and stored automatically in the Key Vault specified by `key_vault_id`. They are never printed or output.

---

## CI/CD

| Workflow | Trigger | What it does |
|----------|---------|-------------|
| `terraform-ci.yml` | Push / PR to `main` | `terraform validate` + `terraform test` with mock providers (no Azure credentials needed) |
| `publish-public.yml` | `workflow_dispatch` or `v*` tags | Sanitizes private repo and force-pushes to the public mirror |

---

## Documentation

Module READMEs are generated by [terraform-docs](https://terraform-docs.io/). To regenerate after changing variables or outputs:

```powershell
.\tools\generate-docs.ps1
```
