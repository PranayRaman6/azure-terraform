variable "root" {
  type        = string
  description = "Tenant root management group"
}

variable "prod_platform_sub" {
  type        = string
  description = "Platform management subscription"
}

variable "prod_landingzone_sub" {
  type        = string
  description = "Landing zone subscription - Test"
}

variable "prod_policyset_nist" {
  type        = string
  description = "Policy set name for NIST SP 800-171 R2"
}

variable "prod_policyset_nist_assign_exclude" {
  type        = string
  description = ""
}

variable "prod_policyset_nist_assign_include" {
  type        = string
  description = ""
}

variable "prod_policyset_nist_assign_network_watcher" {
  type        = list(string)
  description = ""
}

variable "prod_policyset_nist_assign_log_analytics" {
  type        = string
  description = ""
}