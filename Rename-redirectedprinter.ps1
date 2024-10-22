<########################################################################################

Name		:	Rename-redirectedprinter
Date		:	February 18th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Script to rename a redirected printer and set it as default.
                Some older programs require a specific (short) printer name and will not work otherwise.
                By example SAPlpd that may only consist of x characters, no spaces, etc.
                
                With Remote Desktop Services in Server 2008 R2 however, a redirected printer will show as
                "<printername> (redirected <session ID>)" by example "Lexmark X1100 series (Redirected 2)".

Assumptions	:   Only a single printer can match the $printercommentfilter.

Known issues:	

Limitations	:	

Notes   	:   -Renaming redirected printers is not supported by Microsoft.
                -The new printer name needs to be set as default printer before the printer was renamed to this, otherwise it will not add the icon that designates the printer as default.

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	February 18 2013	: Created script
 
########################################################################################>

#Delete registry value
Remove-Item -Path 'hkcu:\Software\Microsoft\Windows NT\CurrentVersion\Windows\SessionDefaultDevices' -Recurse

#Specify the new printer name.
$newprintername = "Clientprinter_" + $env:USERNAME

#$reg path and reg key to query and set later on.
$regpath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows"
$name = "Device"

#Get current value of the reg key.
$device = get-itemproperty $regpath -name $name
$devicevalue = $device.device

#Split the $devicevalue at the "," character and store it in an array.
$splitdevicevalues = @($devicevalue.split(","))

IF($splitdevicevalues[0] -ne $newprintername) #If desired default printer is not default yet
{
    #Combine data to make up the new device value
    $newdevicevalue = $newprintername+","+$splitdevicevalues[1]+","+$splitdevicevalues[2]

    #Set the new printername as the default printer by modifying the the registry.
    set-itemproperty -path $regpath -name $name -value $newdevicevalue

}

#Get the printer that matches a specific comment and rename the printer. 
#In our case, this is just a single printer. If there are more printers, the script might have to be rewritten.
$printercommentfilter = "Auto Created Client Printer"
$printer = Get-WmiObject win32_printer | where{$_.comment -match $printercommentfilter}
$printer.renameprinter($newprintername)