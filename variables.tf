variable "tenant_id" {
  type        = string
  description = "The tenant_id is used to set the root_parent_id value for the enterprise_scale module."
}

variable "management_subscriptions" {
  type        = list
  description = "List of subscriptions to be nested under Management MG"
}

variable "secure_research_subscriptions" {
  type        = list
  description = "List of subscriptions to be nested under Secure Research MG"
}