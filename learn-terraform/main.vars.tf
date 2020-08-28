variable "location" {}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "prefix" {
  type    = string
  default = "my"
}

variable "tags" {
  type = "map"

  default = {
    Environment = "Terraform GS"
    Dept        = "Engineering"
  }
}

variable "sku" {
  default = {
    westus2 = "16.04-LTS"
    eastus  = "18.04-LTS"
  }
}