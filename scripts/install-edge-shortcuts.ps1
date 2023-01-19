#==================================================================================================================
# Install Microsoft Edge Shortcuts
#==================================================================================================================

param (
  [Alias('c')] [Switch] $Consul,
  [Alias('n')] [Switch] $Nomad,
  [Alias('t')] [Switch] $Traefik,
  [Alias('a')] [Switch] $TestApp,
  [Alias('1')] [Switch] $TestApp1,
  [Alias('2')] [Switch] $TestApp2,
  [Alias('3')] [Switch] $TestApp3,
  [Alias('s')] [String] $ShortcutName = 'HashiStack'
)

#==================================================================================================================
#==================================================================================================================
# MAIN
#==================================================================================================================
#==================================================================================================================

Write-Host ( "Adding desktop MS Edge shortcut ..." )

$service_url   = ""
$desktop_path  = $([Environment]::GetFolderPath("CommonDesktopDirectory"))
$shortcut_path = Join-Path -Path $desktop_path -ChildPath $( "\\{0}.lnk" -f $ShortcutName )

if ( $Consul   ) { $service_url += "http://localhost:8500/ " }
if ( $Nomad    ) { $service_url += "http://localhost:4646/ " }
if ( $Traefik  ) { $service_url += "http://localhost:8081/ " }
if ( $TestApp  ) { $service_url += "http://app.local/ "      }
if ( $TestApp1 ) { $service_url += "http://app1.local/ "     }
if ( $TestApp2 ) { $service_url += "http://app2.local/ "     }
if ( $TestApp3 ) { $service_url += "http://app3.local/ "     }

if ( Test-Path($shortcut_path) ) { Remove-Item $shortcut_path -Force }

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcut_path)
$shortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Shortcut.Arguments = $service_url
$shortcut.Save()
