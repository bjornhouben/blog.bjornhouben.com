<########################################################################################

Name		:	Extract-Office2003Updates
Date		:	January 10th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   For a new Office 2003 installation package, it was convenient to slipstream updates
                in the package instead of having to patch the systems afterwards.

                This script will extract all .exe based updates so you don't have to do this manually
                for all the available updates.

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

History     :	Januari 10 2013	:	Created script
 
########################################################################################>

#Define the variables
$updatespath = "C:\Temp\OfficeUpdates"
$updatesextractionpath = "C:\Temp\OfficeUpdates\Extracted"
$extensionfilter = ".exe"

#Define the function
Function extractupdates
{
    IF(((test-path $updatespath) -eq "True") -and ((test-path $updatesextractionpath) -eq "True")) #If required paths are present, proceed
    {
        #Write output to host to show status
        write-host "Required directories are present."
        write-host "Required: $updatespath"
        write-host "Required: $updatesextractionpath"

        #Get the updates in the updatespath
        $updates = @(Get-ChildItem -path $updatespath | where{$_.extension -eq $extensionfilter})

        #Determine the number of updates in the $updatespath
        $updatescount = $updates.count

        IF($updatescount -ge 1) #If there are updates to extract, extract them
        {
            Foreach($update in $updates) #Extract each update
            {
                $UpdateName = $Update.name
                invoke-expression "C:\Windows\System32\cmd.exe /c $UpdateName /Q /C /T:$updatesextractionpath/$updateName"
            }
         }
         ELSE #If there are no updates to extract, no processing is necessary. Write output to host to show status
         {
                write-host "No $extensionfilter update files are present in $updatespath." -backgroundcolor "Red"
         }
    }
    ELSE #If required paths aren't present, offer to create path and offer to re-run the function
    {
        #Write output to host to show status
        write-host "Not all required directories are present. Please check the configuration." -backgroundcolor "Red"
        write-host "Required: $updatespath"
        write-host "Required: $updatesextractionpath"
        
        #Offer to create the necessary directories, requires confirmation
        write-host "If you want to create these directories, confirm the request."
        new-item -type directory -path $updatespath -confirm
        new-item -type directory -path $updatesextractionpath -confirm
        
        #Offer to re-run the function, requires confirmation
        write-host "If you want to retry running the extraction, confirm the request."
        extractupdates -confirm
    }
}

#Run the function
extractupdates