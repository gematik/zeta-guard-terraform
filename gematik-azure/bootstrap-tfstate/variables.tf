variable "subscription_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "zero-trust-architecture"
}

variable "project_short" {
  type    = string
  default = "zeta"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "blob_delete_retention_days" {
  type    = number
  default = 30
}

variable "container_delete_retention_days" {
  type    = number
  default = 7
}

variable "assign_current_principal" {
  type    = bool
  default = true
}

variable "extra_tags" {
  description = "Additional tags to merge into common tags"
  type        = map(string)
  default     = {}
}
