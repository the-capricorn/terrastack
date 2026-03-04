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
  name                = "nic-test-001"
  location            = "westeurope"
  resource_group_name = "rg-test"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ExtendedLocation/customLocations/cl-test"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/logicalNetworks/lnet-test/subnets/snet-test"

  tags = {}
}

# ---------------------------------------------------------------------------
# Run 1: Happy path — a valid configuration must plan without errors.
# ---------------------------------------------------------------------------
run "valid_config_plans_without_error" {
  command = plan
}

# ---------------------------------------------------------------------------
# Run 2: name must match the naming pattern.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_name" {
  command = plan

  variables {
    name = "-invalid"
  }

  expect_failures = [var.name]
}

# ---------------------------------------------------------------------------
# Run 3: Happy path with optional fields set.
# ---------------------------------------------------------------------------
run "valid_config_with_optional_fields" {
  command = plan

  variables {
    private_ip_address = "10.10.10.20"
    dns_servers        = ["10.10.10.1"]
  }
}
