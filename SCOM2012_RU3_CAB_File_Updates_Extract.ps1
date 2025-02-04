<########################################################################################

Name		:	SCOM 2012 Update Rollup Extract English Only MSP from CAB.ps1
Date		:	December 15th 2012
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Script to automate extracting (English only) MSP files from CAB files in the SCOM 2012 Update Rollup 3 (UR3) files
                that you can download here: http://catalog.update.microsoft.com/v7/site/search.aspx?q=2750631
                By default it will delete extracted non-English versions.

                With some minor modifications it can be used for any CAB file though, not just SCOM 2012 Update Rollup 3.

                The issue with Update Rollup 3 is that after downloading you'll end up with a total of 41 CAB files.
                The large number of files is because they are for different components and in multiple languages.
                And what is even worse, is that the file names do not show which file is for which language.
                
                This script will extract all cab files to a subfolder and will then removes the non English ones.
                Below is a list of the files in Update Rollup 3 to give you an idea about the nondescriptive file names.
                
                all-kb2750631-amd64-agent_d7cc8d1fa307f6bc9db3ced386f427864b3a3e5d.cab                                                                                                                            
                all-kb2750631-i386-agent_a2c8476c8b4352e4c38fc8116e4953046cb691d0.cab                                                                                                                             
                all-kb2750631-ia64-agent_da768ff179a4039c9e1be3246b081a1342f70274.cab                                                                                                                             
                all-kb2750631-amd64-console_1af57997fba722cdd3dfe4b2ddb4b8d8d829dd6f.cab                                                                                                                          
                all-kb2750631-amd64-console_3d61c9e090622b2b59ee8bf7b13b922e815bdf15.cab                                                                                                                          
                all-kb2750631-amd64-console_494a77ddaa09206f8f61ecdfb2edfcd1e82a497c.cab                                                                                                                          
                all-kb2750631-amd64-console_69bb307dbd450cfd8b732c2ac3845c9870bdc6d0.cab                                                                                                                          
                all-kb2750631-amd64-console_71c65fc2ded6769edbf610958780b5a8ac374f8c.cab                                                                                                                          
                all-kb2750631-amd64-console_755b85ba494fa5c83ca31cf40d38be5d6d0551ef.cab                                                                                                                          
                all-kb2750631-amd64-console_a250c97c67e183cc64cbb00f248ca8299359d4f6.cab                                                                                                                          
                all-kb2750631-amd64-console_bc4a7344fd9646fcf812a39c5856a17d48a17a8e.cab                                                                                                                          
                all-kb2750631-amd64-console_f6e74f2ce14508ccb2187f4e401cc59dd35e6472.cab                                                                                                                          
                all-kb2750631-i386-console_0ca296adb5dbba2abd1ba876a044a83a41515218.cab                                                                                                                           
                all-kb2750631-i386-console_1ec8e2c609b582afd41a72026edf4acee6eaf7cc.cab                                                                                                                           
                all-kb2750631-i386-console_3309108f044e9167ba30af934e537517fc6bbcfe.cab                                                                                                                           
                all-kb2750631-i386-console_71005c719c4a10a5bc6d8ac7da300a5851d95b0b.cab                                                                                                                           
                all-kb2750631-i386-console_74b1593272d3c45ca7a98b2a3e0d8dc2c3f795d6.cab                                                                                                                           
                all-kb2750631-i386-console_c4c79b505f62f9d11ff6f6d493eb9446907ce166.cab                                                                                                                           
                all-kb2750631-i386-console_e6ff88488ec21fcf047927381df57d5ecedaf972.cab                                                                                                                           
                all-kb2750631-i386-console_e92329147e752fffc7507af1aa781b0331960014.cab                                                                                                                           
                all-kb2750631-i386-console_ed7e3adb1905b631de20b08064a83574f2be3ec6.cab                                                                                                                           
                all-kb2750631-amd64-gateway_90206ca6ac69a5982a7eaa74e7eedf41f367ee7b.cab                                                                                                                          
                all-kb2750631-amd64-reporting_1c05f1c746f6f31f63f8c4eb6e96a5f2ccf6d5a9.cab                                                                                                                        
                all-kb2750631-amd64-reporting_2bf78b9b407a760eefe606304b8fae363985bd0f.cab                                                                                                                        
                all-kb2750631-amd64-reporting_55ebde7f29443506f4cb707ee4bccdeacc3eb8f9.cab                                                                                                                        
                all-kb2750631-amd64-reporting_6f602ee6d372371a55130e7fc9f776c9778291a3.cab                                                                                                                        
                all-kb2750631-amd64-reporting_7d5c0399abd43a9410720a720fc3147828765708.cab                                                                                                                        
                all-kb2750631-amd64-reporting_8043cc39d79514d1e633b645063100c136cf1f92.cab                                                                                                                        
                all-kb2750631-amd64-reporting_abbb2c9ac725826fd8f0c8fa641959abd375affc.cab                                                                                                                        
                all-kb2750631-amd64-reporting_d4bdb703b2141e534b19d2f0527dc94e79fc1551.cab                                                                                                                        
                all-kb2750631-amd64-reporting_ebb0938d500b796ccf2b1b7c11a1c9e8c53d40e3.cab                                                                                                                        
                all-kb2750631-amd64-server_44223b2a954b95837ebfbdcbcf8b742a56dbe123.cab                                                                                                                           
                all-kb2750631-amd64-webconsole_15c3cca938121992cb3c459775aac4767d7f7b0f.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_2ef77d6ea1080b83c10351001dc13bf7e6977b7a.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_48a02c6676468a18ccdda688458e71583d387bd1.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_5308b4a3fc905d5cf151ff1549bd122c954ed761.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_631dbf384853f6bfc8588b7654d7578344f793b6.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_a6e84a3dea13e173bceedcc4de44db540fe3a27b.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_c429892ad5e38436aea6671efa42d9da1713e058.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_f0c09ab928fcf18a61709344a96debba554e3a46.cab                                                                                                                       
                all-kb2750631-amd64-webconsole_f90f3d62a590d4d5f6705f39f633910b667c6dcf.cab                    

