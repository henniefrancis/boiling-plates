# -----------------------------------------------------------------------------
# backend.tf
# Configures where Terraform stores its state file.
# Using a remote backend means your state is shared across your team
# and not sitting on someone's laptop.
#
# Uncomment the backend block for your cloud of choice.
# Run `terraform init` after making changes here.
# -----------------------------------------------------------------------------

terraform {

  # -- AWS S3 backend --
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "your-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-terraform-lock-table"   # optional but recommended for state locking
    encrypt        = true
  }

  # -- Azure Storage backend --
  # backend "azurerm" {
  #   resource_group_name  = "your-rg"
  #   storage_account_name = "yourstorageaccount"
  #   container_name       = "tfstate"
  #   key                  = "your-project/terraform.tfstate"
  # }

  # -- GCP GCS backend --
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "your-project/terraform.tfstate"
  # }

  # -- Local backend (not recommended for teams) --
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

}
