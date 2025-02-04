<########################################################################################

Name		:	Slipstream-Office2003Updates
Date		:	January 11th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   For a new Office 2003 installation package, it was convenient to slipstream updates
                in the package instead of having to patch the systems afterwards.

                This script will slipstream patches (.msp) into the package (.msi) using msiexec.
                
                With another script, the .msp patch files have already been extracted from the original .exe files.

Assumptions	:	
                

Known issues:	

Limitations	:	

Notes   	:   


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 11 2013	:	Created script
 
########################################################################################>

#Define variables
$updatesextractionpath = "C:\Temp\OfficeUpdates\Extracted"
$extensionfilter = ".msp"
$filetopatch = "\\corp.bjornhouben.com\DFSroot\SoftwareDeployment\Office2003wSP3\PRO11.MSI"

#Define the function to slipstream updates called slipstreamupdates
Function slipstreamupdates
{
    #Test if directories are available AND reachable
    IF(((test-path $filetopatch) -eq "True") -and ((test-path $updatesextractionpath) -eq "True"))
    {
        #Provide feedback in the CLI
        write-host "Required directories are present."
        write-host "Required: $updatespath"
        write-host "Required: $updatesextractionpath"

        #Get the updates in the updatesextractionpath
        $updates = @(Get-ChildItem -path $updatesextractionpath -recurse | where{$_.extension -eq $extensionfilter})
        
        #Count the number of updates in the updatesextractionpath
        $updatescount = $updates.count
        
        #If there are patches in the updatesextractionpath, install them
        IF($updatescount -ge 1)
        {
            Foreach($update in $updates)
            {
                #Get current date and time
                $date = get-date
                
                #Get the full path of the update name
                $UpdateName = $Update.FullName
                
                #Write progress information in the CLI.
                #By example: 11/01/2013 14:52:41 : Started slipstreaming C:\Temp\OfficeUpdates\Extracted\office2003-KB2288613-FullFile-NLD.exe\USP10.msp
                write-host "$date : Started slipstreaming $UpdateName"       
               
                #Start slipstreaming each MSP one at a time (utilizing wait).
                #http://blogs.msdn.com/b/heaths/archive/2005/11/15/493236.aspx  
                invoke-expression "cmd.exe /c start /wait msiexec.exe /p $UpdateName /a $filetopatch SHORTFILENAMES=TRUE /qb"
            }
         }
         #If there aren't any patches in the updatesextractionpath, provide feedback in the CLI.
         ELSE
         {
                write-host "No $extensionfilter update files are present in $updatespath." -backgroundcolor "Red"
         }
    }
    #If directories are NOT available and/or are not reachable, provide feedback in the CLI.
    ELSE
    {
        write-host "Not all required directories are present / reachable. Please check the configuration." -backgroundcolor "Red"
        write-host "Required: $updatesextractionpath"
        write-host "Required: $filetopatch"       
    }
}

#Run the function slipstreamupdates
slipstreamupdates