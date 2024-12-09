function Get-JSKJiraProject {
    <#
    .SYNOPSIS
    This advanced function gets all projects from Jira
    
    .DESCRIPTION
    This advanced function gets all projects from Jira. The function requires that Connect-JSKJira has been run. The function will create the URL to get all projects and invoke the REST API. The function will output the response from the REST API.
    
    .EXAMPLE
    Get-JSKJiraProject
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param ()
    
    begin {
        # Check if Connect-JSKJira has been run
        if (-not $BaseUrl -or -not $BaseHeaders) {
            throw "Connect-JSKJira has not been run. Please run Connect-JSKJira first."
        }
    }
    
    process {
        # Create the URL
        $Url = '{0}/project' -f $script:BaseUrl

        # Invoke the REST API
        $Response = Invoke-RestMethod -Uri $Url -Headers $BaseHeaders -Method Get

        # Output the response
        Write-Output $Response
    }
    
    end {}
}