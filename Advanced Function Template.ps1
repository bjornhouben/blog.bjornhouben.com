#Turn strict mode on and set it to version 2.0. As a result, Windows PowerShell throws an error if you use
#method syntax (parentheses and commas) for a function call or reference uninitialized variables or non-existent properties.
Set-Strictmode -version 2.0

#If desirable, use Start-Transcript and Stop-Transcript to create logging. Beware, this does not work with the PowerShell ISE.
    
Set-PSDebug -Trace 0 #Set the trace level. 0 turn script tracing off. For debugging commands see: get-command -noun "PSBreakPoint" and Get-PSCallStack. You can also use PowerShell ISE for debugging.
#Set-PSDebug -Step #Enable debug step prompting to confirm each command. Disable using Set-PSDebug -Off
#Set-PSDebug -Strict #Enable debugging with similar functionality as in Set-StrictMode

#region mycustomregion
#Insert script block here. Helps make script more readable/manageable because you can collapse the custom script block region in the PowerShell Integrated Scripting Environment (ISE)
#Beware: #region and #endregion need to be lower case.
#endregion mycustomregion

Function Get-SystemInfo
{
<#
.Synopsis
    Retrieves system version and model information from one or more computers.
.DESCRIPTION
    Get-SystemInfo uses WMI to retrieve information from one or more computers.
.PARAMETER ComputerName
    One or more computer names or IP addresses.
.PARAMETER LogErrors
    By default errors are not logged. Use -LogErrors to enable logging errors.
.PARAMETER ErrorLog
    When used with -LogErrors it specifies the full path and location for the ErrorLog. Defaults to "D:\errorlog.txt"
.LINK
    http://blog.bjornhouben.com
.NOTES        
Name	    :	Advanced Function Template
Last edit   :	March 17th 2013
Version     :	1.1.0 March 17 2013     :   Added useful notes with regards to #Requires
                1.0.0 February 25 2013	:	Created script

Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Keywords    :   Advanced,Function,Template,PowerShell,Script

Assumptions	:   

Known issues:	

Limitations	:	

Notes   	:   1) This advanced function template is based on the great book : Learn PowerShell Toolmaking In A Month Of Lunches

                2) For more options and info about adding help: get-help about_comment_based_help
                   Also read the following : http://www.nigelboulton.co.uk/2011/05/problems-with-powershell-comment-based-help/

                3) With #Requires you can define requirements that must be met before running the script.
                   Even though it might appear commented out with #, it is enabled.
                   By example you can prevent a script from running if the wrong PowerShell version is used or if a needed module or snap-in is not present.
                   For more information, use get-help about_Requires.

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/


.EXAMPLE
    Get-SystemInfo
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function and prompts for parameters.
.EXAMPLE
    Get-SystemInfo "localhost" "C:\logfile.txt" -LogErrors -Verbose
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for "localhost", logs errors to "C:\myerrorlog.txt" and shows verbose information.
    This example uses the position of the arguments as you can see, because -ComputerName and -ErrorLog are not included in the command.
.EXAMPLE
    Get-SystemInfo -hostname "localhost" -LogErrors -logfile "C:\logfile.txt" -Verbose
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for "localhost", logs errors to "C:\myerrorlog.txt" and shows verbose information.
.EXAMPLE
    Get-SystemInfo -ComputerName "localhost","AS-01" -LogErrors -ErrorLog "C:\myerrorlog.txt" | Format-List
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for "localhost" and "AS-01", logs errors to "C:\myerrorlog.txt" and returns the info as a format-list.
.EXAMPLE
    Get-SystemInfo -ComputerName "AS-01","AS-02" -LogErrors -ErrorLog "C:\myerrorlog.txt" | Format-Table -Auto
    
    
    Description
    
    -----------
    
    Placeholder.
