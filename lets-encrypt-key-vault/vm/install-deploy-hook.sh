#!/usr/bin/env bash
# Deploy hook: reload nginx after every successful renewal.
# Same pattern as the certbot User Guide's renewal-hooks example (there: HAProxy pre/post hooks).
# "systemctl reload nginx" is the systemd/nginx command, not taken from the certbot docs.
set -euo pipefail
sudo sh -c 'printf "#!/bin/sh\nsystemctl reload nginx\n" > /etc/letsencrypt/renewal-hooks/deploy/reload-nginx'
sudo chmod 755 /etc/letsencrypt/renewal-hooks/deploy/reload-nginx
