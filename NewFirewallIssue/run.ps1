using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Import required modules
Import-Module JSKJira

# Get the request body
Get-Command -Module JSKJira

# Get jira token from key vault
$Token = Get-AzKeyVaultSecret -VaultName $Env:KeyVaultName -Name $Env:SecretName -AsPlainText
$JiraUser = Get-AzKeyVaultSecret -VaultName $Env:KeyVaultName -Name $Env:JiraUser -AsPlainText

$PAT = ConvertTo-SecureString -String $Token -AsPlainText -Force

# Short description
$ShortDescription = 'New firewall rule for {0}' -f $Request.Body.SystemName

# Description should be a detailed description of the request, and list each port and protocol that needs to be opened.
# Every port should be listed in the format "Port: <port number>, Protocol: <protocol>" (e.g. "Port: 80, Protocol: TCP")
# The description has to be in the following format: "Source: <source> `nDestination: <destination> `nPorts: `n<port1> `n<port2> `n<port3> `nReason: <reason> `nTechnical Details: <technical details> `nExpiration Date: <expiration date>"
$Description = "Reason: `n$($Request.Body.Reason)`n`nTechnical Details: `n$($Request.Body.TechnicalDetails)`n`nSource: `n$($Request.Body.Source)`n`nDestination: `n$($Request.Body.Destination)`n`nPorts: `n$(($Request.Body.Ports | ForEach-Object { "Port: $($_.ports_mrv), Protocol: $($_.tcp_mrv)" }) -join "`n")`n`nExpiration Date: `n$($Request.Body.ExpirationDate)"


# Convert Date
$SLADate = Get-Date -Date $Request.Body.SLA -Format yyyy-MM-dd

# Splatting for the New-JSKJiraIssue cmdlet
$Splat = @{
    ProjectId           = 'ITOPS'
    IssueType           = 'Task'
    Priority            = 'Low'
    AssignmentGroup     = 'ITNetwork'
    ShortDescription    = $ShortDescription
    Description         = $Description
    ServiceNowRequestId = $Request.Body.ServiceNowRequestId
    UserMail            = $Request.Body.UserMail
    Environment         = $Request.Body.Environment
    SLA                 = $SLADate
}

# Connect to Jira
Connect-JSKJira -PAT $PAT -UserName $JiraUser -Server $Request.Body.Environment

# Create a new Jira issue
$Issue = New-JSKJiraIssue @Splat

# Create a response body
$body = @{
    IssueKey = $Issue
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
