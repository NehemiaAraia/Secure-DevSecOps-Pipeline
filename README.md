<p align="center">
  <h1 align="center">Secure DevSecOps Pipeline</h1>
  <p align="center">
    This project demonstrates how to build a secure CI/CD pipeline by integrating DevSecOps practices early in the development lifecycle. It shifts security left, catching vulnerabilites at the source code level before reaching production.<br />
  </p>
</p>

## Features


- **VS Code**
- **Dockerized CI/CD Pipeline**
- **Static Code Analysis (SAST) - Pre-commit**
- **Software Composition Analysis (SCA) - Docker Scout**
- **Software Bill of Materials (SBOM)**
- **Chainguard Distroless base image**


## Step 1.
Opened project in VS Code, lauched the terminal, and used Docker to start building and testing. I Used a Dockerfile to containerize the app. The goal was to embed security into each stage of the development lifecycle by containerizing the NGINX app which I started with, scan for vulnerabilities, block insecure builds, and document dependencies.



## Step 2
Created and refined a CICD.sh bash script that included:

- Remove any existing containers
- Build the image using Docker
- Run Docker Scout to detect vulnerabilites
- Generate an SBOM
- Run the container if passes checks

```shell
#!/bin/bash
set -e

APP_NAME=mywebapp
VERSION=SECURE

# Clenaup old container/build image
docker rm -f $APP_NAME 2>/dev/null || true
docker build -t $APP_NAME:$VERSION . 
docker scout cves $APP_NAME:$VERSION --output ./vulns.report
docker scout cves $APP_NAME:$VERSION --only-severity high,critical --exit-code
docker scout sbom --output $APP_NAME:$VERSION.sbom $APP_NAME:$VERSION:SECURE

# Run the container
docker run -d -p 80:80 --name webapp $APP_NAME:$VERSION
```
## Step 3
Integrated secret scanning with Pre-commit and Gitleaks to detect secrets in the source code before they're comitted.

```yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.1
    hooks:
      - id: gitleaks
```

## Step 4
After scanning the default base image and finding multiple vulnerabiliities, I replaced it with a distroless version from Chainguard. This reduced almost all CVEs which improved the security posture significantly.


```
FROM cgr.dev/chainguard/nginx:latest
```

## Step 5
I succesfuly completed my project when:
- I ran the script and saw that the image was built, scanned, and depolyed without errors.
- Docker Scout was functional and generated the CVE report and SBOM.
- Verfied that no containers ran if high/critical CVEs were found.
- Pre-commit was functional and stopped any attempt to push any hardcoded secrets if any were found.

<img width="2940" height="1912" alt="Screenshot 2025-07-25 at 1 26 45 PM" src="https://github.com/user-attachments/assets/4151d3f8-1af5-405f-9f2f-4e64c00b1391" />
