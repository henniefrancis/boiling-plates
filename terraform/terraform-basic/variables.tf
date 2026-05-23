# -----------------------------------------------------------------------------
# variables.tf
# Define all input variables here.
# Values are passed in at runtime via -var flags or a .tfvars file.
# -----------------------------------------------------------------------------

# -- Common --

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "project" {
  description = "Project name — used for tagging and naming resources"
  type        = string
}

variable "resource_name" {
  description = "Name to give the sample resource"
  type        = string
}

# -- AWS --

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

# -- Azure --
# variable "subscription_id" {
#   description = "Azure subscription ID"
#   type        = string
# }

# variable "location" {
#   description = "Azure region to deploy into"
#   type        = string
#   default     = "East US"
# }

# -- GCP --
# variable "project_id" {
#   description = "GCP project ID"
#   type        = string
# }
