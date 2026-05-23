# -----------------------------------------------------------------------------
# main.tf
# Entry point for your Terraform configuration.
# Uncomment the provider block for your cloud of choice.
# -----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {

    # -- AWS --
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    # -- Azure --
    # azurerm = {
    #   source  = "hashicorp/azurerm"
    #   version = "~> 3.0"
    # }

    # -- GCP --
    # google = {
    #   source  = "hashicorp/google"
    #   version = "~> 5.0"
    # }

  }

  # Backend configuration lives in backend.tf
}

# -----------------------------------------------------------------------------
# Provider configuration
# Uncomment the block that matches your cloud provider above.
#
# NOTE: When using Terraform Cloud, provider credentials should be set as
# environment variables in your Terraform Cloud workspace, not hardcoded here.
# AWS:   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY  (or use OIDC)
# Azure: ARM_CLIENT_ID / ARM_CLIENT_SECRET / ARM_TENANT_ID / ARM_SUBSCRIPTION_ID
# GCP:   GOOGLE_CREDENTIALS
# -----------------------------------------------------------------------------

# -- AWS --
provider "aws" {
  region = var.region
}

# -- Azure --
# provider "azurerm" {
#   features {}
# }

# -- GCP --
# provider "google" {
#   project = var.project_id
#   region  = var.region
# }

# -----------------------------------------------------------------------------
# Sample resource — replace this with your actual resource
# -----------------------------------------------------------------------------

resource "aws_resource_type" "example" {
  name = var.resource_name

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}
