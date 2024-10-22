<########################################################################################

Name		:	Extract-WinauditInfo
Date		:	February 25th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   I run Winaudit on each server/system and save it to a central location named <computername>.csv
                This way I have access to a lot of information about each system. If you need specific information
                for each server however, you don't want to open each file manually to get this information.

                This script will parse each <computername>.csv to extract specifc information and save it to one new file containing this info for all parsed separate files.


Assumptions	:   It is assumed that the number of cores per physical processor in a system does not vary.

Known issues:	

Limitations	:	

Notes   	:   -Winaudit can be downloaded for free at : http://winaudit.zymichost.com/
                -This sample script assumes the Winaudit csv is in English 

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	February 25 2013	:	Created script
 
########################################################################################>

#Define output file
$outputfile = "D:\Virtual Direcories\WinAudit\CPU_count_and_core_count_27-02-2012.csv"

#Define input files
$files = get-childitem "D:\Virtual Direcories\WinAudit\" -filter *.csv

#Define header
$header = "Computer name;Processor Description;Number of processors;Number of cores per physical processor;Number of logical processors per physical processor (Hyperthreading taken in account);Operating System;OS Service Pack" 

#Write header to output file
$header | out-file $outputfile -force -append

#For each input file
Foreach($file in $files)
{
    #Clear variable values
    $computername = $null
    $ProcessorDescription = $null
    $ProcessorDescription = $null
    $Numberofprocessors = $null
    $Numberofcoresperphysicalprocessorarray = $null
    $Numberofcoresperphysicalprocessors = $null
    $Numberoflogicalprocessorsperphysicalprocessorarray = $null
    $Numberoflogicalprocessorsperphysicalprocessor = $null
    $os = $null
    $osservicepack = $null
    
    #Import the CSV and save it to the $csv variable
    $csv = import-csv $file.fullname
    
    #Extract desired information from the imported CSV and save it to the variables
    $Computername = ($csv | where{$_.ItemName -eq "Computer Name"}).ItemValue1
    $ProcessorDescription = ($csv | where{($_.ItemName -eq "Processor Description")}).ItemValue1
    $Numberofprocessors = ($csv | where{$_.ItemName -eq "Number Of Processors"}).ItemValue1
    $Numberofcoresperphysicalprocessorarray = $csv | where{($_.Category -eq "Processors") -and ($_.ItemName -eq "Number Cores")}
    
    #Even though the number of cores per physical processor might vary, it is very unlikely. To simplify the output it is assumed the processors are identical
    Foreach($processor in $Numberofcoresperphysicalprocessorarray)
    {
       $Numberofcoresperphysicalprocessors = $processor.ItemValue1
    }
    $Numberoflogicalprocessorsperphysicalprocessorarray = ($csv | where{($_.Category -eq "Processors") -and ($_.ItemName -eq "Logical Processors")}).ItemValue1
    
    #Even though the number of cores per physical processor might vary, it is very unlikely. To simplify the output it is assumed the processors are identical
    Foreach($processor in $Numberofcoresperphysicalprocessorarray)
    {
        $Numberoflogicalprocessorsperphysicalprocessor = $processor.ItemValue1
    }
    
    $OS = ($csv | where{$_.ItemName -eq "Operating System"}).ItemValue1
    $OSServicePack = ($csv | where{$_.ItemName -eq "Service Pack"}).ItemValue1
    
    #Define the output format
    $Output = "$computername;$ProcessorDescription;$Numberofprocessors;$Numberofcoresperphysicalprocessors;$Numberoflogicalprocessorsperphysicalprocessor;$OS;$OSServicePack"
    
    #Write the output to the output file
    $Output | out-file $outputfile -force -append
}