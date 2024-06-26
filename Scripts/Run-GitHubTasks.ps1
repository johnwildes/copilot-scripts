function Get-GitHubWorkflowLogs {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Owner,

        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [Parameter(Mandatory = $true)]
        [securestring]$Token

    )

    $workflowRunsUrl = "https://api.github.com/repos/$Owner/$Repo/actions/runs"
    $workflowRuns = Invoke-RestMethod -Uri $workflowRunsUrl -Headers @{ "Authorization" = $Token }

    $workflowRunIds = $workflowRuns.workflow_runs.id

    Write-Host "Available Workflow Runs:"
    $workflowRunIds | ForEach-Object {
        Write-Host "  $_"
    }

    $selectedWorkflowRunId = Read-Host "Enter the Workflow Run ID you want to view"

    $workflowLogsUrl = "https://api.github.com/repos/$Owner/$Repo/actions/runs/$selectedWorkflowRunId/logs"
    $workflowLogs = Invoke-RestMethod -Uri $workflowLogsUrl -Headers @{ "Authorization" = $Token }

    $workflowLogs
}
