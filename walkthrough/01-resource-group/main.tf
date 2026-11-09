# Stage 1: create the lab resource group only.
# Networking and the database will be added after this stage is reviewed.
resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Project     = "DB-Azure-ADBS"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
