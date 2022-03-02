# Write the localhost name back for further processing
$hostname=[System.Net.Dns]::GetHostByName($null).HostName
$ip_addresses =  $([System.Net.Dns]::GetHostAddresses($hostname) | where {$_.AddressFamily -notlike "InterNetworkV6"} | where {$_.IPAddressToString -notlike "127.0.0.1"} | foreach {echo $_.IPAddressToString })
$ip_address = $ip_addresses[0]
# HACK: For localhost, using IP address to avoid issues in Docker resolving the hostname from inside the container
$hostname = $ip_address;
Write-Output "{ ""hostname"": ""$hostname"" }"