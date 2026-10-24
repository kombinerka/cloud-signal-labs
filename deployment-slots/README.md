# Blue-green and canary with App Service deployment slots

▶ **[Watch the video](https://www.youtube.com/watch?v=NlzHxWWi6o8)**

Companion code for the Cloud Signal Short **"Blue-Green vs Canary Deployments in 40 Seconds"**.

| | Blue-green | Canary |
|---|---|---|
| How | deploy to a second environment, test, switch **all** traffic at once | send a small share (e.g. 5%) to the new version, raise it step by step |
| Rollback | switch back, instant | route the share back to 0 |
| Costs | a second environment | good monitoring, a slower release |
| Blast radius | everyone, once switched | only the current share |
| With slots | [`blue-green.sh`](blue-green.sh): deploy to `staging`, swap | [`canary.sh`](canary.sh): `az webapp traffic-routing set --distribution staging=5`, then swap |

## The infrastructure: an app with a staging slot

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) (`azurerm_linux_web_app_slot`) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) (`Microsoft.Web/sites/slots`) |

Slots need the Standard tier or higher. The traffic percentage is deliberately not in the IaC: it changes during a
release, and keeping it in code would reset it on every deployment.

## Good to know

- A swap warms up the staging instances before switching, so users don't hit a cold start. Settings marked as
  *deployment slot settings* stay with the slot; everything else moves with the swap.
- Routed users get a cookie and stay on their slot for about an hour. Testers can opt in with
  `?x-ms-routing-name=staging` and back out with `?x-ms-routing-name=self`.
- Database changes must work with both versions during the switch (expand first, contract later), or neither
  pattern can roll back cleanly.

## Sources

- Microsoft: Set up staging environments in Azure App Service: https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots
- Azure CLI: az webapp traffic-routing: https://learn.microsoft.com/en-us/cli/azure/webapp/traffic-routing
