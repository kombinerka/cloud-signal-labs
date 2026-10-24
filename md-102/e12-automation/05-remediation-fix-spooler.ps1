# MD-102 Episode 12: Remediations remediation script (pairs with 04-remediation-detect-spooler.ps1).
#
# Runs only after the detection script exited with code 1. Run it in the system context
# ("Run this script using the logged-on credentials" = No), because starting a service needs admin rights.

try {
    Start-Service -Name "Spooler" -ErrorAction Stop
    Write-Output "Spooler started"
    exit 0
}
catch {
    Write-Output "Could not start Spooler: $($_.Exception.Message)"
    exit 1
}
