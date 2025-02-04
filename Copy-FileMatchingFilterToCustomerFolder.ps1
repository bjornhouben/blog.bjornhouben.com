<########################################################################################

Name		:	Copy-FileMatchingFilterToCustomerFolder.ps1
Date		:	January 7th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Report files for multiple customers are placed a source folder monthly. The report files include the customer name.
                These reports need to be copied to a specific folder (on sharepoint) named "Backup Controle" somewhere inside a customer's root folder.

                Notes:
                1. The customer's root folder name can differ from the customer name used in the report files.
                2. The folder "Backup Controle" isn't always located in the same relative location from the root folder.

                By example:

                -The source report files folder contains:
                Backup Controle - Customer 1 - 12-2012.pdf
                Backup Controle - Customer 2 - 12-2012.pdf

                -The customer's root folder's might be:
                C:\Customersroot\Cust1
                C:\Customersroot\Client2

                -The "Backup Controle" folder might be located at:
                C:\Customersroot\Cust1\folder1\folder2\folder3\temp\folder4\Backup Controle
                C:\Customersroot\Client2\folder1\folder2\Backup Controle

                This script contains a function where you can define for each customer:
                1. Which name filter specifies the customer for the report name.
                2. What the name of the folder is for the customer's root folder.
                
                The script will then recursively look inside the customer's folder for a folder matching the "Backup Controle" folder and will copy the report to it if it does not exist.                
                

Assumptions	:	-There is only one folder names Backup Controle in the customer's folder.
                -The PowerShell executionpolicy is set to unrestricted using : Set-ExecutionPolicy "Unrestricted"
                

Known issues:	N/A

Limitations	:	N/A

Notes   	:   If files need to be copied to sharepoint, create a network mapping using WebDAV.


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 7 2013	:	Created script
 
########################################################################################>


#Variables you might need to customize
$sourcefolder = "C:\Backup Reports"
$fileextensiontoincludefromsourcefolder = "*.pdf"
$Destinationdrive = "C:\Customersroot"
$Destinationfoldername = "Backup Controle"
$logfilename = "Copy-FileMatchingFilterToCustomerFolder"

$logfileextension = ".csv"
$date = get-date -format MM-dd-yyyy-HH.mm

#Construct the outputfile full path
$outputfile = $sourcefolder + "\" + $logfilename + $date + $logfileextension

#Declare function to be run for each combination of PdfFileFilter and custommerrootfolder.
Function Copy-FileMatchingFilterToCustomerFolder($PdfFileFilter,$customerrootfoldername)
{  
    #Get all PDFs in the $sourcefolder
    $pdfs = @(get-childitem -path $sourcefolder -include $fileextensiontoincludefromsourcefolder -recurse -force | where {$_.BaseName -match $PDFFileFilter})

    IF($pdfs.count -lt 1) #If there are no PDF's matching the $PDFFileFilter, no further processing is necessary.
    {
        #write-host "No PDFs found matching filter: $PDFFileFilter
    }
    Else #Process the found PDF's matching the $PDFFileFilter
    {
        #Construct the full $destinationcustomerpath for the customer
        $Destinationcustomerpath = $destinationdrive + $customerrootfoldername

        #Determine the full path of the folder matching the $destinationfoldername by recursively checking the customer's root folder
        $backupfolderfullpath = (get-childitem -path $Destinationcustomerpath -recurse | Where{($_.PSisContainer -eq $TRUE) -and ($_.name -eq $Destinationfoldername)}).Fullname

        #Determine if there is a folder matching the current year and if not, create it
        $Year = (Get-Date).Year
        IF(Test-Path $backupfolderfullpath+'\'+$year)
        {
            Write-Output "Year folder $Year exists in $backupfolderfullpath"
        }
        ELSE
        {
            New-Item -Path $backupfolderfullpath -Name $Year -ItemType Directory -Force -Confirm:$False
        }
        $backupfolderfullpathYear = $backupfolderfullpath+'\'+$year
    
        #Copy each pdf found in the source folder to the customer "Backup Controle" folder
        foreach($pdf in $pdfs)
        {
            #Get the fullname and the name of the PDF
            $PDFfullname = $pdf.fullname
            $PDFname = $pdf.name
        
            #Determine what the new file location would become
            $newfilelocation = $backupfolderfullpathYear + "/" + $pdfname
        
            #Reset the value of the $backupfolderpathtest variable
            $backupfolderpathtest = $null

            #Check if the backupfolderfullpath exists and/or is reachable
            $backupfolderpathtest = Test-Path $backupfolderfullpathYear

            IF($backupfolderpathtest -eq $TRUE) #Proceed if the backupfolderpath both exists and is reachable
            {
        
                IF((Test-path $newfilelocation) -eq $TRUE) #If the file is present already at the backupfolderpath, write this to console and log.
                {
                    #Create logging to console and source folder
                    "$date;exists;$PDFname;$backupfolderfullpathYear" | write-host
                    "$date;exists;$PDFname;$backupfolderfullpathYear" | out-file -filepath $outputfile -append -force
                }
                ELSE #If the file does not exist at the backupfolderpath, copy the file and log its results.
                {
                    #Copy the item to the backupfolderfullpath
                    copy-item $PDFFullname -destination $backupfolderfullpathYear -force #-confirm
                
                           
                    IF((Test-path $newfilelocation) -eq $TRUE) #If the copy was succesful, write success to console and log.   
                    {
                        #Create logging to console and source folder
                        "$date;succes;$PDFname;$backupfolderfullpathYear" | write-host
                        "$date;succes;$PDFname;$backupfolderfullpathYear" | out-file -filepath $outputfile -append -force
                    }
                    ELSE #If the copy was unsuccesful, write this to console and log.
                    {
                        #Create logging to console and source folder
                        "$date;fail;$PDFname;$backupfolderfullpathYear" | write-host
                        "$date;fail;$PDFname;$backupfolderfullpathYear" | out-file -filepath $outputfile -append -force
                    }
                }
             }
             Else #If the backupfolderpath either does not exist or is reachable, write this to console and log.
             {
                    #Create logging to console and source folder
                    "$date;backup folder not exist or unreachable;$PDFname;Backup folder path is dynamically determined. Will not work when no connection." | write-host
                    "$date;backup folder not exist or unreachable;$PDFname;Backup folder path is dynamically determined. Will not work when no connection." | out-file -filepath $outputfile -append -force
             }
        }
    }
}


#Run the function for each reportfilter and customer folder (in the root folder)
Copy-FileMatchingFilterToCustomerFolder "Customer 1" "cust1"
Copy-FileMatchingFilterToCustomerFolder "Customer 2" "client2"

#open the logfile for review
invoke-item -path $outputfile