[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $resourceGroupName,

    [Parameter(Mandatory=$true)]
    [string] $containerAppName
)

az config set extension.use_dynamic_install=yes_without_prompt

# Finding production revision..."
$productionRevision = (&az containerapp ingress show -g $resourceGroupName -n $containerAppName --query 'traffic[?label == `production`].revisionName' -o tsv)

if([System.String]::IsNullOrEmpty($productionRevision)) {
    $productionRevision = "none"
} 

return $productionRevision
