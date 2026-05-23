# Deploy Angular App to EC2

Builds an Angular app in production mode and deploys it to an EC2 instance running Nginx on every push to `main`.

---

## How it works

Six jobs run in sequence:

1. **setup** — installs npm dependencies and caches them
2. **build** — restores the cache, builds the Angular app with `ng build --configuration production`
3. **package** — zips the build output into a deployment package
4. **upload-to-s3** — uploads the zip to S3 with a versioned path and overwrites `latest/`
5. **deploy-to-ec2** — pulls the zip from S3 onto the instance via SSM, unzips into the Nginx root, waits for the command to complete and fails the job if it didn't succeed
6. **restart-nginx** — restarts Nginx and confirms it came back up cleanly

---

## Differences from the HTML EC2 template

| | HTML to EC2 | Angular to EC2 |
|---|---|---|
| **Build step** | None — files are static | `ng build --configuration production` |
| **Artifact** | Raw HTML/CSS/JS files | Compiled Angular output from `dist/` |
| **Node.js** | Not needed | Required for Angular CLI |
| **Dependency cache** | Not needed | `node_modules` cached between jobs |
| **Versioned S3 uploads** | No | Yes — keeps a copy per deploy |
| **SSM wait** | `sleep 10` | Polls SSM command status properly |

---

## Prerequisites

- An EC2 instance running Nginx — see the [Nginx EC2 setup guide](../../ec2/nginx-html-site/)
- SSM Agent installed on the instance (pre-installed on Amazon Linux 2023)
- An S3 bucket for deployment artifacts
- An IAM role with the right permissions (see below)
- Your Angular app at the root of the repo with a valid `angular.json`

---

## Configuration

At the top of the workflow file, update the `env` block:

```yaml
env:
  APP_NAME: your-app-name   # must match the project name in angular.json
  NODE_VERSION: '20'        # change if your project needs a different version
```

`APP_NAME` is used to find the build output at `dist/APP_NAME/browser/` and to name the zip file. It must match your Angular project name exactly — check `angular.json` if you're unsure.

---

## IAM Role

Your GitHub Actions IAM role needs:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:SendCommand", "ssm:GetCommandInvocation", "ssm:ListCommandInvocations"],
      "Resource": "*"
    }
  ]
}
```

The trust policy must allow GitHub Actions to assume the role via OIDC — see the [HTML EC2 template](../deploy-html-ec2/) for the full trust policy.

---

## GitHub Secrets

Add these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|---|---|
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID |
| `AWS_ROLE_NAME` | The IAM role name to assume |
| `AWS_REGION` | e.g. `us-east-1` |
| `EC2_INSTANCE_ID` | e.g. `i-0abc123def456` |
| `S3_BUCKET_NAME` | Bucket used for deployment artifacts |

---

## Usage

1. Copy `deploy-angular-ec2.yml` into your repo at `.github/workflows/`
2. Update `APP_NAME` in the `env` block to match your Angular project name
3. Add the GitHub Secrets listed above
4. Push to `main`

---

## S3 folder structure

Each deployment creates two copies in S3:

```
your-bucket/
└── your-app-name/
    ├── 20240523-143022-a1b2c3d/   ← versioned copy (kept for rollback)
    │   └── your-app-name.zip
    └── latest/                    ← always the most recent build
        └── your-app-name.zip
```

The EC2 instance always pulls from `latest/`. The versioned copies are kept so you can manually roll back by pulling a specific version.

---

## Notes

- The workflow fails fast — if any job fails, everything downstream stops
- SSM commands are polled for completion rather than using a fixed sleep, so the workflow reflects the actual deploy status
- The S3 bucket is not public — the EC2 instance pulls from it using its IAM role
- Nginx serves files from `/usr/share/nginx/html` — adjust the deploy path in the workflow if your config points elsewhere