// -----------
// Parameters
// -----------
param containerAppEnvName string
param containerAppName string
param containerPort int = 8080
param containerImageName string
param containerNamespace string
param containerRevisionSuffix string
param containerRegistry string
param containerRegistryResourceGroup string
param containerRegistrySubscriptionId string
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
    containerNamespace: containerNamespace
    containerRevisionSuffix: containerRevisionSuffix
    containerAppProductionRevision: containerAppProductionRevision
    containerPort: containerPort
    containerRegistry: containerRegistry
    containerRegistryResourceGroup: containerRegistryResourceGroup
    containerRegistrySubscriptionId: containerRegistrySubscriptionId
    SomeSection__SomeSensitiveString: SomeSection__SomeSensitiveString
    SomeSection__SomeOtherSetting: SomeSection__SomeOtherSetting
    storageAccountName: storageAccountName
    location: resourceLocation
  }
}
