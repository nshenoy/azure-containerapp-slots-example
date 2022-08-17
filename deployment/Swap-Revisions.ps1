[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $resourceGroupName,

    [Parameter(Mandatory=$true)]
    [string] $containerAppName
)

&az config set extension.use_dynamic_install=yes_without_prompt

Write-Host "Finding staging revision..."
$stagingRevision = (&az containerapp ingress show -g $resourceGroupName -n $containerAppName --query 'traffic[?label == `staging`].revisionName' -o tsv)

Write-Host "Staging revision: $stagingRevision"

Write-host "Finding production revision..."
$productionRevision = (&az containerapp ingress show -g $resourceGroupName -n $containerAppName --query 'traffic[?label == `production`].revisionName' -o tsv)

if([System.String]::IsNullOrEmpty($productionRevision)) {
    Write-Host "No production revision found."
    Write-Host "Applying production label to staging revision..."
    &az containerapp revision label add -g $resourceGroupName -n $containerAppName --label production --revision $stagingRevision
} else {
    Write-Host "Production revision: $productionRevision"
    Write-Host "Swapping staging and production revisions..."
	&az containerapp revision label swap -g $resourceGroupName -n $containerAppName --source staging --target production
}

# set traffic for production=100 and staging=0
Write-Host "Setting traffic for production=100 and staging=0..."
if([System.String]::IsNullOrEmpty($productionRevision)) {
    &az containerapp ingress traffic set -g $resourceGroupName -n $containerAppName --label-weight production=100
} else {
    &az containerapp ingress traffic set -g $resourceGroupName -n $containerAppName --label-weight production=100 staging=0
}

Write-Host "Swap complete!"