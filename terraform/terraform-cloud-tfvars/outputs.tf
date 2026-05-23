# -----------------------------------------------------------------------------
# outputs.tf
# Outputs are shown in the Terraform Cloud run logs after a successful apply.
# They can also be shared between workspaces using tfe_outputs.
# -----------------------------------------------------------------------------

output "resource_name" {
  description = "Name of the created resource"
  value       = aws_resource_type.example.name
}

output "environment" {
  description = "Environment this was deployed to"
  value       = var.environment
}
