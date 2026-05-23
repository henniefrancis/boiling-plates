# Nginx on EC2 — Setup Guide

Everything you need to get a static HTML site running on an EC2 instance with Nginx, ready for the GitHub Actions deployment workflow.

---

## What you'll end up with

- An EC2 instance running Amazon Linux 2023
- Nginx installed and serving your site
- SSM Agent enabled so the GitHub Actions workflow can deploy without SSH
- An IAM role attached to the instance so it can pull from S3

---

## Step 1 — Launch the EC2 Instance

1. Go to **EC2 → Launch Instance** in the AWS Console
2. Fill in the details:

| Setting | Value |
|---|---|
| **Name** | `my-website` |
| **AMI** | Amazon Linux 2023 |
| **Instance type** | `t3.micro` (free tier eligible) |
| **Key pair** | Create one and save it — you may need it for troubleshooting |
| **Network** | Default VPC is fine |

3. Under **Firewall (Security Group)**, create a new security group with these rules:

| Type | Protocol | Port | Source |
|---|---|---|---|
| SSH | TCP | 22 | My IP |
| HTTP | TCP | 80 | Anywhere |
| HTTPS | TCP | 443 | Anywhere |

4. Leave everything else as default and click **Launch instance**

---

## Step 2 — Attach an IAM Role to the Instance

The instance needs a role so it can pull files from S3 and be managed by SSM.

### Create the role

1. Go to **IAM → Roles → Create role**
2. **Trusted entity type:** AWS Service
3. **Use case:** EC2
4. Click **Next**

### Attach these policies

Search for and attach both:

- `AmazonSSMManagedInstanceCore` — allows SSM to run commands on the instance
- `AmazonS3ReadOnlyAccess` — allows the instance to pull the zip from S3

> If you want to restrict S3 access to just your bucket, skip `AmazonS3ReadOnlyAccess` and use this inline policy instead:
> ```json
> {
>   "Version": "2012-10-17",
>   "Statement": [
>     {
>       "Effect": "Allow",
>       "Action": ["s3:GetObject"],
>       "Resource": "arn:aws:s3:::YOUR_BUCKET_NAME/*"
>     }
>   ]
> }
> ```

5. Name the role `ec2-website-role` and click **Create role**

### Attach the role to the instance

1. Go to **EC2 → Instances**
2. Select your instance
3. Click **Actions → Security → Modify IAM role**
4. Select `ec2-website-role` and click **Update IAM role**

---

## Step 3 — Connect to the Instance

1. Go to **EC2 → Instances**, select your instance
2. Click **Connect → Session Manager → Connect**

This opens a terminal in your browser — no SSH needed.

---

## Step 4 — Install Nginx

Run these commands in the terminal:

```bash
# Update packages
sudo dnf update -y

# Install Nginx
sudo dnf install nginx -y

# Start Nginx
sudo systemctl start nginx

# Enable it to start automatically on reboot
sudo systemctl enable nginx

# Check it is running
sudo systemctl status nginx
```

You should see `active (running)` in the status output.

---

## Step 5 — Test Nginx is Working

1. Go back to **EC2 → Instances**
2. Copy the **Public IPv4 address**
3. Open it in your browser — `http://YOUR_PUBLIC_IP`

You should see the default Nginx welcome page. If you do, Nginx is running correctly.

---

## Step 6 — Create the Website Directory

The GitHub Actions workflow deploys your site to `/usr/share/nginx/html/website`. Create that folder and set the right permissions:

```bash
# Create the website directory
sudo mkdir -p /usr/share/nginx/html/website

# Set ownership so Nginx can read it
sudo chown -R nginx:nginx /usr/share/nginx/html/website

# Set permissions
sudo chmod -R 755 /usr/share/nginx/html/website
```

---

## Step 7 — Configure Nginx

Tell Nginx to serve your site from the `/website` folder:

```bash
sudo nano /etc/nginx/conf.d/website.conf
```

Paste this in:

```nginx
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html/website;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Save and exit (`Ctrl+X`, then `Y`, then `Enter`).

Remove the default Nginx config so it doesn't conflict:

```bash
sudo rm /etc/nginx/conf.d/default.conf 2>/dev/null || true
```

Test the config is valid:

```bash
sudo nginx -t
```

You should see `syntax is ok` and `test is successful`.

Reload Nginx to apply the changes:

```bash
sudo systemctl reload nginx
```

---

## Step 8 — Verify SSM is Working

The GitHub Actions workflow uses SSM to run commands on this instance. Check SSM can see your instance:

1. Go to **Systems Manager → Fleet Manager**
2. Your instance should appear with a status of **Online**

If it doesn't appear, wait a minute and refresh — it can take a moment after attaching the role.

---

## Step 9 — Create the S3 Staging Bucket

The workflow uploads a zip to S3, then the instance pulls it down. Create the bucket:

1. Go to **S3 → Create bucket**
2. **Bucket name:** something unique like `deploy-staging-yourname`
3. **Region:** same region as your EC2 instance
4. Leave **Block all public access** turned ON — the instance pulls from it using its IAM role, not public access
5. Click **Create bucket**

Note the bucket name — this is your `S3_BUCKET_NAME` secret in GitHub.

---

## You're ready

Your instance is set up. Now grab these values for your GitHub Secrets:

| GitHub Secret | Where to find it |
|---|---|
| `AWS_ACCOUNT_ID` | Top right of the AWS Console |
| `AWS_ROLE_NAME` | The name of the IAM role you created for GitHub Actions |
| `AWS_REGION` | e.g. `us-east-1` |
| `EC2_INSTANCE_ID` | EC2 → Instances → Instance ID column |
| `S3_BUCKET_NAME` | The bucket name you just created |

Once you add those secrets to your repo, push to `main` and the workflow will handle the rest.

---

## Troubleshooting

**Nginx not serving the site after deploy**
- Check the deploy path in the workflow matches `/usr/share/nginx/html/website`
- Run `sudo nginx -t` to check for config errors
- Check Nginx logs: `sudo tail -f /var/log/nginx/error.log`

**SSM command not reaching the instance**
- Confirm the IAM role is attached to the instance
- Check the instance shows as Online in Fleet Manager
- Make sure the instance has outbound internet access to reach SSM endpoints

**S3 access denied on the instance**
- Confirm `AmazonS3ReadOnlyAccess` or the inline policy is attached to the instance role
- Make sure the bucket is in the same region as the instance