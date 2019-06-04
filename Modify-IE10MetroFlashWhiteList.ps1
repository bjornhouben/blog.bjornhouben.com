<########################################################################################

Name		:	Modify-IE10MetroFlashWhiteList.ps1
Date		:	January 5th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Windows 8 and Windows RT include support for Flash in Internet Explorer 10.
                
                In Windows 8 there are however two version of Internet Explorer 10 that handle
                flash websites differently. First there's Internet Explorer 10 Desktop, which is
                similar as the Internet Explorer you've been used to with previous versions of Windows.
                Then there's also Internet Explorer 10 (non Desktop), which is the Internet Explorer in
                the new modern/Windows interface (Metro) that is full screen.

                Internet Explorer 10 Desktop allows Flash for all websites.
                Internet Explorer 10 (Metro) only allows Flash for websites that have been whitelisted.

                Especially for Windows tablets, Flash support can be a selling point because most other tablets
                don't have Flash support. It is however confusing for regular consumers that not all their websites
                will work. By example a friend of mine who's a hairdresser, uses http://www.kapperssite.nl to show
                her customers models and their haircuts. The site is however completely in Flash and that it is not
                working by default is very annoying.

                The websites that have been whitelisted are defined in your local appdate folder. By example:
                "C:\Users\Bjorn\AppData\Local\Microsoft\Internet Explorer\IECompatData\iecompatdata.xml".
                This file also contains information about websites and which compatibility mode should be used for each.
                The segment between <flash> and </flash> contains the websites that have been whitelisted for flash.

                You can manually modify this file as described here: http://forum.xda-developers.com/showthread.php?t=1961793
                Basic steps include:
                1. Modifying the iecompatdata.xml to add the websites you want to whitelist for Flash.
                   Wildcards don't work unfortunately.
                2. Open Internet Explorer 10 Desktop, press ALT, Tools, "Compatibility View setting". 
                   Then Disable "Download updated compatibility lists from Microsoft"
                   This way Microsoft won't overwrite the updates you've made in step 1.
                3. Delete the IE10 browser history.

                The disadvantage of this method however is, that you won't be taking advantage of future
                compatibility updates because you've disabled the update functionality. Leaving it enabled
                however means that you you would have to keep re-adding sites you want to whitelist for Flash .

                As a workaround, I've created this script that will automatically perform these tasks:
                1. Disable "Download updated compatibility lists from Microsoft"
                2. Close all internet explorer processes.
                3. Download the latest iecompatdata.xml to the appropriate folder.
                4. Combine the data from the latest iecompatdata.xml with websites you want to whitelist for Flash
                   (specified in flashsitestoadd.txt).
                5. Backup the original iecompatdata.xml and store the modified iecompatdata.xml
                6. Clear the Internet Explorer browsing history.

                Because automatic downloading of updated compatibility lists has been disabled, I advise to schedule
                the script to run on a regular basis (by example monthly). For instructions read this blog post:
                http://blogs.technet.com/b/heyscriptingguy/archive/2012/08/11/weekend-scripter-use-the-windows-task-scheduler-to-run-a-windows-powershell-script.aspx
                Keep in mind that this will clear your Internet Explorer browsing history though.

Assumptions	:	-You've created a file containing flash sites to add to the white list.
                -In this file each domain you want to add is on a seperate lin in this format: kapperssite.nl
                -The file is stored in the IECompatDate folder by example:
                 "C:\Users\Bjorn\AppData\Local\Microsoft\Internet Explorer\IECompatData\flashsitestoadd.txt"

Known issues:	-Download of the latest iecompatviewlist.xml might fail when the script is run using ISE
                -Getresponse() will show an error when an iecompatdata.xml does not exist for a specific month.

Limitations	:	

Notes   	:   -Inspired by : http://forum.xda-developers.com/showthread.php?t=1961793
                -This script will close all internet explorer processes.
                -This script will remove your internet explorer browsing history.
                -This script will disable "Download updated compatibility lists from Microsoft",because otherwise all the sites
                 you've whitelisted will be removed. To get updates AND have your personal whitelisted sites, schedule this script
                 to run on a regular basis. Keep in mind that this will delete your browsing history though.


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 5 2013	:	Created script
 
########################################################################################>

#Create a file containing flash sites to add. Enter each domain you want to add on a seperate line in this format: kapperssite.nl
#Store it in the same location from where you run the script
$flashsitestoaddfile="flashsitestoadd.txt"

#Disable "Download updated compatibility lists from Microsoft"
#The script will download the latest compatibility list automatically when run. 
#Consider running the script on a regular basis (or scheduling it).
$path = "HKCU:\Software\Microsoft\Internet Explorer\BrowserEmulation"
$name = "MSCompatibilityMode"
$compatibilitymodevalue = (Get-ItemProperty -Path $path -Name $name).$name
IF($compatibilitymodevalue = 1) #If enabled, then disable
{
    Set-ItemProperty -Path $path -Name $name -Value 0
}

#Close all Internet Explorer processes.
get-process iexplore | Stop-Process -Force

#Set variables 
$flashsitestoaddfilefullpath = $env:LOCALAPPDATA + "\Microsoft\Internet Explorer\IECompatData\" + $flashsitestoaddfile
$iecompatdatafile = $env:LOCALAPPDATA + "\Microsoft\Internet Explorer\IECompatData\iecompatdata.xml"
$outputpath = $env:LOCALAPPDATA + "\Microsoft\Internet Explorer\IECompatData"
$outputfileprefix = "\iecompatdata_part_"
$outputfileextension = ".xml"
$outputfilepartnumber = 1

#Remove temporary XML files if a previous script did not complete
Get-ChildItem $outputpath -filter *.xml | where{$_.FullName -ne $iecompatdatafile} | remove-item -force

