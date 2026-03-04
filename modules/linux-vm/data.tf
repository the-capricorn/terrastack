# ----------------------------------------------------------------------------
# DATA SOURCE: Current Azure account information
# ----------------------------------------------------------------------------
# Reads the Subscription ID from the configured credentials automatically.
data "azapi_client_config" "current" {}
