function New-JSKJiraIssue {
    <#
    .SYNOPSIS
    This advanced function creates a new issue in Jira
    
    .DESCRIPTION
    This advanced function creates a new issue in Jira. The function requires a project ID, issue type, priority, assignment group, short description, description, ServiceNow request ID, user mail, environment, and SLA. The function will get the issue type ID, priority ID, project ID, and assignment group ID. The function will create the body for the API call and invoke the REST API. The function will output the response from the REST API.
    
    .PARAMETER ProjectId
    Project ID to create the issue in
    
    .PARAMETER IssueType
    Issue type to create the issue as
    
    .PARAMETER Priority
    Priority of the issue
    
    .PARAMETER AssignmentGroup
    Assignment group to assign the issue to
    
    .PARAMETER ShortDescription
    Short description of the issue
    
    .PARAMETER Description
    Description of the issue to create
    
    .PARAMETER ServiceNowRequestId
    ServiceNow request ID to link to the issue
    
    .PARAMETER UserMail
    Email of the requester
    
    .PARAMETER Environment
    Environment of the issue (Prod or Dev)
    
    .PARAMETER SLA
    SLA of the issue
    
    .EXAMPLE
    New-JSKJiraIssue -ProjectId 'ITOPS' -IssueType 'Task' -Priority 'Highest' -AssignmentGroup 'SAPBasis' -ShortDescription 'Test' -Description 'Test' -ServiceNowRequestId '1234' -UserMail 'jsmith@jysk.com' -Environment 'Prod' -SLA '4h'
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        # Project ID
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('ITOPS')]
        $ProjectId,

        # Issue Type
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('Task', 'SAP Transport', 'Deployment', 'Feature', 'Deployment', 'Story', 'Problem', 'Precondition', 'Idea', 'Development', 'Epic', 'Incident', 'Sub-task', 'Bug')]
        $IssueType,

        # Priority
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('Highest', 'High', 'Medium', 'Low', 'Lowest')]
        $Priority,

        # Assignment Group
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('SAPBasis', 'ITServer', 'ITNetwork', 'ITClientADM', 'ITClientMobility', 'ITClientStore', 'StoreOps', 'IT3rdLvl')]
        $AssignmentGroup,

        # Short Description
        [Parameter(Mandatory)]
        [string]
        $ShortDescription,

        # Description
        [Parameter(Mandatory)]
        [string]
        $Description,

        # ServiceNow Request ID
        [Parameter(Mandatory)]
        [string]
        $ServiceNowRequestId,

        # Requester User Mail
        [Parameter(Mandatory)]
        [string]
        $UserMail,

        # Environment
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('Prod', 'Dev')]
        $Environment,

        # ServiceNow SLA
        [Parameter(Mandatory)]
        [string]
        $SLA
    )
    
    begin {

        # Check if Connect-JSKJira has been run
        if (-not $BaseUrl -or -not $BaseHeaders) {
            throw "Connect-JSKJira has not been run. Please run Connect-JSKJira first."
        }

        # Get issue type id
        $IssueTypeId = switch ($IssueType) {
            Task {
                '10002'
            }
            'SAP Transport' {
                '10009'
            }
            Deployment {
                '10008'
            }
            Feature {
                '10000'
            }
            Story {
                '10001'  
            }
            Problem {
                '10101'
            }
            Idea { 
                '10022'
            }
            Development { 
                '10010'
            }
            Epic { 
                '10007'
            }
            Incident { 
                '10100'
            }
            'Sub-task' { 
                '10013'
            }
            Bug { 
                '10004'
            }
        }

        # Get priority id
        $JiraPriority = switch ($Priority) {
            Highest { @{ id = '1'; name = 'Highest' } }
            High { @{ id = '2'; name = 'High' } }
            Medium { @{ id = '3'; name = 'Medium' } }
            Low { @{ id = '4'; name = 'Low' } }
            Lowest { @{ id = '5'; name = 'Lowest' } }
        }

        # Get the project id
        $JiraProject = Switch ($ProjectId) {
            ITOPS { @{Name = 'IT Operations'; Id = '10022'; key = 'ITOPS' } }
        }

        # Assignment groups
        $JiraAssignmentGroup = switch ($AssignmentGroup) {
            'SAPBasis' {
                @{
                    'value' = 'SAP Basis'
                    'id'    = 10913
                }
            }
            'ITServer' {
                @{
                    'value' = 'IT Server Operations'
                    'id'    = 10977
                }
            }
            'ITNetwork' {
                @{
                    'value' = 'IT Network'
                    'id'    = 10978
                }
            }
            'ITClientADM' {
                @{
                    'value' = 'IT Client Infrastructure - Administrative'
                    'id'    = 11055
                }
            }
            'ITClientMobility' {
                @{
                    'value' = 'IT Client Infrastructure - Mobility & Mac'
                    'id'    = 11056
                }
            }
            'ITClientStore' {
                @{
                    'value' = 'IT Client Infrastructure - Stores'
                    'id'    = 10979
                }
            }
            'StoreOps' {
                @{
                    'value' = 'Store IT Operations'
                    'id'    = 10980
                }
            }
            'IT3rdLvl' {
                @{
                    'value' = 'IT 3rd Level Support (OPS)'
                    'id'    = 10981
                }
            }
        }
    }
    
    process {

        # Get the user
        $User = Get-JSKJiraUser -UserMail $UserMail

        # Create the URL
        $Url = '{0}/issue' -f $BaseUrl

        # Create the body
        # Customfield_10037 is the assignment group
        # Customfield_10077 is the SLA
        # Customfield_10073 is the labels
        # customfield_10097 is the ServiceNow request ID

        $Body = @{
            fields = @{
                project             = @{
                    id = $JiraProject.Id
                }
                issuetype           = @{
                    id = $IssueTypeId
                }
                priority            = @{
                    id   = $JiraPriority.id
                    name = $JiraPriority.name
                }
                "customfield_10037" = @{
                    value = $JiraAssignmentGroup.value
                }
                customfield_10073 = @(
                    @{
                        value = 'IT'
                    }
                )
                customfield_10077 = $SLA
                summary             = $ShortDescription 
                description         = @{
                    version = 1
                    type    = 'doc'
                    content = @(
                        @{
                            type    = 'paragraph'
                            content = @(
                                @{
                                    type = 'text'
                                    text = $Description
                                }
                            )
                        }
                    )
                }
                reporter            = @{
                    accountId = $User.accountId
                }
            }
        }

        switch ($Environment) {
            Prod {
                $Body.fields.Add('customfield_10097',$ServiceNowRequestId)
            }
            Dev {
                $Body.fields.Add('customfield_10132',$ServiceNowRequestId)
            }
        }

        # Convert the body to JSON
        $BodyRequest = $Body | ConvertTo-Json -Depth 10

        # Invoke the REST API
        $Response = Invoke-RestMethod -Uri $Url -Headers $BaseHeaders -Method Post -Body $BodyRequest -StatusCodeVariable StatusCode -ContentType 'application/json'

        # Output the response
        Write-Output $Response
        
    }
    
    end {
        
    }
}