# One datacenter fails. Does your app?

▶ **[Watch the video](https://www.youtube.com/watch?v=NI9L6OnpcGU)**

Companion code for the Cloud Signal Short **"One Azure Datacenter Fails. Does Your App? (Availability Zones)"**.

A region is an area with datacenters close together. Many regions are split into **availability zones**: separate
locations with their own power, cooling and networking, usually three. One VM in one zone fails with that zone.
Copies in two or three zones behind a load balancer keep serving: the health probe simply stops sending traffic to
the zone that's down.

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) |

Both build the same thing: a flexible scale set with 3 VMs spread over zones 1, 2 and 3, a zone-redundant Standard
public IP and Standard load balancer, and nginx answering with the zone it runs in. Refresh the URL a few times and
you see different zones.

```bash
# Terraform
terraform -chdir=terraform apply -var "ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)"
# Bicep
az group create -n rg-shop-zones -l westeurope
az deployment group create -g rg-shop-zones -f bicep/main.bicep -p sshPublicKey="$(cat ~/.ssh/id_ed25519.pub)"
```

It runs 3 VMs and a load balancer, so it costs money while it exists. Delete the resource group when you're done.

## Zones vs regions

- **Zones** protect you from a building failing. Most PaaS services have a zone-redundant option too (ZRS storage,
  zone-redundant App Service plans, SQL Database zone redundancy).
- **A second region** protects you from the whole region failing. That's a disaster recovery design: data
  replication, failover and a tested runbook.

A zone for a building, a region for a disaster.

## Sources

- Microsoft: What are availability zones? https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview
- Microsoft: Use availability zones with Virtual Machine Scale Sets: https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones
- Microsoft: Load Balancer and availability zones: https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-availability-zones
