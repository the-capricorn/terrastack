# Mock the azapi provider so no Azure credentials are needed.
mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "11111111-1111-1111-1111-111111111111"
      client_id       = "22222222-2222-2222-2222-222222222222"
    }
  }
}

# ---------------------------------------------------------------------------
# Shared variable defaults used across all run blocks (can be overridden).
# ---------------------------------------------------------------------------
variables {
  name                = "aks-test-001"
  location            = "westeurope"
  resource_group_name = "rg-test"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ExtendedLocation/customLocations/cl-test"
  logical_network_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/logicalNetworks/lnet-test"
  ssh_public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0FAKEKEY1234567890 user@example"

  node_pools = [
    {
      name  = "nodepool1"
      count = 2
    }
  ]
}

# ---------------------------------------------------------------------------
# Run 1: Happy path — a valid configuration must plan without errors.
# ---------------------------------------------------------------------------
run "valid_config_plans_without_error" {
  command = plan
}

# ---------------------------------------------------------------------------
# Run 2: HA control plane with 3 nodes and a static IP.
# ---------------------------------------------------------------------------
run "ha_control_plane_with_static_ip" {
  command = plan

  variables {
    control_plane_count = 3
    control_plane_ip    = "10.0.0.100"
  }
}

# ---------------------------------------------------------------------------
# Run 3: Multiple node pools — first in body, rest as child resources.
# ---------------------------------------------------------------------------
run "multiple_node_pools" {
  command = plan

  variables {
    node_pools = [
      {
        name    = "nodepool1"
        count   = 2
        vm_size = "Standard_A4_v2"
      },
      {
        name    = "nodepool2"
        count   = 3
        vm_size = "Standard_D4s_v3"
      }
    ]
  }
}

# ---------------------------------------------------------------------------
# Run 4: Explicit kubernetes version and custom pod CIDR.
# ---------------------------------------------------------------------------
run "explicit_kubernetes_version" {
  command = plan

  variables {
    kubernetes_version = "1.28.5"
    pod_cidr           = "192.168.0.0/16"
  }
}

# ---------------------------------------------------------------------------
# Run 5: Tags and load balancer count.
# ---------------------------------------------------------------------------
run "with_tags_and_load_balancer" {
  command = plan

  variables {
    load_balancer_count = 2
    tags = {
      environment = "prod"
      team        = "platform"
    }
  }
}

# ---------------------------------------------------------------------------
# Run 6: control_plane_count validation rejects even numbers.
# ---------------------------------------------------------------------------
run "validation_rejects_even_control_plane_count" {
  command = plan

  variables {
    control_plane_count = 2
  }

  expect_failures = [var.control_plane_count]
}

# ---------------------------------------------------------------------------
# Run 7: node_pools validation rejects empty list.
# ---------------------------------------------------------------------------
run "validation_rejects_empty_node_pools" {
  command = plan

  variables {
    node_pools = []
  }

  expect_failures = [var.node_pools]
}

# ---------------------------------------------------------------------------
# Run 8: ssh_public_key validation rejects empty string.
# ---------------------------------------------------------------------------
run "validation_rejects_empty_ssh_public_key" {
  command = plan

  variables {
    ssh_public_key = ""
  }

  expect_failures = [var.ssh_public_key]
}

# ---------------------------------------------------------------------------
# Run 9: load_balancer_count validation rejects negative values.
# ---------------------------------------------------------------------------
run "validation_rejects_negative_lb_count" {
  command = plan

  variables {
    load_balancer_count = -1
  }

  expect_failures = [var.load_balancer_count]
}
