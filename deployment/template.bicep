// -----------
// Parameters
// -----------
param containerAppEnvName string
param containerAppName string
param containerPort int = 8080
param containerImageName string
param containerImageTag string // ghcr.io/username/namespace/containerImageName:tag
param containerRegistryUri string
param containerRegistryUsername string

#disable-next-line secure-secrets-in-params
param containerRegistryPassword string

param containerAppProductionRevision string = 'none'

param resourceLocation string = resourceGroup().location

param storageAccountName string

param SomeSection__SomeSensitiveString string
param SomeSection__SomeOtherSetting string

// -----------
// Resources
// -----------
module storage 'storage.bicep' = {
  name: storageAccountName
  params: {
    location: resourceLocation
    storageAccountName: storageAccountName
  }
}

module containerAppExisting 'containerApp.bicep' = {
  name: containerAppName
  params: {
    containerAppName: containerAppName
    containerAppEnvironmentName: containerAppEnvName
    containerImageName: containerImageName
    containerImageTag: containerImageTag
    containerAppProductionRevision: containerAppProductionRevision
    containerPort: containerPort
    containerRegistryUri: containerRegistryUri
    containerRegistryUsername: containerRegistryUsername
    containerRegistryPassword: containerRegistryPassword
    SomeSection__SomeSensitiveString: SomeSection__SomeSensitiveString
    SomeSection__SomeOtherSetting: SomeSection__SomeOtherSetting
    storageAccountName: storageAccountName
    location: resourceLocation
  }
  dependsOn: [
    storage
  ]
}
