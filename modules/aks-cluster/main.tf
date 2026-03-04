# ----------------------------------------------------------------------------
# RESOURCE: Arc Connected Cluster (Microsoft.Kubernetes/connectedClusters)
# ----------------------------------------------------------------------------
# Creates the Arc shell that acts as the parent for the provisioned cluster
# instance. kind = "ProvisionedCluster" marks it as an HCI-managed cluster.
resource "azapi_resource" "connected_cluster" {
  type      = local.connected_cluster_type
  name      = var.name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = {
    kind = "ProvisionedCluster"
    properties = {
      # Required by schema but intentionally empty for HCI-provisioned clusters.
      agentPublicKeyCertificate = ""
      aadProfile = {
        enableAzureRBAC     = false
        adminGroupObjectIDs = []
      }
      arcAgentProfile = {
        agentAutoUpgrade = "Enabled"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      body.properties.distribution,
      body.properties.provisioningState,
    ]
  }
}

# ----------------------------------------------------------------------------
# RESOURCE: AKS Arc Provisioned Cluster Instance
# ----------------------------------------------------------------------------
# Extension resource scoped to the connected cluster above.
# Carries all AKS configuration: node pools, networking, OS profile, etc.
resource "azapi_resource" "provisioned_cluster" {
  type      = local.provisioned_cluster_type
  name      = "default"
  parent_id = azapi_resource.connected_cluster.id

  # provisionedClusterInstances does not support top-level location or tags.

  body = {
    extendedLocation = {
      type = "CustomLocation"
      name = var.custom_location_id
    }

    properties = {
      # Null is omitted by AzAPI — cluster uses its registered default version.
      kubernetesVersion = var.kubernetes_version

      linuxProfile = {
        ssh = {
          publicKeys = [
            { keyData = var.ssh_public_key }
          ]
        }
      }

      controlPlane = {
        count  = var.control_plane_count
        vmSize = var.control_plane_vm_size
        # controlPlaneEndpoint is omitted when null — DHCP assigns the IP.
        controlPlaneEndpoint = var.control_plane_ip != null ? { hostIP = var.control_plane_ip } : null
      }

      agentPoolProfiles = [
        {
          name    = local.primary_node_pool.name
          count   = local.primary_node_pool.count
          vmSize  = local.primary_node_pool.vm_size
          osType  = local.primary_node_pool.os_type
          osSKU   = local.primary_node_pool.os_sku
          maxPods = local.primary_node_pool.max_pods
        }
      ]

      # Reference to the HCI logical network — no intermediate bridge resource needed
      # with API version 2024-01-01.
      cloudProviderProfile = {
        infraNetworkProfile = {
          vnetSubnetIds = [var.logical_network_id]
        }
      }

      networkProfile = {
        networkPolicy = "calico"
        podCidr       = var.pod_cidr
        loadBalancerProfile = {
          count = var.load_balancer_count
        }
      }

      storageProfile = {
        nfsCsiDriver = { enabled = var.nfs_csi_driver_enabled }
        smbCsiDriver = { enabled = var.smb_csi_driver_enabled }
      }
    }
  }
}

# ----------------------------------------------------------------------------
# RESOURCE: Additional Node Pools
# ----------------------------------------------------------------------------
# The first node pool is embedded in the provisioned cluster body above.
# Any additional node pools are created as separate child resources.
resource "azapi_resource" "agent_pool" {
  for_each = local.additional_node_pools

  type      = local.agent_pool_type
  name      = each.key
  parent_id = azapi_resource.provisioned_cluster.id

  body = {
    properties = {
      count  = each.value.count
      vmSize = each.value.vm_size
      osType = each.value.os_type
      osSKU  = each.value.os_sku
    }
  }
}
