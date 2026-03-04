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
# Shared variable defaults used across all run blocks.
# ---------------------------------------------------------------------------
variables {
  name                = "vhd-test-001"
  location            = "westeurope"
  resource_group_name = "rg-test"
  custom_location_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ExtendedLocation/customLocations/cl-test"
  disk_size_gb        = 128
}

# ---------------------------------------------------------------------------
# Run 1: Happy path — default values plan without errors.
# ---------------------------------------------------------------------------
run "valid_config_plans_without_error" {
  command = plan
}

# ---------------------------------------------------------------------------
# Run 2: Fixed disk with Gen1, explicit sector sizes, storage path.
# ---------------------------------------------------------------------------
run "fixed_disk_gen1_with_storage_path" {
  command = plan

  variables {
    disk_file_format      = "vhdx"
    dynamic               = false
    hyper_v_generation    = "V1"
    logical_sector_bytes  = 512
    physical_sector_bytes = 4096
    storage_path_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.AzureStackHCI/storageContainers/sc-test"
  }
}

# ---------------------------------------------------------------------------
# Run 3: VHD format (legacy).
# ---------------------------------------------------------------------------
run "vhd_format_accepted" {
  command = plan

  variables {
    disk_file_format = "vhd"
  }
}

# ---------------------------------------------------------------------------
# Run 4: disk_size_gb validation rejects zero.
# ---------------------------------------------------------------------------
run "validation_rejects_zero_disk_size" {
  command = plan

  variables {
    disk_size_gb = 0
  }

  expect_failures = [var.disk_size_gb]
}

# ---------------------------------------------------------------------------
# Run 5: disk_file_format validation rejects unknown format.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_disk_format" {
  command = plan

  variables {
    disk_file_format = "vmdk"
  }

  expect_failures = [var.disk_file_format]
}

# ---------------------------------------------------------------------------
# Run 6: hyper_v_generation validation rejects unknown value.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_hyper_v_generation" {
  command = plan

  variables {
    hyper_v_generation = "V3"
  }

  expect_failures = [var.hyper_v_generation]
}

# ---------------------------------------------------------------------------
# Run 7: logical_sector_bytes validation rejects unsupported value.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_logical_sector_bytes" {
  command = plan

  variables {
    logical_sector_bytes = 1024
  }

  expect_failures = [var.logical_sector_bytes]
}

# ---------------------------------------------------------------------------
# Run 8: physical_sector_bytes validation rejects unsupported value.
# ---------------------------------------------------------------------------
run "validation_rejects_invalid_physical_sector_bytes" {
  command = plan

  variables {
    physical_sector_bytes = 2048
  }

  expect_failures = [var.physical_sector_bytes]
}
