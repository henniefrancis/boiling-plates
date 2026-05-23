# -----------------------------------------------------------------------------
# variables.tf
# Define all input variables here.
#
# When using Terraform Cloud there are two ways to supply values:
#
#   1. Terraform variables — set in the workspace UI under Variables,
#      or passed via -var flags when running locally.
#      These map directly to the variables defined below.
#
#   2. Environment variables — set in the workspace UI as env vars
#      (e.g. AWS_ACCESS_KEY_ID). Used for credentials, not config.
#
# Sensitive values (passwords, tokens, keys) should always be marked
# as sensitive in the Terraform Cloud workspace so they are never shown in logs.
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
