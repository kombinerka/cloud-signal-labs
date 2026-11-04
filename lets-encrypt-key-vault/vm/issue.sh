#!/usr/bin/env bash
# Example one: Pinecone's nginx VM (HTTP-01 via the webroot plugin). Run as a user with sudo.
# Commands as on certbot.eff.org (Nginx, snap) and the certbot User Guide (webroot). NOT RUN on a real VM.
# shop.pinecone-gear.example and /var/www/shop are fictional; replace with your domain and nginx root.
set -euo pipefail

# 1. Install certbot (needs snapd) and make the command available
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/local/bin/certbot

# 2. Get the certificate only (certbot does not edit nginx; the config lives in Git).
#    nginx must already serve /var/www/shop on port 80 for this name (HTTP-01).
sudo certbot certonly --webroot -w /var/www/shop -d shop.pinecone-gear.example

# 3. Point nginx at the live files; do not copy them. In the server block (nginx syntax, not from certbot docs):
#      ssl_certificate     /etc/letsencrypt/live/shop.pinecone-gear.example/fullchain.pem;
#      ssl_certificate_key /etc/letsencrypt/live/shop.pinecone-gear.example/privkey.pem;
