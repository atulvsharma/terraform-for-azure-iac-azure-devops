variable "environment" {
  description = "The deployment environment name (dev, qa, prod, stage)"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}