.EXAMPLE
    Get-SystemInfo -ComputerName "AS-03","AS-04" -LogErrors -ErrorLog "C:\myerrorlog.txt" | ConvertTo-Html | Out-File "D:\Test.html"
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for "AS-03" and "AS-04", logs errors to "C:\myerrorlog.txt" and saves the results as HTML to "D:\Test.html".
.EXAMPLE
    Get-SystemInfo -ComputerName "DC-01","DC-02" -LogErrors -ErrorLog "C:\myerrorlog.txt" | Export-Csv -Path "D:\Test.csv"
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for "DC-01" and "DC-02", logs errors to "C:\myerrorlog.txt" and saves the info as CSV to "D:\Test.csv".
.EXAMPLE
    Get-SystemInfo -ComputerName "localhost","DC-02" -LogErrors -ErrorLog "C:\myerrorlog.txt" | Sort ComputerName
    
    
    Description
    
    -----------
    
    Placeholder.
.EXAMPLE
    Get-SystemInfo -ComputerName "AS-01","DC-01" -LogErrors -ErrorLog "C:\myerrorlog.txt" | Out-GridView
    
    
    Description
    
    -----------
    
    Placeholder.
.EXAMPLE
    Get-SystemInfo -ComputerName "AS-01","AS-02","AS-03","AS-04" -LogErrors -ErrorLog "C:\myerrorlog.txt" -Verbose | Format-Table -AutoSize
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for "AS-01","AS-02","AS-03" and "AS-04", logs errors to "C:\myerrorlog.txt", shows verbose information and returns the info as an auto-sized format-table.
.EXAMPLE
    Get-SystemInfo -ComputerName ((get-adcomputer -filter *).name) -LogErrors -ErrorLog "C:\myerrorlog.txt" | Format-Table -AutoSize
    
    
    Description
    
    -----------
    
    Runs the SystemInfo function for  all computers in Active Directory, logs errors to "C:\myerrorlog.txt" and returns the info as an autosized format-table.
.EXAMPLE
    (Get-ADComputer -LDAPFilter "(name=*)" -SearchBase "DC=CORP,DC=BjornHouben,DC=com").name | Get-SystemInfo -LogErrors -Logfile "C:\myerrorlog.txt" | Format-Table ComputerName, OSVersion, Manufacturer -AutoSize
    
    
    Description
    
    -----------
    
    Gets all computers in the Active Directory forest Corp.BjornHouben.com and pipes it to Get-SystemInfo. Get-SystemInfo logs errors to "C:\myerrorlog.txt" and returns the info as an autosized format-table containing ComputerName, OSVersion and Manufacturer.
