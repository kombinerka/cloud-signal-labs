# Validation (2026-10-30, syntax check 2026-11-04)

File: `check-hr-site.ps1`.

- Not run against any tenant (the SharePoint Online Management Shell is Windows-only and needs a tenant).
- Syntax-checked 4 Nov 2026 with PowerShell 7.4.6 on Linux:
  `[System.Management.Automation.Language.Parser]::ParseFile('check-hr-site.ps1',[ref]$t,[ref]$e)` → 0 parse errors.
  This checks syntax only, not that the SPO cmdlets accept these values.
- Cmdlets and parameters are copied from Microsoft Learn (30 Oct 2026):
  `Set-SPOSite -RestrictContentOrgWideSearch`, `Get-SPOSite | Select RestrictContentOrgWideSearch`
  (Restrict discovery of SharePoint sites and content); `Set-SPOTenant -EnableRestrictedAccessControl`,
  `Set-SPOSite -RestrictedAccessControl`, `-AddRestrictedAccessControlGroups <comma separated group GUIDS>`
  (Restricted access control). The `-join ','` builds that comma-separated string; check the parameter type with
  `Get-Help Set-SPOSite -Parameter AddRestrictedAccessControlGroups` before relying on it.
- Everything else in the video (sharing defaults, data access governance reports, site access reviews, sensitivity
  labels, the DLP policy) is set in the admin centers, not in this file.
