# The app works. Why does Application Gateway return 502?

Companion code for the Cloud Signal Short **"The App Works. Why Does Application Gateway Return 502?"**.

The app answers when you call it directly, but the gateway returns 502. The two requests may not test the same thing:
watch the **Host header**. A hostname-sensitive app (virtual hosts, App Service, many web servers) answers its own
hostname with 200 and anything else with 404. If the health probe sends the backend's IP as Host, the probe fails,
no backend is healthy, and the gateway has nowhere to forward to: 502.

## See it locally

```bash
python3 fixture.py &
curl -i -H 'Host: app.example.test' http://127.0.0.1:8080/   # 200: the intended site works
curl -i http://127.0.0.1:8080/                               # 404: what a default probe gets
```

## Diagnose a real gateway

```bash
RG=rg-appgw GW=agw-shop ./diagnose.sh
```

[`diagnose.sh`](diagnose.sh) shows backend health per server (with the probe log), the probes' host and path, and the
host header the backend settings send. Compare the probe's hostname and path with what the app expects before
blaming capacity.

## The fix, as code

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) |

A custom probe with the right host (`pickHostNameFromBackendHttpSettings`, or a fixed `host`) and a real health path,
plus backend settings that send the backend's hostname. After changing it, wait for a fresh successful probe before
you test with a user request.

This is one possible cause of a 502, not every cause: also check backend certificates (HTTPS to the backend),
NSGs/UDRs on the gateway subnet, timeouts, and DNS resolution of FQDN backends.

## Sources

- Microsoft: Troubleshoot bad gateway errors in Application Gateway: https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-troubleshooting-502
- Microsoft: Application Gateway health probes: https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-probe-overview
- Microsoft: Preserve the original host name: https://learn.microsoft.com/en-us/azure/architecture/best-practices/host-name-preservation
