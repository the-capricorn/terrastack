# ----------------------------------------------------------------------------
# DATA SOURCE: Current Azure account information
# ----------------------------------------------------------------------------
# This data source automatically reads the Subscription ID from the
# credentials that are configured in the environment (e.g. a Service Principal
# or an Azure CLI login). No manual input is required.
data "azapi_client_config" "current" {}