Assumptions	:	
                

Known issues:	

Limitations	:	

Notes   	:   Deploying SCOM 2012 components and updates to them can be done in multiple ways:
                http://technet.microsoft.com/en-us/library/hh551142.aspx
                
                Most of the work while updating will probably be updating the agents. Basically for SCOM 2012 there are 2 major ways to install agents:
                1. A push installation (initiated from SCOM 2012). Updates can then also be deployed from within SCOM (Remotely Manageable = Yes).
                   Push installation is often preferred, because it is easy and also allows you to push updates to clients from within SCOM 2012.
                   The downside however is that it also requires a lot of open ports (including RPC) which might not always be acceptable:
                   http://support.microsoft.com/kb/2566152. Push install and update install can also consume a lot of bandwidth and depending on your architecture (b.e. WAN links), 
                   the push install might not be the best way.
                2. A manual installation (anything that is not a push installation). Updates cannot be deployed from within SCOM (Remotely Manageable = No).
                   Manual installation includes running setup manually, using a GPO software install or using deployment tools like System Center Configuration Manager).
                   Using the GUI, you cannot simply set an agent back to remotely manageable = Yes. You can change this in SQL though, but keep in mind that connectivity
                   requirements still need to be met:
                   http://blogs.technet.com/b/kevinholman/archive/2010/02/20/how-to-get-your-agents-back-to-remotely-manageable-in-opsmgr-2007-r2.aspx

                With Update Rollup 3, it is even possible to leverage WSUS / Microsoft Update to deploy updates (not the inital agent) to all SCOM 2012 components.
                I predict this will probably become the preferred way of updating SCOM 2012 for most companies:
                + It does not require many ports on your firewall to be opened.
                + Better bandwidth management (local WSUS, BranchCache, BITS).
                + Auto detects components on systems (component updates are not forgotten).
                + Still in control of when which updates are deployed/approved.
                + Leverage existing patch management procedures and systems, including System Center Configuration Manager (standardization).
                - Initial agent installation cannot be performed using WSUS.

                PS: Also check these great blog posts:
                    http://blogs.technet.com/b/stefan_stranger/archive/2012/10/22/opsmgr-2012-update-rollup-3-ships-and-my-experience-installing-it.aspx
                    http://kevingreeneitblog.blogspot.nl/2012/10/scom-2012-deploying-cumulative-update.html

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	Perform check of files to keep before extracting. Then also no delete is necessary.

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	December 15 2012	:	Created script
 
########################################################################################>


#Define the variables.
$updatespath = "C:\Users\Bjorn\Desktop\SCOM 2012 UR3"
$extensionfilter = ".cab"
$filenamefilter = "*"
$updatesextractionpath = "C:\Temp\SCOM 2012 UR3\extracted"

