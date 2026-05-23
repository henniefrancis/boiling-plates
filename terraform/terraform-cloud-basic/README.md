# Terraform Cloud — Basic template

A starting point for projects using Terraform Cloud as the remote backend. State is stored in Terraform Cloud, runs can be triggered remotely, and variables are managed in the workspace UI.

Variables are passed in using `-var` flags when running locally, or set directly in the Terraform Cloud workspace.

---

## How Terraform Cloud is different

| | Self-managed backend | Terraform Cloud |
|---|---|---|
| **State storage** | S3 / Azure Storage / GCS | Terraform Cloud |
| **State locking** | DynamoDB / built-in | Built-in |
| **Runs** | Your machine | Local or remote (Terraform Cloud) |
| **Variables** | tfvars file or -var flags | Workspace UI or tfvars |
| **Credentials** | Local env vars | Workspace environment variables |
| **Audit logs** | Manual | Built-in |

---

## Files

| File | What it does |
|---|---|
| `main.tf` | Provider config and resources |
| `variables.tf` | All input variable definitions |
| `backend.tf` | Terraform Cloud backend configuration |
| `outputs.tf` | Values shown in run logs after apply |

---

## Setup

**1. Create a Terraform Cloud account and workspace**

- Sign up at [app.terraform.io](https://app.terraform.io)
- Create an organisation
- Create a workspace — use **API-driven workflow** if you want to trigger runs from a CI pipeline, or **CLI-driven workflow** for local runs

**2. Update backend.tf**

Fill in your organisation and workspace name in `backend.tf`.

**3. Set credentials in your workspace**

In your Terraform Cloud workspace go to **Variables** and add your cloud credentials as environment variables:

| Provider | Environment variables to add |
|---|---|
| AWS | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| Azure | `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID` |
| GCP | `GOOGLE_CREDENTIALS` |

Mark all credential variables as **Sensitive** so they are never shown in logs.

**4. Authenticate locally**

```bash
terraform login
```

This opens a browser, generates a token, and saves it to `~/.terraform.d/credentials.tfrc.json`. Only needed once per machine.

**5. Pick your provider**

Open `main.tf`, uncomment the provider block for your cloud, and comment out the rest.

**6. Initialise**

```bash
terraform init
```

**7. Plan**

```bash
terraform plan \
  -var="project=my-project" \
  -var="resource_name=my-resource" \
  -var="environment=dev"
```

**8. Apply**

```bash
terraform apply \
  -var="project=my-project" \
  -var="resource_name=my-resource" \
  -var="environment=dev"
```

---

## Setting variables in the workspace UI

Instead of passing `-var` flags every time, you can set Terraform variables directly in your workspace under **Variables → Terraform Variables**. Once set there, you don't need to pass them on the command line at all.

This is the recommended approach for shared workspaces — everyone on the team uses the same values without needing a local tfvars file.

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
- Never store credentials in `variables.tf` or commit them — always use workspace environment variables for secrets
- If you prefer a `terraform.tfvars` file over `-var` flags, see the [terraform-cloud-tfvars template](../terraform-cloud-tfvars/)
