#Specify desired DNS forwarders for public DNS resolving#In this example, public google DNS servers are used.$desireddnsforwarder1 = "8.8.8.8" $desireddnsforwarder2 = "8.8.4.4"#Gather information needed to create the reverse lookup zone.#Assumed is that the network adapter only contains one IP.$IPaddress = @((Get-NetAdapter | where status -eq "up" | Get-NetIPAddress -ea 0).IPv4Address)[1]$IPAddresssplit = $IPAddress.split(".")$IPaddressreverse = $IPAddresssplit[2] + "." + $IPAddresssplit[1] + "." + $IPAddresssplit[0]$suffix1 = ".in-addr.arpa"$reversezonename = $IPAddressreverse + $suffix1$suffix2 = ".in-addr.arpa.dns"$reversezonefile = $IPAddressreverse + $suffix2#Create a reverse lookup zoneAdd-DnsServerPrimaryZone -name $reversezonename -ZoneFile $reversezonefile#Get the FQDN$fqdn = [System.Net.Dns]::GetHostByName(($env:computerName)).Hostname

#Add a PTR record for this computer to the reverse lookup zone.  
Add-DnsServerResourceRecordPtr -ZoneName $reversezonename -Name $IPAddresssplit[3] -PtrDomainName $fqdn#Configure DNS forwardersAdd-DnsServerForwarder -IPAddress $desireddnsforwarder1Add-DnsServerForwarder -IPAddress $desireddnsforwarder2#Enable the Active Directory Recycle Bin
#Requires ForestMode of Windows 2008 R2 or higher

#Get the current AD Forest
$ADForest = Get-ADForest

#Get the name of the forest
$Target = $ADForest.name

#Split the name of the forest for later use
$parts = @($Target.split("."))

#Set the start identity that is necessary to enable the AD Recycle Bin
$identity = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration"

#Add each part of the AD forest name to the identity in a way that it can be used to enable the AD Recycle Bin
Foreach($part in $parts)
{
    $identity = $identity + ",DC=" + $part
}

#Enable the AD Recycle Bin Feature if it has not been enabled already.
#Beware, this is an irreversible action.

IF((Get-ADOptionalFeature -identity $identity | where {$_.name -eq "Recycle Bin Feature"}) -eq $NULL)
{
    Enable-ADOptionalFeature –Identity $identity –Scope ForestOrConfigurationSet –Target $target -Confirm:$False
}