.INPUTS
.OUTPUTS                          
#>

    #Requires -Version 3

    [CmdletBinding()] #Provides advanced functionality. For more details see "What does PowerShell's [CmdletBinding()] Do?" : http://www.windowsitpro.com/blog/powershell-with-a-purpose-blog-36/windows-powershell/powershells-[cmdletbinding]-142114

    param(
        #Parameter1
        [Parameter(Mandatory=$True, #Setting mandatory to $TRUE, means the default value will be ignored.
                   ValueFromPipeline=$True, #Setting ValueFromPipeline to $True means that values from the pipeline are accepted.
                   Position=0, #Defines the order in which parameters needs to be entered if you don't specify it. Best practice is to specify though using in this case -ComputerName
                   HelpMessage="Enter a computer name or IP address")] #Enter a help message to be shown when no parameter value is provided.
        #[ValidateCount(1,10)] #Limit the maximum number of allowed arguments. In this case it limits the number of computers.
        [Alias("HostName")] #You can use either -HostName or -ComputerName
        [string[]]$ComputerName = "localhost", #Don't forget to use the , if you're using more parameters. Defaults to "localhost", but can be overridden using -Computername

        #Parameter2
        [Parameter(Mandatory=$False, #Setting mandatory to $TRUE, means the default value will be ignored.
                   ValueFromPipeLine=$False,  #Setting ValueFromPipeline to $False means that values from the pipeline are NOT accepted.
                   Position=1, #Defines the order in which parameters needs to be entered if you don't specify it. Best practice is to specify though using in this case -ErrorLog
                   HelpMessage='Enter the full path for your log file. By example: "C:\Windows\log.txt"')] #Enter a help message to be shown when no parameter value is provided.
        [Alias("LogFile")] #You can use either -LogFile or -Errorlog        
        [string]$ErrorLog = "D:\errorlog.txt", #Defaults to "D:\errorlog.txt" , but can be overridden using -ErrorLog      
    
        #Parameter3
        [switch]$LogErrors #You need to specify -LogErrors to enable the logging of errors. By default, logging is disabled.
    ) #End of Param block 
    
    BEGIN #Only performed once for the function in the beginning.
    {
        Write-Verbose "Errorlog is: $ErrorLog"
    } #End of BEGIN block
    PROCESS #Performed multiple times for the function
    {
        Write-Verbose "Beginning PROCESS block"
        Foreach($Computer in $ComputerName) #Always assume $computername contains multiple $computernames and therefore use a Foreach loop
        {
            Write-Verbose "Started querying $Computer"

            TRY #For more info on TRY CATCH and FINALLY : http://blogs.technet.com/b/heyscriptingguy/archive/2010/03/11/hey-scripting-guy-march-11-2010.aspx
            { 
                $CheckSuccesful = $True #Set the CheckSuccesful parameter to $true as the starting value.
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -erroraction Stop #Attempt to aquire WMI information from the computer. Stop on error.
            } #End of TRY
            CATCH #Catch blocks only handle terminating errors. For a catch block to handle non-terminating errors, set the $ErrorActionPreference variable or the -ErrorAction parameter of a cmdlet to Stop
            {
                $CheckSuccesful = $False #Set the CheckSuccesful parameter to $False if an error has occurred.

                $date = get-date -Format dd-MM-yyyy #Get date in a specific format.
                $time = get-date -Format hh.mm #Get time in a specific format.
                $erroroutput = "$date;$time;$Computer;WMI query failed;$_" #Define the error output. $_ contains the exception object. You can also use $_.Exception.Message or $error. $? returns true if the last command was succesful.

                Write-Warning $erroroutput #Write $erroroutput as a warning.

                IF($LogErrors -eq $True) #If -LogErrors parameter has been specified, log $Computer to $ErrorLog and write-verbose.
                {
                    Write-Verbose "Writing error for Computer : $Computer to $ErrorLog" #Write verbose output.
                    $ErrorOutput | Out-File $ErrorLog -Append -Encoding ASCII #Write $erroroutput to the $ErrorLog file as ascii.
                } #End of IF($LogErrors -eq $True)
            } #End of Catch
            FINALLY
            {
                #Perform cleanup if necessary
            } #End of Finally
             
            IF ($CheckSuccesful -eq $True) #If aquiring WMI information from the computer was succesful, continue with other commands.
            {
                #Get the remainder of the desired (superset of) information
                $Comp = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer
                $Bios = Get-WmiObject -Class Win32_Bios -ComputerName $Computer

                #Store the desired (subset of) information in a hashtable. Good article about hashtables : http://technet.microsoft.com/en-us/library/ee692803.aspx
                $Props = @{'ComputerName'=$Computer;
                           'OSVersion'=$Os.version;
                           'SPVersion'=$Os.servicepackmajorversion;
                           'BIOSSerial'=$Bios.serialnumber;
                           'Manufacturer'=$Comp.manufacturer;
                           'Model'=$Comp.model}

                Write-Verbose "Completed querying $Computer"
            
                #Store the content of the hashtable in the PSObject for later use.
                $Obj = New-Object -TypeName PSObject -Property $Props
                
                <#
                #An alternative approach is to create the PSObject and add to it directly instead of creating the hash table first: 
                $Obj = New-Object -TypeName PSObject -Property
                $Obj | Add-Member -MemberType noteproperty -Name ComputerName -Value $computer
                $Obj | Add-Member -MemberType noteproperty -Name OSVersion -Value $Os.version
                $Obj | Add-Member -MemberType noteproperty -Name SPversion -Value $Os.servicepackmajorversion
                $Obj | Add-Member -MemberType noteproperty -Name BIOSSerial -Value $Bios.serialnumber
                $Obj | Add-Member -MemberType noteproperty -Name Manufacturer -Value $Comp.manufacturer
                $Obj | Add-Member -MemberType noteproperty -Name Model -Value $Comp.model
                #>

                #Put the object in the pipeline. You should not use write-host , Format-Table or any other output method in here to preserve flexibility. See the function examples for better ways.
                $Obj
            } #End of IF ($CheckSuccesful -eq $True)
        }
    } #End of PROCESS block
    END #Only performed once for the function at the end.
    {
    } #End of END block
} #End of function Get-Systeminfo
Get-Help Get-SystemInfo -full