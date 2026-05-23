# Terraform — tfvars template

A starting point for any Terraform project. Variables are loaded automatically from a `terraform.tfvars` file — no `-var` flags needed on every command.

Supports AWS, Azure, and GCP — uncomment the provider you need.

---

## Files

| File | What it does |
|---|---|
| `main.tf` | Provider config and resources |
| `variables.tf` | All input variable definitions |
| `backend.tf` | Remote state configuration |
| `outputs.tf` | Values printed after apply |
| `terraform.tfvars.example` | Copy this to `terraform.tfvars` and fill in your values |
| `.gitignore` | Keeps state files and secrets out of version control |

---

## Setup

**1. Pick your provider**

Open `main.tf` and `backend.tf`, uncomment the block for your cloud provider, and comment out the rest.

**2. Create your tfvars file**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Open `terraform.tfvars` and fill in your values. This file is in `.gitignore` — it stays on your machine.

**3. Configure your backend**

In `backend.tf` fill in your state bucket name and region. Run `terraform init` after any backend change.

**4. Initialise**

```bash
terraform init
```

**5. Plan**

```bash
terraform plan
```

Terraform automatically picks up `terraform.tfvars` — no extra flags needed.

**6. Apply**

```bash
terraform apply
```

**7. Destroy**

```bash
terraform destroy
```

---

## tfvars vs -var flags — which should I use?

| | tfvars file | -var flags |
|---|---|---|
| **Best for** | Projects you run repeatedly | One-off runs or CI pipelines |
| **How it works** | Terraform auto-loads the file | Passed explicitly each command |
| **Secrets** | Keep out of version control | Pass via env vars in CI |
| **Team use** | Each person has their own tfvars | Centralised in pipeline config |

Both templates use the same `variables.tf` — the only difference is how values get passed in.

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
- Never commit `terraform.tfvars` if it contains sensitive values — it is already in `.gitignore`
- For CI pipelines, use environment variables (`TF_VAR_project=my-project`) instead of committing a tfvars file
- If you prefer passing `-var` flags instead of a tfvars file, see the [terraform-basic template](../../terraform-basic/)
