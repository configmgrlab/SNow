function ConvertTo-JSKJiraBase64 {
    <#
    .SYNOPSIS
    This advanced function converts a string to a Base64 string
    
    .DESCRIPTION
    This advanced function converts a string to a Base64 string. The function requires a string and an encoding. The function will convert the string to a byte array and then to a Base64 string. The function will output the Base64 string.
    
    .PARAMETER String
    The string to convert to Base64
    
    .PARAMETER Encoding
    The encoding to use (Default is UTF8)
    
    .EXAMPLE
    ConvertTo-JSKJiraBase64 -String 'Hello, World!' -Encoding 'UTF8'
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        # The string to convert to Base64
        [Parameter(Mandatory)]
        [string]
        $String,

        # The encoding to use
        [Parameter(Mandatory=$false)]
        [ValidateSet("ASCII","BigEndianUnicode","Default","Latin1","Unicode","UTF32","UTF7","UTF8")]
        [string]
        $Encoding = 'UTF8'
    )
    
    begin {} # Begin
    
    process {
        # Convert the string to a byte array
        $Bytes = [System.Text.Encoding]::$Encoding.GetBytes($String)

        # Convert the byte array to a Base64 string
        $Base64 = [System.Convert]::ToBase64String($Bytes)

        # Output the Base64 string
        Write-Output $Base64
        
    } # Process
    
    end {} # End
}