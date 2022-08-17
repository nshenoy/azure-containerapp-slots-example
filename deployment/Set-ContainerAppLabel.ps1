[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $resourceGroupName,

    [Parameter(Mandatory=$true)]
    [string] $containerAppName
)

&az config set extension.use_dynamic_install=yes_without_prompt

# fetch latest revision
Write-Host "Finding latest revision..."
$latestRevision = (&az containerapp revision list -g $resourceGroupName -n $containerAppName --query "reverse(sort_by([].{name:name, date:properties.createdTime},&date))[0].name" -o tsv)

Write-Host "Latest revision: $latestRevision"

# Find revision with label of "staging" and remove revision.
Write-Host "Finding staging revision..."
$stagingRevision = (&az containerapp ingress show -g $resourceGroupName -n $containerAppName --query 'traffic[?label == `staging`].revisionName' -o tsv)

Write-Host "Finding production revision..."
$productionRevision = (&az containerapp ingress show -g $resourceGroupName -n $containerAppName --query 'traffic[?label == `production`].revisionName' -o tsv)


if([System.String]::IsNullOrEmpty($stagingRevision)) {
    Write-Host "No staging revision found."
} else {
    Write-Host "Staging revision: $stagingRevision"
    # Write-Host "Removing staging revision: $stagingRevision"
    # &az containerapp revision deactivate -g $resourceGroupName -n $containerAppName --revision $stagingRevision
    Write-Host "Removing staging label from revision: $stagingRevision"
    &az containerapp revision label remove -g $resourceGroupName -n $containerAppName --label staging
}

# Apply "staging" label to latest revision.
Write-Host "Applying staging label to latest revision..."
&az containerapp revision label add -g $resourceGroupName -n $containerAppName --label staging --revision "$latestRevision" --no-prompt --yes

# Write-Host "Setting traffic weights..."
if([System.String]::IsNullOrEmpty($productionRevision)) {
    &az containerapp ingress traffic set -g $resourceGroupName -n $containerAppName --revision-weight latest=100 --label-weight staging=0
} else {
    &az containerapp ingress traffic set -g $resourceGroupName -n $containerAppName --label-weight production=100 staging=0
}
