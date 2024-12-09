function Get-JSKJiraUser {
    param (
        # User mail
        [Parameter(Mandatory)]
        [string]
        $UserMail
    )
    
    begin {
        # Check if Connect-JSKJira has been run
        if (-not $BaseUrl -or -not $BaseHeaders) {
            throw "Connect-JSKJira has not been run. Please run Connect-JSKJira first."
        }
    }

    process {
        # Create the URL
        $Url = '{0}/user/search?query={1}' -f $BaseUrl, $UserMail

        # Invoke the REST API
        $Response = Invoke-RestMethod -Uri $Url -Headers $BaseHeaders -Method Get

        # Output the response
        Write-Output $Response
    }

    end {}
}