#Get latest xml dynamically
#Currently you can retrieve it using: https://iecvlist.microsoft.com/ie10/201206/iecompatviewlist.xml
$urlpart1 = "https://iecvlist.microsoft.com/ie10/"
[int]$year = get-date -format yyyy
[int]$month = get-date -format MM
$urlpart3 = "/iecompatviewlist.xml"

$iecompatdatafile = $env:LOCALAPPDATA + "\Microsoft\Internet Explorer\IECompatData\iecompatdata.xml"


#Function to download the latest xml dynamically
#At January 5th 2013, the last version was: https://iecvlist.microsoft.com/ie10/201206/iecompatviewlist.xml
#This function however will get the latest available version based on the current computer date.

#Define the function
Function download-iecompatviewlist
{
    IF([int]$month -lt 10) #If month lesser than 10 (b.e. 9), add a 0 (b.e. 09) so it is conform the naming standard Microsoft uses.
    {
        $monthstring = "0" + [string]$month
    }

    #Construct the URL
    $urlpart2 = [string]$year+$monthstring
    $fullurl = $urlpart1+$urlpart2+$urlpart3

    #Check to see if there is an iecompatdata.xml in the current month
    $response = [net.webRequest]::create($fullurl).GetResponse()
    IF($response -ne $NULL) #If there is an iecompatdata.xml , download it.
    {
        $webclient = new-object System.Net.WebClient
        $webclient.DownloadFile($fullurl,$iecompatdatafile)
        #write-host "$fullurl : present"
    }
    ELSE #If there is no iecompatdata.xml, keep subtracting a month in the URL and re-run the function until the latest iecompatdata.xml is downnloaded.
    {
        #write-host "$fullurl : not present"
        IF($month -ne 1)
        {
            $month--
            download-iecompatviewlist
        }
        Else
        {
            $year--
            $month = 12
            download-iecompatviewlist
        }
    }
}
download-iecompatviewlist


#Read the content of $iecompatdatafilelines
$iecompatdatafilelines = get-content $iecompatdatafile -force

#Split the original $iecompatdatafile to seperate the part with the Flash whitelist website from the other parts
Foreach($line in $iecompatdatafilelines)
{
    #<domain>01net.com</domain>" is the first flash website and marks the part where the Flash whitelist part begins.
    #Would another flash website become the first flash website, then you need to modify this.
    #<NaturalTextMetrics> marks the part where the Flash whitelist part has ended.
    IF(($line -eq "        <domain>01net.com</domain>") -or ($line -eq "    <NaturalTextMetrics>"))
    {
        $outputfilepartnumber++
    }
    $outputfile = "$outputpath$outputfileprefix$outputfilepartnumber$outputfileextension"
    
    #If one has already manually added websites, these might not have been sorted yet. This will be performed for easier manahement.
    IF($line -eq "        <domain>01net.com</domain>")
    {
        #Store in a variable which outputfile contains the whitelisted flash websites.
        $flashpartfile = $outputfile
        $flashpartfilesorted = $flashpartfile + ".sorted"
    }

    #Write current line to the $outputfile
    $line | out-file -FilePath $outputfile -Append
}

#Get existing flash sites in the whitelist file
$flashpartfilecontent = get-content $flashpartfile -force

#Add your personally specified websites to whitelist to the iecompatdat flash part
$flashsitestoadd = Get-Content $flashsitestoaddfilefullpath -Force
Foreach($line in $flashsitestoadd)
{
    #Create line output
    $lineoutput = "        <domain>"+$line+"</domain>"

    #If flashsite already in iecompatdata, do not add (prevent duplicates).
    #Note: does not check if it is present only under the
    IF($flashpartfilecontent -notcontains $lineoutput)
    {
        #Write line output to file
        $lineoutput | Out-File $flashpartfile -Append -force
    }
}

#Create the new $flashpartfile with the closing </Flash> part
#Also it filters out duplicates that would otherwise occur due to re-running the script.
Get-Content $flashpartfile | unique | sort | out-file $flashpartfilesorted -Append
"    </Flash>" | out-file $flashpartfilesorted -Append -force

#Remove the unsorted $flashpartfile
Remove-Item $flashpartfile

#Rename $flashpartfilesorted to $flashpartfile
Rename-Item $flashpartfilesorted $flashpartfile

#Combine all parts to generate a new $iecompatdatafile with UTF8 encoding
#UTF8 encoding is necessary to make it work and.
$xmlfiles = (Get-ChildItem $outputpath -filter *.xml | where{$_.FullName -ne $iecompatdatafile}).FullName | sort
$newiecompatdatafile = $iecompatdatafile + ".new"
Foreach($xmlfile in $xmlfiles)
{
    $lines = get-content -Path $xmlfile -force
    Foreach($line in $lines)
    {
        $line | out-file $newiecompatdatafile -Append -force -Encoding UTF8
    }
}

#Rename the original $iecompatdatafile to .backup<date>
$filedate = get-date -format "dd-MM-yyyy_HH.mm"
$iecompatdatafilebackupname = $iecompatdatafile + "_" + $filedate
Rename-Item $iecompatdatafile $iecompatdatafilebackupname

#Rename $newiecompatdatafile to $iecompatdatafile
Rename-Item $newiecompatdatafile $iecompatdatafile

#Remove temporary XML files
Get-ChildItem $outputpath -filter *.xml | where{$_.FullName -ne $iecompatdatafile} | remove-item -force

#Clear Internet Explorer Browser history (otherwise the site might not work correctly)
[System.Diagnostics.Process]::Start("rundll32.exe", "InetCpl.cpl,ClearMyTracksByProcess 1")