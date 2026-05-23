# Deploy HTML Site to EC2

Deploys a static HTML site to an EC2 instance running Nginx whenever you push to `main`.

---

## How it works

Three jobs run in sequence:

1. **build-and-upload** — checks out your `src` folder, zips it, and uploads it to S3
2. **deploy-to-ec2** — pulls the zip from S3 onto your EC2 instance via SSM and unzips it into the Nginx web root
3. **restart-nginx** — restarts Nginx to serve the updated files

No SSH keys needed. It uses AWS SSM to run commands on the instance, and OIDC to authenticate GitHub Actions with AWS — no long-lived credentials.

---

## Prerequisites

- An EC2 instance running Nginx
- SSM Agent installed and running on the instance (comes pre-installed on Amazon Linux 2/2023)
- An S3 bucket to use as a staging area for the deployment
- An IAM role with the right permissions (see below)
- Your HTML files inside a `src/` folder at the root of your repo

---

## IAM Role

Your IAM role needs these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Resource": "*"
    }
  ]
}
```

The role also needs a trust policy that allows GitHub Actions to assume it via OIDC:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
        }
      }
    }
  ]
}
```

---

## GitHub Secrets

Add these in your repo under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID |
| `AWS_ROLE_NAME` | The IAM role name to assume |
| `AWS_REGION` | e.g. `us-east-1` |
| `EC2_INSTANCE_ID` | e.g. `i-0abc123def456` |
| `S3_BUCKET_NAME` | The S3 bucket name used for staging |

---

## Usage

1. Copy `deploy.yaml` into your repo at `.github/workflows/`
2. Add the GitHub Secrets listed above
3. Make sure your HTML files are inside a `src/` folder
4. Push to `main`

---

## Notes

- The workflow deploys to `/usr/share/nginx/html/website` on the instance — adjust the path in the workflow if your Nginx config points elsewhere
- The S3 bucket is used as a temporary staging area, the zip is not kept after deployment
- SSM Agent must be able to reach AWS endpoints — make sure your EC2 instance has internet access or a VPC endpoint for SSM