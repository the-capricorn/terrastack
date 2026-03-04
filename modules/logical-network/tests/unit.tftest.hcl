# Mock the azapi provider so no Azure credentials are needed.
# The mock_data block provides a fake subscription_id for
# data.azapi_client_config.current used in main.tf.
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
  name                = "lnet-test-001"
  location            = "westeurope"
  resource_group_name = "rg-test"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ExtendedLocation/customLocations/cl-test"
  vm_switch_name      = "ConvergedSwitch"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []
  subnet_name         = "snet-test"

  tags = {}
}

# ---------------------------------------------------------------------------
# Run 1: Happy path — a valid configuration must plan without errors.
# ---------------------------------------------------------------------------
run "valid_config_plans_without_error" {
  command = plan
}

# ---------------------------------------------------------------------------
# Run 2: subnet_name must match the naming pattern.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_subnet_name" {
  command = plan

  variables {
    subnet_name = "-invalid"
  }

  expect_failures = [var.subnet_name]
}

# ---------------------------------------------------------------------------
# Run 3: ip_allocation_method must be "Dynamic" or "Static".
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_ip_allocation_method" {
  command = plan

  variables {
    ip_allocation_method = "DHCP"
  }

  expect_failures = [var.ip_allocation_method]
}

# ---------------------------------------------------------------------------
# Run 4: address_space must not be empty.
# ---------------------------------------------------------------------------
run "validation_rejects_empty_address_space" {
  command = plan

  variables {
    address_space = []
  }

  expect_failures = [var.address_space]
}

# ---------------------------------------------------------------------------
# Run 5: ip_pool_start and ip_pool_end must be set together.
# ---------------------------------------------------------------------------
run "validation_rejects_incomplete_ip_pool" {
  command = plan

  variables {
    ip_pool_start = "10.0.0.10"
    # ip_pool_end intentionally omitted
  }

  expect_failures = [var.ip_pool_end]
}
