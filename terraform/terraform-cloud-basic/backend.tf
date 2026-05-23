# -----------------------------------------------------------------------------
# backend.tf
# Configures Terraform Cloud as the remote backend.
# State is stored and runs are executed in Terraform Cloud — not locally.
#
# Prerequisites:
#   1. A Terraform Cloud account — https://app.terraform.io
#   2. An organisation created in Terraform Cloud
#   3. A workspace created under that organisation
#   4. Authenticated locally — run `terraform login` once before `terraform init`
#
# Run `terraform init` after making any changes here.
# -----------------------------------------------------------------------------

terraform {

  cloud {
    organization = "your-organisation-name"

    workspaces {
      name = "your-workspace-name"
    }

    # -- Use tags instead of a single workspace name if you have multiple environments --
    # workspaces {
    #   tags = ["app:your-project", "env:dev"]
    # }
  }

}
