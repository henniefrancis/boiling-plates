# -----------------------------------------------------------------------------
# outputs.tf
# Outputs are values Terraform prints after a successful apply.
# Useful for passing values to other modules or just knowing what was created.
# -----------------------------------------------------------------------------

output "resource_name" {
  description = "Name of the created resource"
  value       = aws_resource_type.example.name
}

output "environment" {
  description = "Environment this was deployed to"
  value       = var.environment
}

# Add your own outputs below as you build out the configuration