Function extract-updates #Define the function
{
    IF(((test-path $updatespath) -eq "True") -and ((test-path $updatesextractionpath) -eq "True")) #If required directories are present, continue processing
    {
        #Write confirmation to host
        write-host "Required directories are present."
        write-host "Required: $updatespath"
        write-host "Required: $updatesextractionpath"

        #Get the update files in the specified updates path. Recurse / subfolders is enabled
        $updates = @(Get-ChildItem -path $updatespath -Recurse | where{$_.extension -eq $extensionfilter}) 

        #Determine the number of updates
        $updatescount = $updates.count
        
        IF($updatescount -ge 1) #If updates are found in the updates path continue processing.
        {
            
            Function expand-Cab($cab, $destination) #Define function to expand cab files
            {
                #Code for extracting CAB files : http://technet.microsoft.com/en-us/magazine/2009.04.heyscriptingguy.aspx?pr=blog
                $comObject = "Shell.Application"
                Write-Debug "Creating $comObject"
                $shell = New-Object -Comobject $comObject
                if(!$?) { $(Throw "unable to create $comObject object")}
                Write-Debug "Creating source cab object for $cab"
                $sourceCab = $shell.Namespace($cab).items()
                Write-Debug "Creating destination folder object for $destination"
                $DestinationFolder = $shell.Namespace($destination)
                Write-Debug "Expanding $cab to $destination"
                $DestinationFolder.CopyHere($sourceCab)
            }
            
            Foreach($update in $updates) #Extract each update into the specified extraction path in a subfolder with the patch name
            {
                #Get update information and store in variables
                $updatename = $update.basename
                $updatefullname = $update.fullname
                $updatedirectoryname = $update.directoryname
                $destinationpath = "$updatesextractionpath\$updatename"

                
                                
                IF((test-path $destinationpath) -ne "True") #Create subfolder in $updatesextractionpath with the updatename if it does not exist
                {
                    new-item -type directory -path $destinationpath #-confirm
                }

                #Run the function expand-cab to expand the cab files
                expand-cab $updatefullname $destinationpath
            }
         }
         ELSE #If no updates are found in the updates path stop processing.
         {
                write-host "No $extensionfilter update files are present in $updatespath." -backgroundcolor "Red"
         }
    }
    ELSE #If required directories are not present, write to host, create them automatically and re-run the function.
    {
        write-host "Not all required directories are present. Please check the configuration." -backgroundcolor "Red"
        write-host "Required: $updatespath"
        write-host "Required: $updatesextractionpath"
        
        write-host "If you want to create these directories, confirm the request."
        new-item -type directory -path $updatespath #-confirm
        new-item -type directory -path $updatesextractionpath #-confirm
        
        write-host "If you want to retry running the extraction, confirm the request."
        extract-updates -confirm
    }
}

Function remove-nonenglishpatches
{
    #Define englishpatchestokeep. Big thanks to Kevin Greene for this: http://kevingreeneitblog.blogspot.nl/2012/10/scom-2012-deploying-cumulative-update.html
    $englishpatchestokeep=@(`
    "all-kb2750631-amd64-console_755b85ba494fa5c83ca31cf40d38be5d6d0551ef",`
    "all-kb2750631-amd64-reporting_8043cc39d79514d1e633b645063100c136cf1f92",`
    "all-kb2750631-amd64-console_755b85ba494fa5c83ca31cf40d38be5d6d0551ef",`
    "all-kb2750631-amd64 webconsole_2ef77d6ea1080b83c10351001dc13bf7e6977b7a",`
    "all-kb2750631-amd64-agent_d7cc8d1fa307f6bc9db3ced386f427864b3a3e5d",`
    "all-kb2750631-i386-agent_a2c8476c8b4352e4c38fc8116e4953046cb691d0",`
    "all-kb2750631-ia64-agent_da768ff179a4039c9e1be3246b081a1342f70274",`
    "all-kb2750631-amd64-server_44223b2a954b95837ebfbdcbcf8b742a56dbe123",`
    "all-kb2750631-amd64-gateway_90206ca6ac69a5982a7eaa74e7eedf41f367ee7b")
    
    #Get the patches in the updatesextractionpath
    $patches = get-childitem $updatesextractionpath

    Foreach($patch in $patches) #Check for each patch if it is in $enlishpatchestokeep and either keep or remove the patch.
    {
        #Get patch information and store in variable
        $patchname = $patch.name
        $patchfullname = $patch.fullname


        IF($englishpatchestokeep -contains $patchname) #Keep patch if the patch is in $enlishpatchestokeep
        {
            #write-host "Keep patch"
        }
        ELSE #Remove patch if the patch is not in $enlishpatchestokeep
        {
            #Delete dir
            Remove-item -Path $patchfullname -recurse -force

        }
    }
}

#Run the function to extract updates
extract-updates 

#Run the function to remove manually specified non english patches
remove-nonenglishpatches