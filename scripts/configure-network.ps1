#------------------------------------------------------------------------------------------------------------------
# Sample Calls
#------------------------------------------------------------------------------------------------------------------
# powershell -Command ".\network.ps1 -ip '192.168.3.253' -px 22 -gw '192.168.3.1' -ns ('1.1.1.1','8.8.8.8') -wg 'SEAN' -dm 'sean.local'"
# invoke-expression 'cmd /c start powershell -Command network.ps1 -ip "10.10.1.11" -px 22 -gw "10.10.0.2" -ns "192.168.3.11","192.168.3.12" -l 10'

param (
  [Alias('cn')] [String]   $ComputerName,
  [Alias('ip')] [String]   $IPAddress,
  [Alias('px')] [Int]      $NetworkPrefix,
  [Alias('gw')] [String]   $Gateway,
  [Alias('ns')] [String[]] $DnsServers,
  [Alias('wg')] [String]   $WorkGroupName,
  [Alias('dn')] [String]   $DNSDomainName,

  [Alias('ac')] [Switch]   $AddCurrentIPs,
  [Alias('rd')] [Switch]   $RemoveDynamicIPs,
  [Alias('ep')] [Switch]   $EnableICMP,
  [Alias('pr')] [Switch]   $SetInterfaceToPrivate,

  [Alias('w')]  [Int]      $Delay,
  [Alias('r')]  [Switch]   $Reboot
)

#------------------------------------------------------------------------------------------------------------------
# Environment Setup
#------------------------------------------------------------------------------------------------------------------

$publicInterfaceIndex = Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Select-Object -ExpandProperty 'InterfaceIndex'

$currentIPAddresses = Get-NetIPAddress -InterfaceIndex $publicInterfaceIndex -AddressFamily IPv4

$currentPrefixLength = Get-NetIPAddress -InterfaceIndex $publicInterfaceIndex -AddressFamily IPv4 |
  Select-Object -First 1 -ExpandProperty 'PrefixLength'

$currentGateway = Get-NetIPConfiguration -InterfaceIndex $publicInterfaceIndex |
  Select-Object -First 1 -ExpandProperty 'IPv4DefaultGateway' |
    Select-Object -ExpandProperty 'NextHop'

$currentDnsServers = Get-DnsClientServerAddress -InterfaceIndex $publicInterfaceIndex -AddressFamily IPv4 |
  Select-Object -ExpandProperty 'ServerAddresses'

#------------------------------------------------------------------------------------------------------------------
# Delay Execution to allow other processes to complete
#------------------------------------------------------------------------------------------------------------------

if ( $Delay ) { Start-Sleep -Seconds $Delay }

#------------------------------------------------------------------------------------------------------------------
# Process any Script options that were passed
#------------------------------------------------------------------------------------------------------------------

#---------------------------------------
# Update the IP
#---------------------------------------
if ( $IPaddress )
{
  if ( -not $PrefixLength ) { $PrefixLength = $currentPrefixLength }
  if ( -not $DnsServers   ) { $DnsServers = $currentDnsServers }
  if ( -not $Gateway      ) { $Gateway = $currentGateway }

  New-NetIPAddress -InterfaceIndex $publicInterfaceIndex -IPAddress $IPaddress -PrefixLength $PrefixLength -DefaultGateway $Gateway
  Set-DnsClientServerAddress -InterfaceIndex $publicInterfaceIndex -ServerAddresses $DnsServers

  if ( $AddCurrentIPs )
  {
    $params = @{
      InterfaceIndex    = $publicInterfaceIndex
      ValidLifetime     = $(New-TimeSpan -Minutes 30)
      PreferredLifetime = $(New-TimeSpan -Minutes 30)
      SkipAsSource      = $true
    }
    $currentIPAddresses | ForEach-Object {
      New-NetIPAddress @params -IPAddress $_.IPAddress -PrefixLength $_.PrefixLength
    }
  }

}

#---------------------------------------
# Change from DHCP to a Static IP
#---------------------------------------
if ( $RemoveDynamicIPs )
{
  Get-NetIPAddress -InterfaceIndex $publicInterfaceIndex -AddressFamily IPv4 |
    Where-Object { $_.SkipAsSource -eq $true -and $_.ValidLifetime.TicksPerMinute -le 30 } |
      Select-Object -ExpandProperty "IPAddress" |
        ForEach-Object { Remove-NetIPAddress -IPAddress $_ -Confirm:$False }
}

#---------------------------------------
# Enable Ping
#---------------------------------------
if ( $EnableICMP )
{
  if ( -not (Get-NetFirewallRule -Description 'ICMP Allow incoming V4 echo request' 2> $null) )
  {
    netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol="icmpv4:8,any" dir=in action=allow
  }
  if ( -not (Get-NetFirewallRule -Description 'ICMP Allow incoming V6 echo request' 2> $null) )
  {
    netsh advfirewall firewall add rule name="ICMP Allow incoming V6 echo request" protocol="icmpv6:8,any" dir=in action=allow
  }
}

#---------------------------------------
# Set the Network Interface to Private
#---------------------------------------
if ( $SetInterfaceToPrivate )
{
  # Sleep to allow the network to identify in case the IP was changed
  Start-Sleep -Seconds 7
  Set-NetConnectionProfile -InterfaceIndex $publicInterfaceIndex -NetworkCategory Private
}

#---------------------------------------
# Set DNS domain name
#---------------------------------------
if ( $DNSDomainName )
{
  Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -Name 'Domain' -Value $DNSDomainName
}

#---------------------------------------
# Set the Workgroup
#---------------------------------------
if ( $WorkGroupName )
{
  Add-Computer -WorkGroupName $WorkGroupName
}

#---------------------------------------
# Change the Computer Name
#---------------------------------------
if ( $ComputerName )
{
  Rename-Computer -NewName $ComputerName
}

#---------------------------------------
# Reboot
#---------------------------------------
if ( $Reboot )
{
  Start-Sleep -Seconds 7
  Restart-Computer -Force
}
