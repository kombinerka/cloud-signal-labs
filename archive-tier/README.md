# Archive: the cheapest backup you can't read tonight

▶ **[Watch the video](https://www.youtube.com/watch?v=JnHOszFuLVg)**

Companion code for the Cloud Signal Short **"Your Cheapest Backup Might Take 15 Hours to Restore"**.

The archive tier is the cheapest place in Blob Storage, and it's **offline**: an archived blob can't be read or
changed until you rehydrate it to hot, cool or cold.

| Rehydrate priority | Time | Cost |
|---|---|---|
| Standard | up to 15 hours | lower |
| High | often under 1 hour for blobs under 10 GB | higher |

Archive also expects data to stay **at least 180 days**; deleting or moving it out earlier costs an early-deletion
fee for the remaining days.

## Lifecycle policy (keep recent backups online, archive old ones)

| | File |
|---|---|
| Terraform | [`terraform/main.tf`](terraform/main.tf) (`azurerm_storage_management_policy`) |
| Bicep | [`bicep/main.bicep`](bicep/main.bicep) (`managementPolicies`) |

Hot → cool after 30 days → archive after 90 → delete after 400 (so every blob spends more than 180 days in
archive). Adjust the numbers to your restore needs: whatever you might need *tonight* should not be in archive.

## Getting a blob back

```bash
# in place: the blob changes tier
ACCOUNT=stbackup CONTAINER=backups BLOB=backups/db-2026-06-01.bak PRIORITY=High ./rehydrate.sh
# as a copy in an online tier (the archived original stays)
ACCOUNT=stbackup CONTAINER=backups BLOB=backups/db-2026-06-01.bak ./rehydrate.sh --copy
```

You can subscribe to the `Microsoft.Storage.BlobTierChanged` Event Grid event to get notified when a
rehydration finishes, instead of polling.

Archive is for data you can wait for. Not for the backup you need tonight.

## Sources

- Microsoft: Blob rehydration from the archive tier: https://learn.microsoft.com/en-us/azure/storage/blobs/archive-rehydrate-overview
- Microsoft: Access tiers for blob data: https://learn.microsoft.com/en-us/azure/storage/blobs/access-tiers-overview
- Microsoft: Lifecycle management policies: https://learn.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-overview
