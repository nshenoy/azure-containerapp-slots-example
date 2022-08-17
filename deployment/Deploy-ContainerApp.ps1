# Check to see if ContainerApp Az extension is installed
$isAzExtensionInstalled = (&az extension list --query "[?contains(name, 'containerapp')].name" -o tsv)
if ([string]::IsNullOrEmpty($isAzExtensionInstalled)) {
    Write-Host "Azure ContainerApp Extension is not installed. Installing..."
    &az extension add --name containerapp
}
else {
    Write-Host "Azure ContainerApp Extension is already installed"
}

$containerAppName = "dev-photos-pmi-usea-app"

# Check to see if container app exists
$containerAppResourceId = (&az containerapp list -g dev-photos-rg --query "[?contains(name, '$containerAppName')].id" -o tsv)
if ([string]::IsNullOrEmpty($containerAppResourceId)) {
    Write-Host "ContainerApp $containerAppName does not exist. Creating..."
} else {
    Write-Host "ContainerApp $containerAppName already exists. ResourceId: $containerAppResourceId"
}
