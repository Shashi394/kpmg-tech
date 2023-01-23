# Generic Input Variables

variable "business_division" {
  description = "Organisation"
  type = string
  default = "sap"
}

variable "environment" {
  description = "Environment Variable"
  type = string
  default = "dev"
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type = string
  default = "rg-default"  
}

variable "resource_group_location" {
  description = "Region"
  type = string
  default = "westeurope"  
}

