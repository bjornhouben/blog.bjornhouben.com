<########################################################################################

Name		:	Create-Event
Date		:	February 23rd 2013
Author		:	Bjorn Houben
Blog        :	http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Create an event in an existing event log or a new event log.
                This can be useful to keep track of what happens in your script either locally or using monitoring tools like SCOM.

                You can also use it to test if custom event monitoring you've configured is working as expected. 
		
                Or run a task in response to a given event as explained here: http://technet.microsoft.com/en-us/library/cc748900.aspx
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

History     :	Januari 8 2013	:	Created script
 
########################################################################################>



Function create-eventlog($computername, $logname, $eventsource, $maxsize, $overflowaction)
{
    #If you want to create your own log to be used, use the create-eventlog function
    new-eventlog -logname $logname -Source $eventsource
    limit-eventlog -logname $logname -ComputerName $computername -Maximumsize $maxsize -OverFlowAction $overflowaction

}
create-eventlog $env:Computername "MyEventLog" "Create Event Log" 16MB "OverwriteAsNeeded"
 
Function create-event ($computername, $eventID, $logname, $eventsource, $Description, $Eventlevel)
{
    #$Eventlevel can be Error, Warning, Information, SuccessAudit or FailureAudit
    #lognames on a computer can be determined using "get-eventlog -list"
    #When creating custom events, ensure the combination of the Source ("Test Source Bjorn") and EventID ("666") is unique.

    $EventLog = New-Object System.Diagnostics.EventLog($logname)
    $EventLog.MachineName = $computername
    $EventLog.Source = $eventsource
    $EventLog.WriteEntry($description,$eventlevel, $EventID)
}

#create-event $env:COMPUTERNAME "666" "Application" "Test Source Bjorn" "Test description Bjorn" "Information"
