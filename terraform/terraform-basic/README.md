# Terraform — Basic template

A starting point for any Terraform project. Variables are passed in at runtime using `-var` flags or a `.tfvars` file.

Supports AWS, Azure, and GCP — uncomment the provider you need.

---

## Files

| File | What it does |
|---|---|
| `main.tf` | Provider config and resources |
| `variables.tf` | All input variable definitions |
| `backend.tf` | Remote state configuration |
| `outputs.tf` | Values printed after apply |

---

## Setup

**1. Pick your provider**

Open `main.tf` and `backend.tf`, uncomment the block for your cloud provider, and comment out the rest.

**2. Configure your backend**

In `backend.tf` fill in your state bucket name and region. Run `terraform init` after any backend change.

**3. Initialise**

```bash
terraform init
```

**4. Plan**

```bash
terraform plan \
  -var="project=my-project" \
  -var="resource_name=my-resource" \
  -var="environment=dev"
```

**5. Apply**

```bash
terraform apply \
  -var="project=my-project" \
  -var="resource_name=my-resource" \
  -var="environment=dev"
```

**6. Destroy**

```bash
terraform destroy \
  -var="project=my-project" \
  -var="resource_name=my-resource" \
  -var="environment=dev"
```

---

## Variables

| Variable | Description | Default | Required |
|---|---|---|---|
| `environment` | dev / staging / prod | `dev` | No |
| `project` | Project name for tagging | — | Yes |
| `resource_name` | Name for the sample resource | — | Yes |
| `region` | AWS region (AWS only) | `us-east-1` | No |

---

## Notes

- Replace `aws_resource_type.example` in `main.tf` with the actual resource you need
- If you prefer not to pass `-var` flags every time, see the [terraform-tfvars template](../../terraform-tfvars/) which uses a `terraform.tfvars` file instead
- Never commit real credentials or a populated `.tfvars` file with secrets to version control
