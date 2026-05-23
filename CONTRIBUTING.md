# Contributing to boiling-plates ♨️

First off, thanks for taking the time to contribute! The whole point of this repo is to stop developers from copy-pasting the wrong Stack Overflow answer from 2014 — and you're helping with that.

---

## Before You Start

- Check the [open issues](../../issues) to see if someone is already working on what you have in mind
- If you're adding a new template, open an issue first to discuss it — this avoids wasted effort if it doesn't fit
- If you're fixing a bug or improving an existing template, just go ahead and open a PR

---

## How to Contribute

1. Fork the repo
2. Create a branch off `main`

```bash
git checkout -b template/your-template-name
# or for a fix
git checkout -b fix/what-you-are-fixing
```

3. Make your changes
4. Push your branch and open a Pull Request against `main`
5. Fill in the PR template
6. Wait for review — I'll get back to you as soon as I can

---

## Adding a New Template

Every template must follow this structure:

```
category/
└── your-template-name/
    ├── README.md        # Required — see template README guide below
    ├── .env.example     # Required if the template needs secrets or env vars
    └── assets/          # Optional — architecture diagrams, screenshots
```

Place your template in the right category folder:

| Category | Folder |
|---|---|
| GitHub Actions workflows | `github-actions/` |
| EC2 setups | `ec2/` |
| Serverless / Lambda | `serverless/` |
| IaC (CDK, Terraform, SAM) | `infrastructure/` |

If your template doesn't fit any category, mention it in your issue and we'll figure it out.

---

## Template README Guide

Every template needs its own `README.md` with these sections:

```markdown
# Template Name

One line description of what this does.

## What it does
## Prerequisites
## How to use
## Required secrets / environment variables
## Notes or gotchas
```

Keep it practical. Someone should be able to read it and be up and running in under 10 minutes.

---

## Guidelines

- **Test your template** before submitting — it should actually work
- **No fluff** — keep READMEs clear and to the point
- **No credentials** — double check there are no API keys, passwords, or account IDs in your files
- **Use `.env.example`** for any secrets — never hardcode them
- **One template per PR** — keeps reviews focused

---

## Questions?

Open an issue or reach out on [LinkedIn](https://www.linkedin.com/in/henniefrancis) — happy to help.
