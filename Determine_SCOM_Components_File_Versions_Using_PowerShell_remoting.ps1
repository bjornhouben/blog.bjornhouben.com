<########################################################################################

Name		:	Determine SCOM Components File Versions Using PowerShell Remoting.ps1
Date		:	December 10th 2012
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Unfortunately SCOM 2012 now only shows the major version 7.0.8560.0 when using get-scommanagementserver or get-scomagent.
                This script will show the file versions of the SCOM 2012 components: Management Server, Gateway Server, Console, Web Console, Agent and reporting tools.

                Using PowerShell remoting, this script will query your SCOM environment for management servers and agents and will then check their local file versions.

                

Assumptions	:	To query SCOM, you are running the script from a system that meets all of these requirements:
                 1. The "Operations Manager Shell" is installed.
                 2. You can connect to the management server for queries.
                 3. Your account has sufficient permissions to query the management server.

                To query the file versions on remote systems:
                 1. PowerShell remoting must be enabled and configured correctly.
                 2. Connectivity to the remote systems must be available.
                 3. The account used for PowerShell remoting must have sufficient permissions.

Known issues:	

Limitations	:	

Notes   	:	This script was inspired by Stefan Stranger's blog post about installing update rollup 3:
                http://blogs.technet.com/b/stefan_stranger/archive/2012/10/22/opsmgr-2012-update-rollup-3-ships-and-my-experience-installing-it.aspx

                To determine the changed files, I used the commands provided in this blog post:
                Get-ItemProperty -Path "$env:ProgramFiles\System Center 2012\Operations Manager\Server\*.dll" | select -ExpandProperty VersionInfo | where {$_.FileVersion -eq "7.0.8560.1036"} | Format-List FileName, FileVersion
                Get-ItemProperty -Path "c:\\Program Files\System Center 2012\Operations Manager\Reporting\Tools\*.*" | select -ExpandProperty VersionInfo | where {$_.FileVersion -eq $SCOM2012_Update_version} | Format-List FileName, FileVersion
                Get-ItemProperty -Path "$env:ProgramFiles\System Center 2012\Operations Manager\Console\*.dll" | select -ExpandProperty VersionInfo | where {$_.FileVersion -eq $SCOM2012_Update_version} | Format-List FileName, FileVersion
                Get-ItemProperty -Path "$env:ProgramFiles\System Center 2012\Operations Manager\WebConsole\WebHost\bin\*.dll" | select -ExpandProperty VersionInfo | where {$_.FileVersion -eq $SCOM2012_Update_version} | Format-List FileName, FileVersion
                Get-ItemProperty -Path "$env:ProgramFiles\System Center Operations Manager\Gateway\*.dll" | select -ExpandProperty VersionInfo | where {$_.FileVersion -eq $SCOM2012_Update_version} | Format-List FileName, FileVersion
                Get-ItemProperty -Path "$env:ProgramFiles\System Center Operations Manager\Agent\*.dll" | select -ExpandProperty VersionInfo | where {$_.FileVersion -eq $SCOM2012_Update_version} | Format-List FileName, FileVersion

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	December 10 2012	:	Created script
 
########################################################################################>


#Load the OperationsManager PowerShell module
Import-Module OperationsManager

#Get managementservers and agents
$ManagementServers = Get-SCOMManagementServer
$Agents = Get-SCOMagent

