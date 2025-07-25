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