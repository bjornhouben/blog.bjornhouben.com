Function Get-EnumValue
{
    <#
    .SYNOPSIS
        Determine possible values of a property / attribute of the [system.enum] type
        By example the possible values of startup type of a service.
    .DESCRIPTION
        Determine possible values of a property / attribute of the [system.enum] type
        By example the possible values of startup type of a service

        In some cases this can easily be determined if there is a "set-" version of the cmdlet.
        By example with Get-Service, there is also a Set-Service where the StartUpType values can be determined using "Get-Help Set-Service -Full" or by simply typing: Set-Service -StartupType and using auto completion. 

        In some cases this is however not possible and this function can be used.
    .PARAMETER EnumProperty
        Input a property of the [System.enum] type. By example: (Get-Date)[0].DayOfWeek or (Get-Service)[0].StartType')    
    .EXAMPLE
        $FormatEnumerationLimit=-1
        $Property1 = (Get-Date)[0].DayOfWeek
        $Property2 = (Get-Service)[0].StartType
        Get-EnumValue -EnumProperty $Property1,$Property2
            
        Description
    
        -----------
    
        Set $FormatEnumerationLimit to -1 to prevent cutoff of the results.
        Store 2 properties in variables and use the Get-EnumValue function with the named parameter -EnumProperty to enumerate their values. 
    .EXAMPLE
        $FormatEnumerationLimit=-1
        Get-EnumValue -EnumProperty (Get-Date)[0].DayOfWeek,(Get-Service)[0].StartType
            
        Description
    
        -----------
    
        Set $FormatEnumerationLimit to -1 to prevent cutoff of the results.
        Use the Get-EnumValue function with the named parameter -EnumProperty to enumerate their values without first storing them in variables.
    .EXAMPLE
        $FormatEnumerationLimit=-1
        $Properties = @((Get-Date)[0].DayOfWeek,(Get-Service)[0].StartType)
        Get-EnumValue -EnumProperty $Properties
            
        Description
    
        -----------
    
        Set $FormatEnumerationLimit to -1 to prevent cutoff of the results.
        Store 2 properties in a single array and use the Get-EnumValue function with the named parameter -EnumProperty to enumerate the values of the properties in the array. 
    .EXAMPLE
        $FormatEnumerationLimit=-1
        (Get-Date)[0].DayOfWeek,(Get-Service)[0].StartType | Get-EnumValue | Format-Table    
    
        Description
    
        -----------
    
        Set $FormatEnumerationLimit to -1 to prevent cutoff of the results.
        Put 2 properties in the pipeline and pipe them to Get-EnumValue to get their values.
    .NOTES
        1) By default, the EnumValues are truncated like this for format-list, format-table, etc:

        For Format-List:

        TypeName   : System.DayOfWeek
        EnumValues : {Sunday, Monday, Tuesday, Wednesday...}

        TypeName   : System.ServiceProcess.ServiceStartMode
        EnumValues : {Boot, System, Automatic, Manual...}

        For Format-Table:

        TypeName                               EnumValues                             
        --------                               ----------                             
        System.DayOfWeek                       {Sunday, Monday, Tuesday, Wednesday...}
        System.ServiceProcess.ServiceStartMode {Boot, System, Automatic, Manual...} 

        By setting $FormatEnumerationLimit to -1 all values will be shown (https://blogs.technet.microsoft.com/heyscriptingguy/2011/11/20/change-a-powershell-preference-variable-to-reveal-hidden-data/):        $FormatEnumerationLimit=-1

        2) This example uses [Enum]::GetValues but it can easily be modified to use [Enum]::GetNames

        3) Additional information and resources:
        http://social.technet.microsoft.com/wiki/contents/articles/26436.how-to-create-and-use-enums-in-powershell.aspx#UsingEnumsWiithFunction
        https://msdn.microsoft.com/en-us/library/system.enum.getnames(v=vs.110).aspx
        https://msdn.microsoft.com/en-us/library/system.enum.getvalues(v=vs.110).aspx
#>
    [CmdletBinding()] #Provides advanced functionality. For more details see "What does PowerShell's [CmdletBinding()] Do?" : http://www.windowsitpro.com/blog/powershell-with-a-purpose-blog-36/windows-powershell/powershells-[cmdletbinding]-142114
    Param
    (
        [Parameter(Mandatory=$true, #Parameter is mandatory.
                   ValueFromPipeline=$True, #Allows pipeline input.
                   Position=0, #Allows function to be called without explicitly specifying parameters, but instead using positional parameters in the correct order
                   HelpMessage='Input an object of the [System.enum] type. By example: (Get-Date)[0].DayOfWeek or (Get-Service)[0].StartType')] #Enter a help message to be shown when no parameter value is provided.
        [ValidateNotNullOrEmpty()] #Validate the input is not NULL or empty
        [ValidateScript({$_ -is [System.Enum]})] #Validate whether or not the input is actually of the [System.enum] type.
        [System.enum[]]$EnumProperty
    )
    BEGIN
    {
    }
    PROCESS
    {
        $Output = @()
        Foreach($object in $EnumProperty)
        {
            TRY
            {
                $TypeName = ($object | Get-Member)[0].TypeName
                
                $EnumValues = [Enum]::GetValues($TypeName) #Pre-PowerShell 3.0
             
                $ObjectEnumResult = New-Object PSCustomObject -Property @{
                'TypeName' = $TypeName
                'EnumValues' = $EnumValues
                }      
                $Output += $ObjectEnumResult
            }
            CATCH
            {
                Write-Verbose "Error occurred processing $object"
            }
            FINALLY
            {
            }
        }

        #Send output to the pipeline
        $Output
    }
    END
    {
    }
}