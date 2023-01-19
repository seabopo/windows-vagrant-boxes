
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Update the Package management module so -Confim works correctly and installs execute silently
$packageManagement = Get-Module -Name PackageManagement -ListAvailable | Select-Object Name,Version
if ( $packageManagement.Version -eq '1.0.0.1' )
{
    Write-Output "Updating package management module ..."
    Install-Package -Name PackageManagement -MinimumVersion 1.4.7 -Force -Confirm:$false -Source PSGallery
}
