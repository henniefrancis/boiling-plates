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
# -----------------------------------------------------------------------------

# -- AWS --
provider "aws" {
  region = var.region
}

# -- Azure --
# provider "azurerm" {
#   features {}
#   subscription_id = var.subscription_id
# }

# -- GCP --
# provider "google" {
#   project = var.project_id
#   region  = var.region
# }

# -----------------------------------------------------------------------------
# Sample resource — replace this with your actual resource
# -----------------------------------------------------------------------------

# This is a placeholder to show the pattern.
# Replace "aws_resource_type" with the resource you need,
# e.g. aws_s3_bucket, aws_vpc, aws_instance, azurerm_resource_group, google_storage_bucket

resource "aws_resource_type" "example" {
  name = var.resource_name

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }
}
