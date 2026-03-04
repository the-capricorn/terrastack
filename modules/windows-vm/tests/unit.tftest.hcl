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
  name                = "vm-test-001"
  location            = "westeurope"
  resource_group_name = "rg-test"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ExtendedLocation/customLocations/cl-test"
  image_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/marketplaceGalleryImages/ws-2025-dc"
  network_interface_ids = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/networkInterfaces/nic-test-001"
  ]
  admin_password = "P@ssw0rd1234!"
}

# ---------------------------------------------------------------------------
# Run 1: Happy path — a valid configuration must plan without errors.
# ---------------------------------------------------------------------------
run "valid_config_plans_without_error" {
  command = plan
}

# ---------------------------------------------------------------------------
# Run 2: Custom VM size with explicit cpu and memory counts.
# ---------------------------------------------------------------------------
run "custom_vm_size_with_explicit_resources" {
  command = plan

  variables {
    vm_size   = "Custom"
    cpu_count = 8
    memory_mb = 16384
  }
}

# ---------------------------------------------------------------------------
# Run 3: Predefined VM size (no cpu/memory override needed).
# ---------------------------------------------------------------------------
run "predefined_vm_size" {
  command = plan

  variables {
    vm_size = "Standard_A4_v2"
  }
}

# ---------------------------------------------------------------------------
# Run 4: Optional fields — computer_name, TPM, Secure Boot, auto-updates.
# ---------------------------------------------------------------------------
run "valid_config_with_optional_fields" {
  command = plan

  variables {
    computer_name            = "vm-test-001"
    enable_tpm               = true
    secure_boot_enabled      = true
    enable_automatic_updates = true
  }
}

# ---------------------------------------------------------------------------
# Run 5: computer_name validation rejects names with dots.
# ---------------------------------------------------------------------------
run "validation_rejects_computer_name_with_dot" {
  command = plan

  variables {
    computer_name = "vm.test.001"
  }

  expect_failures = [var.computer_name]
}

# ---------------------------------------------------------------------------
# Run 6: computer_name validation rejects names over 15 characters.
# ---------------------------------------------------------------------------
run "validation_rejects_computer_name_too_long" {
  command = plan

  variables {
    computer_name = "this-is-a-very-long-computer-name"
  }

  expect_failures = [var.computer_name]
}

# ---------------------------------------------------------------------------
# Run 7: vm_size validation rejects unknown sizes.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_vm_size" {
  command = plan

  variables {
    vm_size = "Standard_X999_v9"
  }

  expect_failures = [var.vm_size]
}

# ---------------------------------------------------------------------------
# Run 8: network_interface_ids validation rejects empty list.
# ---------------------------------------------------------------------------
run "validation_rejects_empty_nic_list" {
  command = plan

  variables {
    network_interface_ids = []
  }

  expect_failures = [var.network_interface_ids]
}

# ---------------------------------------------------------------------------
# Run 9: secure_boot_enabled requires enable_tpm.
# ---------------------------------------------------------------------------
run "validation_rejects_secure_boot_without_tpm" {
  command = plan

  variables {
    enable_tpm          = false
    secure_boot_enabled = true
  }

  expect_failures = [var.secure_boot_enabled]
}
