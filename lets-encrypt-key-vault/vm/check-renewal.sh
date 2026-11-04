#!/usr/bin/env bash
# Prove renewal works (certbot User Guide + certbot.eff.org instructions).
set -euo pipefail

# Test renewal against the Let's Encrypt staging server; nothing is saved. Deploy hooks do NOT run here.
sudo certbot renew --dry-run

# The scheduler that runs "certbot renew" (snap: a systemd timer; other installs: /etc/crontab/ or /etc/cron.*/*)
systemctl list-timers | grep certbot

# Same dry run, but also run the deploy hook(s) (only if the dry run succeeds): nginx should reload.
sudo certbot renew --dry-run --run-deploy-hooks

# End state: name, domains, expiry date and days left
sudo certbot certificates
