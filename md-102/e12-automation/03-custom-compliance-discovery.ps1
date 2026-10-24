# MD-102 Episode 12: custom compliance discovery script (Windows) for Pinecone's shop kiosks.
#
# Upload it in the Microsoft Intune admin center under Endpoint security > Device compliance > Scripts > Add > Windows,
# then select it in a Windows compliance policy (Custom compliance) together with 03-custom-compliance-rules.json.
# Based on the sample in the Microsoft Learn article "Create discovery scripts for custom compliance policy":
# the script returns the discovered values as ONE line of JSON (ConvertTo-Json -Compress), and the setting names
# must match the SettingName values in the JSON rules file (case-sensitive).
# Intune doesn't validate the script, so test it locally first:  powershell -File .\03-custom-compliance-discovery.ps1

$WMI_ComputerSystem = Get-WMIObject -class Win32_ComputerSystem
$WMI_BIOS = Get-WMIObject -class Win32_BIOS
$TPM = Get-Tpm

$hash = @{ Manufacturer = $WMI_ComputerSystem.Manufacturer; BiosVersion = $WMI_BIOS.SMBIOSBIOSVersion; TPMChipPresent = $TPM.TPMPresent}
return $hash | ConvertTo-Json -Compress
