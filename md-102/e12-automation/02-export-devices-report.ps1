<#
.SYNOPSIS
    MD-102 Episode 12: export the Intune "Devices" report with the Graph export jobs API.

.DESCRIPTION
    Follows the Microsoft Learn article "Use Graph APIs to export Intune reports":
      1. POST /deviceManagement/reports/exportJobs with a reportName and explicit select columns
         ("Don't build automation around default columns of any report export").
      2. Poll the job until status is "completed".
      3. Download the compressed file from the job's url (a time-limited link).
    Create uses Invoke-MgGraphRequest (Microsoft.Graph.Authentication); polling uses
    Get-MgDeviceManagementReportExportJob (Microsoft.Graph.Reports).
    Scope: DeviceManagementConfiguration.ReadWrite.All (least privileged scope listed for creating an export job).
    Export requests are throttled per tenant, per user and per app, so poll slowly.

.EXAMPLE
    ./02-export-devices-report.ps1 -OutFile ./devices-report.zip
#>
param(
    [string]$OutFile = "./devices-report.zip"
)

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Reports

Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All"

$body = @{
    reportName = "Devices"
    format     = "csv"
    select     = @("DeviceName", "ManagementAgents", "OwnerType", "CompliantState", "OS", "OSVersion", "LastContact", "UPN", "DeviceId")
} | ConvertTo-Json

$job = Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/deviceManagement/reports/exportJobs" `
    -Body $body -ContentType "application/json"
Write-Host "Export job $($job.id) created, status: $($job.status)"

do {
    Start-Sleep -Seconds 10
    $state = Get-MgDeviceManagementReportExportJob -DeviceManagementExportJobId $job.id
    Write-Host "Status: $($state.Status)"
} while ($state.Status -notin @("completed", "failed"))

if ($state.Status -eq "completed") {
    Invoke-WebRequest -Uri $state.Url -OutFile $OutFile
    Write-Host "Report saved to $OutFile (download it before $($state.ExpirationDateTime))"
}
else {
    Write-Warning "The export job failed."
}

Disconnect-MgGraph | Out-Null