#Declare function for PowerShell remoting
Function get-remotefileversions($computername)
{
    #Invoke-command is used to perform commands on remote machines using PowerShell remoting. The ScriptBlock defines what will be executed on each local machine.
    invoke-command -computername $computername -ScriptBlock{
        
        #Get the local hostname
        $hostname = $env:COMPUTERNAME

        #Declare the function to get fileversions
        Function get-fileversion($description,$file)
        {
            #Declare the desiredversion.             
            #SCOM 2012 Update Rollup 3 version = "7.0.8560.1036"
            #SCOM 2012 SP1 beta version = "7.0.8925.0"            
            $desiredversion = "7.0.8560.1036"
    
            IF((test-path $file) -ne $true) #If file is not present, no file version check will be performed
            {
                #write-host "Not present;$file"
            }
            ELSE #If file is present, file version check will be performend
            {
                #write-host "Present;$file"

                #Get the fileversion
                $fileversion = (Get-ItemProperty -Path $file | select -ExpandProperty VersionInfo).FileVersion
                
                #Define the outputformat
                $output = "$hostname;$fileversion;$description;$file"

                IF($fileversion -eq $desiredversion) #If fileversion matches desired version, do not show in output
                {
                    #write-host $output
                }
                ELSE #If fileversion does not match desired version, show in output
                {
                    #Show only non compliant versions
                    $output | write-host
                }
            }
        }

        #Define the files to check
        
        #Files for SCOM 2012 Management Server
        get-fileversion "Management Server" "$env:ProgramFiles\System Center 2012\Operations Manager\Server\Microsoft.EnterpriseManagement.DataAccessService.OperationsManager.dll"
        get-fileversion "Management Server" "$env:ProgramFiles\System Center 2012\Operations Manager\Server\Microsoft.EnterpriseManagement.Modules.PowerShell.dll"
        get-fileversion "Management Server" "$env:ProgramFiles\System Center 2012\Operations Manager\Server\Microsoft.EnterpriseManagement.RuntimeService.dll"
        get-fileversion "Management Server" "$env:ProgramFiles\System Center 2012\Operations Manager\Server\MomIISModules.dll"

        #Files for SCOM 2012 Console
        get-fileversion "Console" "$env:ProgramFiles\System Center 2012\Operations Manager\Console\Microsoft.EnterpriseManagement.Presentation.Controls.dll"
        get-fileversion "Console" "$env:ProgramFiles\System Center 2012\Operations Manager\Console\Microsoft.EnterpriseManagement.Presentation.Core.dll"
        get-fileversion "Console" "$env:ProgramFiles\System Center 2012\Operations Manager\Console\Microsoft.EnterpriseManagement.Presentation.DataProviders.Library.dll"
        get-fileversion "Console" "$env:ProgramFiles\System Center 2012\Operations Manager\Microsoft.EnterpriseManagement.UI.ConsoleFramework.dll"
        get-fileversion "Console" "$env:ProgramFiles\System Center 2012\Operations Manager\Microsoft.Mom.UI.Components.dll"

        #Files for SCOM 2012 Web Console
        get-fileversion "Web Console" "$env:ProgramFiles\System Center 2012\Operations Manager\WebConsole\WebHost\bin\Microsoft.EnterpriseManagement.Presentation.Core.DLL"
        get-fileversion "Web Console" "$env:ProgramFiles\System Center 2012\Operations Manager\WebConsole\WebHost\Microsoft.EnterpriseManagement.Presentation.DataProviders.Library.dll"
        get-fileversion "Web Console" "$env:ProgramFiles\System Center 2012\Operations Manager\WebConsole\WebHost\Microsoft.EnterpriseManagement.Presentation.Security.Cryptography.dll"

        #Files for SCOM 2012 Gateway
        get-fileversion "Gateway" "$env:ProgramFiles\System Center Operations Manager\Gateway\Microsoft.EnterpriseManagement.Modules.PowerShell.dll"
        get-fileversion "Gateway" "$env:ProgramFiles\System Center Operations Manager\Gateway\MomIISModules.dll"
        get-fileversion "Gateway" "$env:ProgramFiles\System Center Operations Manager\Gateway\MOMScriptAPI.dll"

        #Files for SCOM 2012 Reporting
        get-fileversion "Reporting" "$env:ProgramFiles\System Center 2012\Operations Manager\Reporting\Tools\OpsMgrTraceTMFVer.Dll"
        get-fileversion "Reporting" "$env:ProgramFiles\System Center 2012\Operations Manager\Reporting\Tools\TraceFmtSM.exe"
        get-fileversion "Reporting" "$env:ProgramFiles\System Center 2012\Operations Manager\Reporting\Tools\TraceLogSM.exe"

        #Files for SCOM 2012 Agent
        get-fileversion "Agent" "$env:ProgramFiles\System Center Operations Manager\Agent\Microsoft.EnterpriseManagement.Modules.PowerShell.dll"
        get-fileversion "Agent" "$env:ProgramFiles\System Center Operations Manager\Agent\MomIISModules.dll"
        get-fileversion "Agent" "$env:ProgramFiles\System Center Operations Manager\Agent\MOMScriptAPI.dll"

        get-fileversion "Agent" "${env:ProgramFiles(x86)}\System Center Operations Manager\Agent\Microsoft.EnterpriseManagement.Modules.PowerShell.dll"
        get-fileversion "Agent" "${env:ProgramFiles(x86)}\System Center Operations Manager\Agent\MomIISModules.dll"
        get-fileversion "Agent" "${env:ProgramFiles(x86)}System Center Operations Manager\Agent\MOMScriptAPI.dll"

        }
}

#Run the get-remotefileversions function for all Management Servers
Foreach($ManagementServer in $ManagementServers)
{
    get-remotefileversions $managementserver.NetworkName
}

#Run the get-remotefileversions function for all agents
Foreach($Agent in $Agents)
{
    get-remotefileversions $agent.NetworkName
}