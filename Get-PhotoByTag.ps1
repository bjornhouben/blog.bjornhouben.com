Function Get-FileMetaData
{
  # -----------------------------------------------------------------------------
  # Script: Get-FileMetaDataReturnObject.ps1
  # Author: ed wilson, msft
  # Date: 01/24/2014 12:30:18
  # Keywords: Metadata, Storage, Files
  # comments: Uses the Shell.APplication object to get file metadata
  # Gets all the metadata and returns a custom PSObject
  # it is a bit slow right now, because I need to check all 266 fields
  # for each file, and then create a custom object and emit it.
  # If used, use a variable to store the returned objects before attempting
  # to do any sorting, filtering, and formatting of the output.
  # To do a recursive lookup of all metadata on all files, use this type
  # of syntax to call the function:
  # Get-FileMetaData -folder (gci e:\music -Recurse -Directory).FullName
  # note: this MUST point to a folder, and not to a file.
  # -----------------------------------------------------------------------------

  <#
   .Synopsis
    This function gets file metadata and returns it as a custom PS Object 
   .Description
    This function gets file metadata using the Shell.Application object and
    returns a custom PSObject object that can be sorted, filtered or otherwise
    manipulated.
   .Example
    Get-FileMetaData -folder "e:\music"
    Gets file metadata for all files in the e:\music directory
   .Example
    Get-FileMetaData -folder (gci e:\music -Recurse -Directory).FullName
    This example uses the Get-ChildItem cmdlet to do a recursive lookup of 
    all directories in the e:\music folder and then it goes through and gets
    all of the file metada for all the files in the directories and in the 
    subdirectories.  
   .Example
    Get-FileMetaData -folder "c:\fso","E:\music\Big Boi"
    Gets file metadata from files in both the c:\fso directory and the
    e:\music\big boi directory.
   .Example
    $meta = Get-FileMetaData -folder "E:\music"
    This example gets file metadata from all files in the root of the
    e:\music directory and stores the returned custom objects in a $meta 
    variable for later processing and manipulation.
   .Parameter Folder
    The folder that is parsed for files 
   .Notes
    NAME:  Get-FileMetaData
    AUTHOR: ed wilson, msft
    LASTEDIT: 01/24/2014 14:08:24
    KEYWORDS: Storage, Files, Metadata
    HSG: HSG-2-5-14
   .Link
     Http://www.ScriptingGuys.com
 #Requires -Version 2.0
 #>
 Param([string[]]$folder)
 foreach($sFolder in $folder)
  {
   $a = 0
   $objShell = New-Object -ComObject Shell.Application
   $objFolder = $objShell.namespace($sFolder)

   foreach ($File in $objFolder.items())
    { 
     $FileMetaData = New-Object PSOBJECT
      for ($a ; $a  -le 266; $a++)
       { 
         if($objFolder.getDetailsOf($File, $a))
           {
             $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a))  =
                   $($objFolder.getDetailsOf($File, $a)) }
            $FileMetaData | Add-Member $hash
            $hash.clear() 
           } #end if
       } #end for 
     $a=0
     $FileMetaData
    } #end foreach $file
  } #end foreach $sfolder
} #end Get-FileMetaData

