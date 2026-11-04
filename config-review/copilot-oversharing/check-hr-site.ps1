# Pinecone: check and contain the "All company HR" site before the Copilot pilot.
# Every cmdlet and parameter below is copied from Microsoft Learn (see SOURCES.md).
# Requires the SharePoint Online Management Shell, a SharePoint Administrator, and
# SharePoint Advanced Management (one Microsoft Copilot license assigned in the tenant).
# NOT RUN against a tenant. Not syntax-checked (no PowerShell in the build container).
param(
  [Parameter(Mandatory)] [string] $SiteUrl,          # e.g. https://<tenant>.sharepoint.com/sites/<hr-site>
  [string[]] $HrGroupIds = @()                         # Entra security group / Microsoft 365 group IDs (max 10)
)

# Setting 4: Restricted content discovery (temporary, during the access review)
Set-SPOSite -Identity $SiteUrl -RestrictContentOrgWideSearch $true
Get-SPOSite -Identity $SiteUrl | Select RestrictContentOrgWideSearch

# Setting 5: Restricted access control (tenant switch once, then the site)
# Set-SPOTenant -EnableRestrictedAccessControl $true   # can take up to one hour
if ($HrGroupIds.Count -gt 0) {
  Set-SPOSite -Identity $SiteUrl -RestrictedAccessControl $true
  Set-SPOSite -Identity $SiteUrl -AddRestrictedAccessControlGroups ($HrGroupIds -join ',')
}

# After the review is complete and permissions are fixed, lift the stopgap:
# Set-SPOSite -Identity $SiteUrl -RestrictContentOrgWideSearch $false
