# Terraform Cloud — tfvars template

A starting point for projects using Terraform Cloud with a `terraform.tfvars` file for local runs. State is stored in Terraform Cloud — no S3 bucket or DynamoDB table needed.

---

## Local vs remote runs — important difference

This is the key thing to understand when using tfvars with Terraform Cloud:

| | CLI-driven (local run) | API-driven (remote run) |
|---|---|---|
| **Where plan/apply runs** | Your machine | Terraform Cloud |
| **tfvars file loaded** | ✅ Yes — automatically | ❌ No — set vars in workspace UI |
| **Best for** | Local development | CI/CD pipelines |

`terraform.tfvars` works when you run Terraform locally. If you're triggering runs from a CI pipeline or the Terraform Cloud UI, set your variables in the workspace instead.

---

## Files

| File | What it does |
|---|---|
| `main.tf` | Provider config and resources |
| `variables.tf` | All input variable definitions |
| `backend.tf` | Terraform Cloud backend configuration |
| `outputs.tf` | Values shown in run logs after apply |
| `terraform.tfvars.example` | Copy this to `terraform.tfvars` and fill in your values |
| `.gitignore` | Keeps state files, credentials, and secrets out of version control |

---

## Setup

**1. Create a Terraform Cloud account and workspace**

- Sign up at [app.terraform.io](https://app.terraform.io)
- Create an organisation
- Create a workspace using the **CLI-driven workflow** for local runs with tfvars

**2. Update backend.tf**

Fill in your organisation and workspace name in `backend.tf`.

**3. Set credentials in your workspace**

In your Terraform Cloud workspace go to **Variables** and add your cloud credentials as environment variables:

| Provider | Environment variables to add |
|---|---|
| AWS | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| Azure | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` |
| GCP | `GOOGLE_CREDENTIALS` |

Mark all credential variables as **Sensitive**.

**4. Authenticate locally**

```bash
terraform login
```

**5. Create your tfvars file**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Fill in your values. This file stays on your machine — it is in `.gitignore`.

**6. Pick your provider**

Open `main.tf`, uncomment the provider block for your cloud, and comment out the rest.

**7. Initialise**

```bash
terraform init
```

**8. Plan and apply**

```bash
terraform plan
terraform apply
```

Terraform loads `terraform.tfvars` automatically — no `-var` flags needed.

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
- `terraform.tfvars` is loaded for local runs only — for remote runs set variables in the workspace UI
- Never commit `terraform.tfvars` — it is already in `.gitignore`
- If you prefer `-var` flags over a tfvars file, see the [terraform-cloud-basic template](../terraform-cloud-basic/)
