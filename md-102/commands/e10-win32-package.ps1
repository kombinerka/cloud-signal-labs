# .SYNOPSIS
#     MD-102 Episode 10: pack Pinecone's label tool into a .intunewin file for a Win32 app.
#
# .DESCRIPTION
#     What it does: runs the Microsoft Win32 Content Prep Tool (IntuneWinAppUtil.exe) exactly as in the episode.
#       -c  the setup folder (everything in it is compressed into the .intunewin file)
#       -s  the setup file inside that folder
#       -o  the output folder (created if it doesn't exist)
#       -q  quiet mode (optional; not used in the episode)
#     Keep the tool itself outside the setup folder, or it ends up inside the package.
#     Download the tool from Microsoft (Learn links it as https://go.microsoft.com/fwlink/?linkid=2065730).
#
#     Then, in the Intune admin center: Apps › All apps › Create › Windows app (Win32) › upload setup.intunewin.
#       Program page (example values from the episode; the installer must run silently):
#         Install command:   setup.exe /quiet
#         Uninstall command: setup.exe /uninstall
#       Requirements: architecture + minimum Windows version.
#       Detection rules: at least one (MSI product code, file, registry, or a custom script such as
#         e10-win32-detection-label-tool.ps1).
#       Assignments: Required = shop laptops group.
#
#     Role (least privilege): Application Manager (built-in Intune role) to add and assign apps.
#     No Microsoft Graph scopes: this runs locally on a packaging PC.
#
#     Validated against Microsoft Learn ("Prepare a Win32 app to be uploaded", "Add and assign Win32 apps");
#     not run against a tenant. The setup.exe switches are the episode's illustrative values: use your installer's
#     own silent switches.
#
# .EXAMPLE
#     .\e10-win32-package.ps1
[CmdletBinding()]
param()

# Pack the whole .\label folder; setup.exe is the installer; write the package to .\out
IntuneWinAppUtil -c .\label -s .\label\setup.exe -o .\out

# Check the result: expect setup.intunewin
Get-ChildItem .\out -Name
