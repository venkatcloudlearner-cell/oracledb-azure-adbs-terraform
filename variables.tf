variable "subscription_id" {
  description = "Azure subscription selected during the local Azure CLI sign-in."
  type        = string
}

variable "database_name" {
  description = "Azure resource name and display name for the lab database."
  type        = string
  default     = "adbsazurelab01"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{0,29}$", var.database_name))
    error_message = "Use up to 30 lowercase letters and digits, starting with a letter."
  }
}

variable "database_version" {
  description = "Database version checked against the region's live version API."
  type        = string
  default     = "19c"
}

variable "admin_password" {
  description = "Database ADMIN password; enter privately through Set-DatabasePassword.ps1, never tfvars."
  type        = string
  sensitive   = true
  ephemeral   = true

  validation {
    condition = (
      length(var.admin_password) >= 12 && length(var.admin_password) <= 30 &&
      can(regex("[A-Z]", var.admin_password)) && can(regex("[a-z]", var.admin_password)) &&
      can(regex("[0-9]", var.admin_password)) &&
      !strcontains(lower(var.admin_password), "admin") && !strcontains(var.admin_password, "\"")
    )
    error_message = "Use 12-30 characters with uppercase, lowercase and a digit; exclude double quotes and ADMIN."
  }
}

variable "location" {
  description = "Azure region for the lab. Service capacity will be checked before database creation."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource group containing this lab's Terraform-managed resources."
  type        = string
  default     = "rg-adbs-azure-lab"
}

variable "virtual_network_name" {
  description = "Virtual network for the private Oracle database lab."
  type        = string
  default     = "vnet-adbs-azure-lab"
}

variable "virtual_network_cidr" {
  description = "Private IPv4 address space; review overlap before connecting other networks."
  type        = string
  default     = "10.100.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.virtual_network_cidr))
    error_message = "Supply a valid IPv4 CIDR."
  }
}

variable "oracle_subnet_name" {
  description = "Subnet delegated exclusively to Oracle Database@Azure."
  type        = string
  default     = "snet-oracle-adbs"
}

variable "oracle_subnet_cidr" {
  description = "Non-overlapping IPv4 range inside the VNet; /27 is the documented minimum for one ADB-S database."
  type        = string
  default     = "10.100.2.0/27"

  validation {
    condition     = can(cidrnetmask(var.oracle_subnet_cidr)) && try(tonumber(split("/", var.oracle_subnet_cidr)[1]) >= 22 && tonumber(split("/", var.oracle_subnet_cidr)[1]) <= 27, false)
    error_message = "Use a valid IPv4 CIDR between /22 and /27."
  }
}
