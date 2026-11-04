# Validation (2026-10-30)

File: `check-hr-site.ps1`.

- Not run against any tenant, and **not syntax-checked**: PowerShell isn't installed in the build container and
  downloading it was not permitted. Run `pwsh -NoProfile -Command "[System.Management.Automation.Language.Parser]::ParseFile('check-hr-site.ps1',[ref]$null,[ref]$null)"`
  locally before publishing the file to the repo.
- Cmdlets and parameters are copied from Microsoft Learn (30 Oct 2026):
  `Set-SPOSite -RestrictContentOrgWideSearch`, `Get-SPOSite | Select RestrictContentOrgWideSearch`
  (Restrict discovery of SharePoint sites and content); `Set-SPOTenant -EnableRestrictedAccessControl`,
  `Set-SPOSite -RestrictedAccessControl`, `-AddRestrictedAccessControlGroups <comma separated group GUIDS>`
  (Restricted access control). The `-join ','` builds that comma-separated string; check the parameter type with
  `Get-Help Set-SPOSite -Parameter AddRestrictedAccessControlGroups` before relying on it.
- Everything else in the video (sharing defaults, data access governance reports, site access reviews, sensitivity
  labels, the DLP policy) is set in the admin centers, not in this file.
