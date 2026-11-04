# .SYNOPSIS
#     MD-102 Episode 10: custom detection script for the label tool Win32 app.
#
# .DESCRIPTION
#     What it does: tells Intune whether the app is installed. Upload it on the Win32 app's Detection rules page
#     (Rules format: Use a custom detection script).
#     How Intune reads it (Learn, "Add and assign Win32 apps"):
#       - exit code 0 AND something written to STDOUT  = installed
#       - nonzero exit code, or no STDOUT              = not installed
#       - anything written to STDERR                   = not installed, even with exit 0 and STDOUT
#     Learn recommends saving the script as UTF-8 with BOM.
#
#     The episode teaches the four detection rule types (MSI product code, file, registry, custom script); a simple
#     file rule in the portal does the same job as this script. The path below is illustrative (Pinecone is a
#     fictional company; label.exe is the file named in the episode's portal panel).
#
#     Role (least privilege): Application Manager (built-in Intune role) to edit the app.
#     Runs on the device as part of the Intune Management Extension; no Graph scopes.
#
#     Validated against Microsoft Learn; not run against a tenant.

$path = Join-Path $env:ProgramFiles 'Pinecone\LabelTool\label.exe'

if (Test-Path -Path $path) {
    Write-Output "Label tool found: $path"
    exit 0
}

# Not found: no STDOUT, nonzero exit code
exit 1
