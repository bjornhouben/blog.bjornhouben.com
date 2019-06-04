<########################################################################################

Name		:	Pretty up movie names.ps1
Date		:	September 9th 2012
Author		:	Bjorn Houben
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:           Rename movie files to a format that is better recognized by YAMJ (Yet Another Movie Jukebox) and also to make the file names prettier.
			    It does so by removing dots (".") and removing everything after the year.
			    An example of correct behaviour is that "Tropa.de.Elite.Elite.Squad.2007.blu-ray.x264.720P.DTS-CHD.mkv" is being renamed to "Tropa de Elite Elite Squad 2007.mkv"

Assumptions	:	This script assumes the input files are in the format : <name>.<year>.<720p or 1080p>.<format>.<source><-releasegroup>

Known issues:		All dots in a file name will be removed, even when they are part of the movie name and should not be removed.
			In by example the movie "Catch .44" with filename catch..44.2011.720p.bluray.x264.dts-releasegroup.mkv the result would be "catch 44 2011".

Limitations	:	The script is unable to detect whether a dot is part of a movie name or not and will therefore remove all dots in a file name.

Notes   	:	1. Modify the personal variables in the script so the correct paths will be used for your purpose.
			2. A log file is being created that contains the old file name and the new file name. So should the renaming go wrong, you will always be able to correlate between the old and new name.
                	3. For more information on running powershell scripts, check http://technet.microsoft.com/en-us/library/ee176949.aspx
			4. Ensure you have sufficient permissions.

Disclaimer	:	    This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	Check for dots grouped together and then leave only one of those.

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	September 09 2012	:	Created script
 
########################################################################################>

#Define personal variables
$filepath = "Z:\shares\Videos\Movies to rename"
$logfilefolder = "Z:\shares\Data\Batch\"
$logfile = "Renamed_downloaded_movies.csv"

#Other variables needed for correct functioning of the script
$logfilefullpath = $logfilefolder + $logfile
$oldcharactertoreplace = "."
$newcharacter = " "
$yearsearch = "1[9][0-9][0-9]|2[0][0-9][0-9]" 
    #regex to find 4 digit number between 1900 and 2099
    #http://www.codeproject.com/Articles/206330/Learning-REGEX-regular-expression-in-the-most-easi
$files = Get-ChildItem $filepath <#-Recurse#> -force | Where-Object {!$_.PSIsContainer}
    #Recurse has been disabled in this example


#Define Function to remove text after specific string. Source: http://stackoverflow.com/questions/5831479/powershell-remove-text-from-end-of-string
function Remove-TextAfter
{   
    param (
        [Parameter(Mandatory=$true)]
        $string, 
        [Parameter(Mandatory=$true)]
        $value,
        [Switch]$Insensitive
    )

    $comparison = [System.StringComparison]"Ordinal"
    if($Insensitive) 
    {
        $comparison = [System.StringComparison]"OrdinalIgnoreCase"
    }

    $position = $string.IndexOf($value, $comparison)

    #manipulate the cutoff if necessary
    $newposition = $position

    if($position -ge 0) 
    {
        $string.Substring(0, $newposition + $value.Length)
    }
}

#Re-iterate each file in the $files array and perform the rename function
Foreach($file in $files)
{

   #Replace character in filename
   $fileextension = $file.extension
   $filebasename = $file.BaseName
   $filelength = $file.length
   $filebasenamewithcharactersreplaced = $filebasename.Replace($oldcharactertoreplace,$newcharacter)
   
   #Define $year by extracting only the part of the string that matches $yearsearch
   $year = $filebasename | select-string -pattern $yearsearch -AllMatches | % { $_.Matches } | % { $_.Value }

   IF($year -ne $null)
   {    
        #Define $moviename to match the new desired moviename to be used for the file name
        $moviename = Remove-TextAfter $filebasenamewithcharactersreplaced $year

        #Define $newfilennamecomplete to match the desired $moviename + the $fileextension
        $newfilenamecomplete = "$moviename$fileextension"
        
   }
   ELSE
   {
        #When no year has been detected, $filebasenamewithcharactersreplaced cannot be split

        #Define $moviename to match the new desired moviename to be used for the file name
        $moviename = $filebasenamewithcharactersreplaced

        #Define $newfilennamecomplete to match the desired $moviename + the $fileextension
        $newfilenamecomplete = "$moviename$fileextension"
   }

   #Write log of processed files with old file name, new file name and process date/time
   #Should something have gone wrong, you can check what the old name was
   $date = get-date -f dd-MM-yyyy
   $time = get-date -f hh:mm

   #Write info to log file
   "$date;$time;$newfilenamecomplete;$filebasename$fileextension;$filelength" | out-file -filepath $logfilefullpath -encoding ASCII -append
   
   #write info to console window
   write-host "$newfilenamecomplete;$filebasename"
   
   #Perform the actual rename
   $file | Rename-Item -NewName $newfilenamecomplete
}