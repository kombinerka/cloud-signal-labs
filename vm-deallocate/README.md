# Stopped is not deallocated

▶ **[Watch the video](https://www.youtube.com/watch?v=-hLfODys7k8)**

Companion code for the Cloud Signal Short **"Your Azure VM Is Off. Why Are You Still Paying?"**.

| How the VM was stopped | State in Azure | Compute billed? |
|---|---|---|
| Shut down from inside the OS | Stopped | **yes**, the hardware is still reserved |
| Stopped from Azure (portal, CLI, PowerShell, auto-shutdown) | Stopped (deallocated) | no |

Still billed either way: managed disks (your data is stored) and static public IPs. A dynamic public IP can change
when a deallocated VM starts again.

## Find and fix

```bash
./find-stopped-not-deallocated.sh               # read-only list, all subscriptions you can see
./find-stopped-not-deallocated.sh --deallocate  # asks per VM
az vm deallocate -g rg-dev -n vm-test-01        # one VM
az vm get-instance-view -g rg-dev -n vm-test-01 --query "instanceView.statuses[?starts_with(code,'PowerState')].displayStatus" -o tsv
```

## Prevent it: auto-shutdown

| | File |
|---|---|
| Terraform | [`terraform/auto-shutdown.tf`](terraform/auto-shutdown.tf) |
| Bicep | [`bicep/auto-shutdown.bicep`](bicep/auto-shutdown.bicep) |

Auto-shutdown stops the VM from Azure, so it is deallocated every evening. Start it again when you need it
(`az vm start`).

## Sources

- Microsoft: States and billing status of Azure Virtual Machines: https://learn.microsoft.com/en-us/azure/virtual-machines/states-billing
- Microsoft: Auto-shutdown a VM: https://learn.microsoft.com/en-us/azure/virtual-machines/auto-shutdown-vm
