# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    
    # Get Jira token from vault
    $Token = Get-AzKeyVaultSecret -VaultName $Env:KeyVaultName -Name $Env:SecretName -AsPlainText
    $JiraUser = Get-AzKeyVaultSecret -VaultName $Env:KeyVaultName -Name $Env:JiraUser -AsPlainText

    $PAT = ConvertTo-SecureString -String $Token -AsPlainText -Force

    # Connect to Jira
    Connect-JSKJira -PAT $PAT -UserName $JiraUser -Server Dev

    # Get all issues
    $Issues = Get-JSKJiraIssue -Query '"ServiceNow ID[Short text]" IS NOT EMPTY AND resolved >= "-5d"'

    # Get all issues from ServiceNow
    $Header = @{
        'Authorization' = 'Basic {0}' -f [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes('{0}:{1}' -f $Env:ServiceNowUser, $Env:ServiceNowSecret))
        'Accept' = 'application/json'
    }

    $Uri = "https://itsmtest.jysk.com/api/now/table/sc_request?sysparm_query=u_jira_issueISNOTEMPTY%5Erequest_stateINrequested%2Cin_process&sysparm_limit=1"

    $Params = @{
        Uri     = $Uri
        Headers = $Header
        Method  = 'Get'
    }

    $ServiceNowIssues = Invoke-RestMethod @Params

    # Loop through all jiira issues and get the ServiceNow ID
    $ServiceNowReq = foreach ($Issue in $Issues.issues) {

        # Get ServiceNow request ID
        $Issue.fields.

    }

    # Loop through all ServiceNow issues and get the Jira ID

}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
