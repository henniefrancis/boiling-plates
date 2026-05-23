# TL;DR — How the deployment works

Quick explanations for every part of the deploy-html-ec2 workflow. Read this if you want to understand what's happening under the hood, not just how to run it.

---

## What triggers the GitHub Actions workflow?

Every time you push to `main`, GitHub detects the change and automatically kicks off the workflow. This is controlled by this block at the top of the workflow file:

```yaml
on:
  push:
    branches: [ main ]
```

Nothing else needed. No webhooks to set up, no manual triggers. Push to main, deployment starts.

---

## What is OIDC and why does it matter?

OIDC (OpenID Connect) is how GitHub Actions proves its identity to AWS without storing any credentials.

The old way was to create an AWS access key, paste it into GitHub Secrets, and hope nobody ever found it. OIDC replaces that entirely. Instead, GitHub and AWS have a trust relationship — GitHub says "this workflow is running from this repo" and AWS says "ok, I trust that, here's temporary credentials that expire in an hour".

No long-lived keys. Nothing to rotate. Nothing to leak.

---

## Why is S3 used as a staging bucket?

GitHub Actions can't talk directly to your EC2 instance in this setup. There's no SSH, no open ports for file transfer. The instance sits behind a security group that only allows HTTP and HTTPS traffic from the public.

S3 is the handoff point between the two jobs in the workflow:

- GitHub Actions zips your files and uploads to S3 using the IAM role
- EC2 pulls the zip down from S3 using its own IAM role
- Both sides already have access, no extra networking needed

It also means if the deploy job fails, the zip is still in S3 and you can re-trigger the deploy without re-uploading everything. And it keeps the EC2 instance completely locked down — no SSH ports open, no keys to manage.

---

## What does the EC2 instance do during deployment?

Everything on the instance is triggered remotely by GitHub Actions via SSM — no SSH involved. Three things happen in order:

**① Pull the zip from S3**
The instance uses its IAM role to authenticate with S3 and download the zip. No credentials stored on the machine.

**② Unzip into the Nginx web root**
The zip gets extracted into `/usr/share/nginx/html/website`, overwriting the previous version cleanly. The zip is deleted straight after to keep things tidy.

**③ Set permissions**
Nginx runs as the `nginx` user. If files are owned by someone else, Nginx can't read them and the site breaks. `chown -R nginx:nginx` makes sure ownership is always correct after every deploy.

---

## Why does Nginx restart as a separate job?

The workflow has three jobs — build, deploy, restart — and each one only runs if the previous one succeeds. Restarting Nginx is intentionally last because:

- If the file copy fails, you don't want to restart Nginx and briefly serve nothing
- Separating it makes it easy to see exactly which step failed in the GitHub Actions UI
- `systemctl status nginx` runs after the restart so the logs show whether Nginx came back up cleanly

---

## What is SSM and why use it instead of SSH?

SSM (AWS Systems Manager) lets you run commands on EC2 instances without opening any ports or managing SSH keys. GitHub Actions sends a command to the SSM API, AWS routes it to the instance through the SSM Agent running on the machine, and the output comes back through the same channel.

From a security standpoint this is much better than SSH:
- Port 22 stays closed
- No key pairs to manage or rotate
- Every command is logged in AWS CloudTrail
- Access is controlled by IAM, not by who has a key file

The only requirement is that SSM Agent is installed and running on the instance and the instance has the `AmazonSSMManagedInstanceCore` policy attached to its IAM role. Amazon Linux 2023 comes with SSM Agent pre-installed.

---

## What is the IAM role doing?

There are actually two IAM roles in this setup and they do different things:

**The GitHub Actions role** — assumed by the workflow via OIDC. It needs permission to upload to S3 and send SSM commands. This is what lets the workflow talk to AWS without storing credentials in GitHub.

**The EC2 instance role** — attached to the EC2 instance itself. It needs permission to read from S3 so the instance can pull the zip during deployment. It also needs `AmazonSSMManagedInstanceCore` so SSM can reach the instance.

Think of it this way: the GitHub role is the delivery driver, the EC2 role is the receiving dock. Both need the right permissions for the handoff to work.

---

## How does the user access the site?

After Nginx restarts it starts serving files from `/usr/share/nginx/html/website` on port 80. Anyone who visits the EC2 instance's public IP address in a browser gets the site.

The security group has port 80 open to the public (`0.0.0.0/0`) which is what allows this. Port 443 is also open for when you add HTTPS later.

---

## What does Nginx actually do?

Nginx is a web server. It sits on the EC2 instance, listens for incoming HTTP requests on port 80, and serves the HTML files back to whoever is asking.

The config file at `/etc/nginx/conf.d/website.conf` tells it where the files are and how to handle requests:

```nginx
server {
    listen 80;
    root /usr/share/nginx/html/website;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
```

`try_files` means: look for the exact file requested, if that doesn't exist try it as a folder, if that doesn't exist return a 404. That covers most cases for a static site.

---

## What is in the src/ folder?

Your HTML, CSS, JavaScript, images — everything that makes up the website. The workflow does a sparse checkout of just the `src/` folder, zips its contents, and that zip is what ends up on the server.

Keep your source files in `src/` and the workflow handles the rest. If you change the folder name, update the `sparse-checkout` and zip steps in the workflow to match.