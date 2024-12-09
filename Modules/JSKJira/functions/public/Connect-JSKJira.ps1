function Connect-JSKJira {
    <#
    .SYNOPSIS
    This advanced function connects to the Jira API
    
    .DESCRIPTION
    This advanced function connects to the Jira API. It requires a username and a Personal Access Token (PAT) to authenticate. The function also requires the Jira server to connect to. The function will create a base64 encoded credential object and configure the base URL for the Jira API. The function will also create a header object to be used in the API calls.
    
    .PARAMETER UserName
    Username to authenticate with the Jira API
    
    .PARAMETER PAT
    Personal Access Token to authenticate with the Jira API
    
    .PARAMETER Server
    The Jira server to connect to. The server can be either 'Prod' or 'Dev'
    
    .EXAMPLE
    Connect-JSKJira -UserName 'jsmith@jysk.com' -PAT $PAT -Server 'Prod'
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        # username
        [Parameter(Mandatory)]
        [string]
        $UserName,

        # Personal Access Token
        [Parameter(Mandatory)]
        [securestring]
        $PAT,

        # Jira Server
        [Parameter(Mandatory)]
        [ValidateSet('Prod', 'Dev')]
        [string]
        $Server
    )
    
    begin {
        switch ($Server) {
            Prod { $InstanceName = 'jysk' }
            Dev { $InstanceName = 'jysk-sandbox-974' }
        }
    } # Begin
    
    process {

        # Create the credential object
        $Credential = ConvertTo-JSKJiraBase64 -String ('{0}:{1}' -f $UserName, (ConvertFrom-SecureString -SecureString $PAT -AsPlainText))

        # Configure the base URL
        $BaseUrl = 'https://{0}.atlassian.net/rest/api/3' -f $InstanceName

        # Create Jira Header
        $Headers = @{
            Authorization = 'Basic {0}' -f $Credential
        }

        # Add base header to script scope
        $script:BaseHeaders = $Headers
        $script:BaseUrl = $BaseUrl
        $script:Environment = $Server

        Write-Output "Connected to Jira Server: $Server"
    } # Process
    
    end {} # End
}