function Get-PhotoByTag
{
    <#
    .Synopsis
       Gets photos in a folder/directory that contain tags you specified.
    .DESCRIPTION
       Gets photos in a folder/directory that contain tags you specified.
       
       Use cases:
       1) Last summer I attended a large wedding in Serbia and a lot of photos were made during the day (2000+). At the evening, people could buy these photos. In general, people desired and bought only photos that contained the bride, groom and people they knew. With this function, the desired photos can easily be determined and copied based on the tags.
       2) I have a pet parrot called lucky. Pictures of him are scattered over numerous folders. Using this function, these photos can easily be determined.
    .PARAMETER Folder
        Enter the folder/directory that contains the photos you want to filter by tag.
    .Example
        Get-PhotoByTag


        Description
    
        -----------

        Run the function without paramaters. It will ask you to specify the folder that contains the photos.
    .EXAMPLE 
        Get-PhotoByTag -Folder 'D:\Photos\2014-02-13' -Verbose

        Description
    
        -----------

        Run the function with paramaters.
        The folder 'D:\Photos\2014-02-14' contains the photos.
        Verbose output is enabled to show more detailed information.
    .EXAMPLE
        'D:\Photos\2014-01-05','D:\Photos\2014-02-13' | Get-PhotoByTag -Verbose | Copy-Item -Destination "D:\Output" -force

        Description
    
        -----------

        Run the function with paramaters.
        The folder 'D:\Photos\2014-02-14' contains the photos.
        Verbose output is enabled to show more detailed information
        All photos containing the tags that are specified will be copied to 'D:\Output'
    .EXAMPLE
        $PhotoFolders = @('D:\Photos\2014-01-05','D:\Photos\2014-02-13')
        $TargetRootFolder = "D:\Output"
        Foreach($Folder in $PhotoFolders)
        {
            $DesiredPhotos = @(Get-PhotoByTag -Folder $Folder -Verbose)
            $FolderName = (($DesiredPhotos[0]).Split("\"))[-2]
            $TargetFolder = "$TargetRootFolder\$FolderName"

            IF((Test-Path -Path $TargetFolder) -ne $TRUE)
            {
                New-Item -ItemType Directory -Path $TargetFolder -Force
            }
            $DesiredPhotos | Copy-Item -Destination $TargetFolder -force
        }

        Description
    
        -----------

        Get the photos and meta data from the folders 'D:\Photos\2014-01-05' and 'D:\Photos\2014-02-13'
        Those photos that contain the tags you specifief will be copied to D:\Output in a folder a name similar to the source folder name.
        So by example from 'D:\Photos\2014-01-05' to 'D:\Output\2014-01-05'.
    .NOTES
        1) I expected the tags to be more easily available, but luckily Ed Wilson created the function Get-FileMetaData that I could leverage: http://gallery.technet.microsoft.com/scriptcenter/get-file-meta-data-function-f9e8d804
           See also : http://blogs.technet.com/b/heyscriptingguy/archive/2014/02/06/use-powershell-to-find-metadata-from-photograph-files.aspx 
        2) Keep in mind that the function may take some time when accessing files a (slow) network.
        3) If multiple tags are selected it will show photos that contain any of these tags. Photos do not have to contain both tags to be shown.
    #>
    [CmdletBinding()]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,
                   HelpMessage="Enter the folder/directory to get photos from. By example 'D:\Photos\2014-02-13'")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})] #Validate if the specified folder exists

        [Alias("Directory")]
        [String[]]$Folder
    )

    Begin
    {
    }
    Process
    {
      Foreach($Directory in $Folder)
      {
        Write-Verbose "Started processing folder : $Directory"

        #Get the metadata from all files in a folder
        $FilesAndTags = Get-FileMetaData -folder $directory

        $FolderName = $FilesAndTags[0].'Folder name' 

        #Get the unique tags. The standard string needs to be changed and split to get the desired outcome.
        $UniqueTags = (($FilesAndTags.tags).replace('; ',';')).split(';') | Select-Object -Unique | Sort-Object
        
        #Create an objects array to hold the future objects
        $Objects = @()

        #Create a new object where the tags from $FilesAndTags are not just a string, but array entries
        Foreach($Item in $FilesAndTags)
        {
          
          #Create a new array containing the tags for this item
          $ItemTags = (($Item.tags).replace('; ',';')).split(';') | Select-Object -Unique | Sort-Object
                      
          #Create a new pscustomobject containing the desired data
          $object=[pscustomobject][ordered]@{
              ItemPath = $Item.Path
              ItemTags = $ItemTags
          }
            
          #Add the object to the array of objects
          $objects += $object
        }

        #Create a variable to hold the desired files
        $DesiredFiles = @()

        #Use Out-GridView to have users select the desired tags
        $SelectedTags = @($UniqueTags | Out-Gridview -Title "Select the tags to filter on in directory: $directory. Hold down CTRL and select to select multiple tags." -PassThru)
        #$SelectedTags = @("Bjorn Houben","Lucky") #Static alternative to the Out-Gridview dynamic method described above.

        #Show verbose information for troubleshooting and verification
        Foreach($Tag in $SelectedTags)
        {
          Write-Verbose "Show files containing tag : '$Tag' in folder : '$Directory'"
        }

        #Foreach tag, go through the objects to see if they contain the tag and if so, add it to $DesiredFiles
        Foreach($SelectedTag in $SelectedTags) 
        {
          $DesiredFiles += ($objects | Where-Object{$_.ItemTags -contains "$SelectedTag"})
        }

        #Show verbose information for troubleshooting and verification
        Foreach($DesiredFile in $DesiredFiles)
        {
          Write-Verbose $($DesiredFile.ItemPath)
        }
        
        #Output the desired files to the pipeline
        $DesiredFiles.ItemPath | Select-Object -Unique
        
        Write-Verbose "Completed processing folder : $Directory"
      }
    }
    End
    {
    }
}