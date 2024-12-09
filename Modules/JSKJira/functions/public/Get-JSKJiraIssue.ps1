function Get-JSKJiraIssue {
    <#
    .SYNOPSIS
    This advanced function retrieves one or more Jira issues.
    
    .DESCRIPTION
    This advanced function retrieves one or more Jira issues. The function can be used to retrieve a single issue by issue key or multiple issues by using a JQL query.
    
    .PARAMETER IssueKey
    Issue key of the issue to retrieve
    
    .PARAMETER Query
    JQL query to retrieve multiple issues
    
    .EXAMPLE
    this example retrieves a single issue with the key ITOPS-1234
    Get-JSKJiraIssue -IssueKey 'ITOPS-1234'

    .EXAMPLE
    this example retrieves all issues with a ServiceNow id and that have been resolved in the last 30 days
    Get-JSKJiraIssue -Query '"ServiceNow id" IS NOT EMPTY AND resolved > -30d'
    
    .NOTES
    NAME: Get-JSKJiraIssue
    #>
    [CmdletBinding()]
    param (
        # The issue key
        [Parameter(Mandatory, ParameterSetName='IssueKey')]
        [string]
        $IssueKey,

        # Query string
        [Parameter(Mandatory, ParameterSetName='Query')]
        [string]
        $Query
    )
    
    begin {
        # Check if Connect-JSKJira has been run
        if (-not $BaseUrl -or -not $BaseHeaders) {
            throw "Connect-JSKJira has not been run. Please run Connect-JSKJira first."
        }
    } # Begin
    
    process {
        # Create the URL
        #$Url = '{0}/issue/{1}' -f $BaseUrl, $IssueKey

        $URL = switch ($PSCmdlet.ParameterSetName) {
            'IssueKey' { '{0}/issue/{1}' -f $BaseUrl, $IssueKey }
            'Query' { '{0}/search?jql={1}' -f $BaseUrl, $Query }
        }

        # Invoke the REST API
        $Response = Invoke-RestMethod -Uri $Url -Headers $BaseHeaders -Method Get

        # Output the response
        Write-Output $Response

    } # Process
    
    end {} # End
}