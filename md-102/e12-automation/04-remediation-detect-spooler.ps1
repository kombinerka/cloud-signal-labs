# MD-102 Episode 12: Remediations detection script (Pinecone example: the print spooler on shop PCs).
#
# Add it in the Microsoft Intune admin center under Devices > Manage devices > Scripts and remediations > Create,
# together with 05-remediation-fix-spooler.ps1. Save both as UTF-8.
# Rule from Microsoft Learn: the remediation script only runs when the detection script exits with code 1
# ("issue detected"). Any other exit code, or empty output, means no issue was found.
# Output shown in the report is limited to 2,048 characters. Don't put reboot commands or personal data in scripts.

$service = Get-Service -Name "Spooler" -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "Spooler service not found"
    exit 0   # nothing to fix on this device
}

if ($service.Status -ne "Running") {
    Write-Output "Spooler is $($service.Status)"
    exit 1   # issue found: Intune runs the remediation script
}

Write-Output "Spooler is running"
exit 0
