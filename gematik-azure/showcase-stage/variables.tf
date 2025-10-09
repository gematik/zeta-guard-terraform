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
