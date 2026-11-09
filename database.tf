# Stage 4: a small private Autonomous Database managed by Terraform via AzAPI.
resource "azapi_resource" "database" {
  type      = "Oracle.Database/autonomousDatabases@2025-09-01"
  name      = var.database_name
  parent_id = azurerm_resource_group.lab.id
  location  = azurerm_resource_group.lab.location
  tags      = azurerm_resource_group.lab.tags

  body = {
    properties = {
      dataBaseType                      = "Regular"
      displayName                       = var.database_name
      dbWorkload                        = "OLTP"
      dbVersion                         = var.database_version
      computeModel                      = "ECPU"
      computeCount                      = 2
      dataStorageSizeInGbs              = 20
      isAutoScalingEnabled              = false
      isAutoScalingForStorageEnabled    = false
      licenseModel                      = "LicenseIncluded"
      characterSet                      = "AL32UTF8"
      ncharacterSet                     = "AL16UTF16"
      isMtlsConnectionRequired          = true
      vnetId                            = azurerm_virtual_network.lab.id
      subnetId                          = azurerm_subnet.oracle.id
      privateEndpointLabel              = var.database_name
      autonomousMaintenanceScheduleType = "Regular"
      backupRetentionPeriodInDays       = 1
      isLocalDataGuardEnabled           = false
    }
  }

  # Write-only plus ephemeral: do not persist the ADMIN password in plan or state.
  sensitive_body = {
    properties = {
      adminPassword = var.admin_password
    }
  }
  sensitive_body_version = {
    "properties.adminPassword" = "1"
  }

  response_export_values = ["properties.lifecycleState", "properties.provisioningState"]

  timeouts {
    create = "2h"
    update = "1h"
    delete = "1h"
  }
}
