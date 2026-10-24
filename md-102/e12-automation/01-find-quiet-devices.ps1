<#
.SYNOPSIS
    MD-102 Episode 12: list Intune-managed devices that have not synced for N days, export them to CSV,
    and (optionally) send them a sync.

.DESCRIPTION
    Uses the Microsoft Graph PowerShell SDK (v1.0 module), as documented on Microsoft Learn:
      - Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
      - Connect-MgGraph -Scopes ...            (delegated access: you sign in as yourself)
      - Get-MgDeviceManagementManagedDevice    (least privileged scope: DeviceManagementManagedDevices.Read.All)
      - Sync-MgDeviceManagementManagedDevice   (scope: DeviceManagementManagedDevices.PrivilegedOperations.All)
    The Microsoft Graph API for Intune requires an active Intune license for the tenant.

    Pinecone is a fictional example company. Run this against a test tenant first.

.EXAMPLE
    ./01-find-quiet-devices.ps1                       # report only (read scope)
    ./01-find-quiet-devices.ps1 -Days 30 -Sync -WhatIf  # show which devices would get a sync
    ./01-find-quiet-devices.ps1 -Sync                 # send a sync to every quiet device
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [int]$Days = 14,
    [string]$CsvPath = "./quiet-devices.csv",
    [switch]$Sync
)

Import-Module Microsoft.Graph.DeviceManagement

# Ask only for the scopes this run needs (least privilege).
$scopes = @("DeviceManagementManagedDevices.Read.All")
if ($Sync) { $scopes += "DeviceManagementManagedDevices.PrivilegedOperations.All" }
Connect-MgGraph -Scopes $scopes

# Every managed device (-All follows all pages); only the properties we use.
$devices = Get-MgDeviceManagementManagedDevice -All `
    -Property "id,deviceName,operatingSystem,complianceState,lastSyncDateTime,userPrincipalName"

$cutoff = (Get-Date).ToUniversalTime().AddDays(-$Days)
$quiet = $devices | Where-Object { $_.LastSyncDateTime -lt $cutoff } |
    Sort-Object LastSyncDateTime |
    Select-Object DeviceName, OperatingSystem, ComplianceState, LastSyncDateTime, UserPrincipalName, Id

Write-Host ("{0} of {1} devices have not synced for {2} days." -f @($quiet).Count, @($devices).Count, $Days)
$quiet | Export-Csv -Path $CsvPath -NoTypeInformation
Write-Host "Saved to $CsvPath"

if ($Sync) {
    foreach ($d in $quiet) {
        if ($PSCmdlet.ShouldProcess($d.DeviceName, "Sync device")) {
            Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $d.Id
        }
    }
}

Disconnect-MgGraph | Out-Null
