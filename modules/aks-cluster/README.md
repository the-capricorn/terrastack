# Module: aks-cluster

Deploys an AKS Arc cluster on Azure Local (`Microsoft.HybridContainerService/provisionedClusterInstances`) attached to an Arc connected cluster (`Microsoft.Kubernetes/connectedClusters`) created by this module.

Uses the [AzAPI provider](https://registry.terraform.io/providers/azure/azapi/latest) against API version `2024-01-01`.

---

## Example usage

```hcl
resource "tls_private_key" "aks_node" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azapi_resource" "aks_ssh_secret" {
  type      = "Microsoft.KeyVault/vaults/secrets@2023-07-01"
  name      = "ssh-aks-prod-001"
  parent_id = var.key_vault_id
  body = {
    properties = { value = tls_private_key.aks_node.private_key_openssh }
  }
}

module "aks_cluster" {
  source = "./modules/aks-cluster"

  name                = "aks-prod-001"
  location            = "westeurope"
  resource_group_name = "rg-azlocal-prod"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-azlocal-prod/providers/Microsoft.ExtendedLocation/customLocations/cl-azlocal-prod"
  logical_network_id  = module.logical_network.logical_network_id

  ssh_public_key = tls_private_key.aks_node.public_key_openssh

  kubernetes_version    = "1.28.5"
  control_plane_count   = 1
  control_plane_vm_size = "Standard_A4_v2"

  node_pools = [
    {
      name    = "nodepool1"
      count   = 2
      vm_size = "Standard_A4_v2"
    }
  ]

  tags = { environment = "prod" }
}
```

---

## Notes

- The provisioned cluster instance is **always named `default`** — this is enforced by the HCI API. The logical cluster name comes from the parent Arc connected cluster.
- **SSH key**: The module takes an SSH public key as input (`ssh_public_key`). Generate the key pair externally (e.g., with `tls_private_key`) and store the private key in Key Vault so operators can retrieve it via `az keyvault secret show`.
- **Logical network**: Pass the `Microsoft.AzureStackHCI/logicalNetworks` resource ID directly via `logical_network_id`. No intermediate bridge resource is needed with API version `2024-01-01`.
- **Control plane IP**: If `control_plane_ip` is null (default), the HCI platform assigns an IP from the logical network via DHCP. Set a static IP for production clusters to keep the API server address stable.
- **Additional node pools**: The first entry in `node_pools` is embedded in the provisioned cluster body. Additional entries are created as separate `agentPools` child resources and can be added/removed independently.
- **Kubeconfig retrieval**: Kubeconfig is not an output of this module — it requires a POST to `listAdminKubeconfig` after the cluster is fully provisioned. Use: `az aksarc get-credentials --resource-group <rg> --name <cluster-name>`.

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
