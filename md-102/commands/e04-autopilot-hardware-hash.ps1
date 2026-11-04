# .SYNOPSIS
#     MD-102 Episode 4: capture a Windows device's hardware hash for classic Windows Autopilot registration.
#
# .DESCRIPTION
#     What it does: the episode says IT can register devices "with a CSV file" when the manufacturer, reseller or
#     distributor didn't. These are the commands Microsoft Learn gives for that ("Manually register devices with
#     Windows Autopilot"), using the Get-WindowsAutopilotInfo script from the PowerShell Gallery.
#
#       Option A (default): save the hash to C:\HWID\AutopilotHWID.csv, then import it in the
#         Intune admin center: Devices › Windows › Device onboarding › Enrollment › Windows Autopilot › Devices
#         › Import › Sync. Up to 500 devices per CSV. Edit the CSV in a plain-text editor, not Excel.
#         Header: Device Serial Number,Windows Product ID,Hardware Hash,Group Tag,Assigned User
#       Option B (-Online): upload the hash straight to Intune.
#
#     Run on the device itself, in an elevated Windows PowerShell 5.1 prompt.
#
#     Roles (least privilege): importing devices needs Intune Administrator or Policy and Profile Manager, or a
#     custom Intune role with the Enrollment programs permissions (Learn). For -Online, Learn says to sign in with
#     "an account that is at least an Intune Administrator"; on first run the script asks to approve the app
#     registration permissions it needs (Microsoft Graph PowerShell).
#
#     Validated against Microsoft Learn; not run against a tenant.
#     Source: https://learn.microsoft.com/en-us/autopilot/add-devices
#
# .EXAMPLE
#     .\e04-autopilot-hardware-hash.ps1            # write C:\HWID\AutopilotHWID.csv
#     .\e04-autopilot-hardware-hash.ps1 -Online    # upload directly (Intune Administrator sign-in)
[CmdletBinding()]
param(
    [switch]$Online
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

if ($Online) {
    Install-Script -Name Get-WindowsAutopilotInfo -Force
    Get-WindowsAutopilotInfo -Online
}
else {
    New-Item -Type Directory -Path "C:\HWID" -Force | Out-Null
    Set-Location -Path "C:\HWID"
    $env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
    Install-Script -Name Get-WindowsAutopilotInfo
    Get-WindowsAutopilotInfo -OutputFile AutopilotHWID.csv
}
