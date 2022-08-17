// -----------
// Parameters
// -----------
param containerAppEnvironmentName string
param containerAppName string
param containerPort int
param containerImageName string
param containerNamespace string
param containerRevisionSuffix string // 0.1.25
param containerRegistrySubscriptionId string

param containerRegistry string // mimeocommon-acr
param containerRegistryResourceGroup string

param useExternalIngress bool = true

param storageAccountName string

param location string

// Configuration parameters
param SomeSection__SomeSensitiveString string
param SomeSection__SomeOtherSetting string

param containerapp_revision_uniqueid string = newGuid()
param containerAppProductionRevision string

// -----------
// Variables
// -----------
var containerAppEnvironmentId = resourceId('Microsoft.App/managedEnvironments', containerAppEnvironmentName)
var containerRegistryId = resourceId(containerRegistrySubscriptionId, containerRegistryResourceGroup, 'Microsoft.ContainerRegistry/registries', containerRegistry)
var containerRegistryUsername = listCredentials(containerRegistryId, '2022-02-01-preview').username
var containerRegistryPassword = listCredentials(containerRegistryId, '2022-02-01-preview').passwords[0].value
var containerRegistryUri = '${containerRegistry}.azurecr.io'
var containerImage = '${containerRegistryUri}/${containerNamespace}/${containerImageName}:${containerRevisionSuffix}'
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'

// -----------
// Resources
// -----------
resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      activeRevisionsMode: 'multiple'      
      ingress: containerAppProductionRevision != 'none' ? {
        external: useExternalIngress
        targetPort: containerPort
        transport: 'auto'
        traffic: [
          {
            latestRevision: true
            label: 'staging'
            weight: 0
          }
          {
            revisionName: containerAppProductionRevision
            label: 'production'
            weight: 100
          }
        ]
      } : {
        external: useExternalIngress
        targetPort: containerPort
        transport: 'auto'
      }
      registries: [
        {
          server: containerRegistryUri
          username: containerRegistryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistryPassword
        }
        {
          name: 'somesection-somesensitivestring'
          value: SomeSection__SomeSensitiveString
        }
        {
          name: 'storageaccount-connectionstring'
          value: storageAccountConnectionString
        }
      ]      
    }
    template: {
      containers: [
        {          
          image: containerImage
          name: containerImageName
          env: [
            {
              name: 'SomeSection__SomeSensitiveString'
              secretRef: 'somesection-somesensitivestring'
            }
            {
              name: 'SomeSection__SomeOtherSetting'
              value: SomeSection__SomeOtherSetting
            }
            {
              name: 'StorageAccount__ConnectionString'
              secretRef: 'storageaccount-connectionstring'
            }
            {
              name: 'containerapp_revision_uniqueid'
              value: containerapp_revision_uniqueid
            }
          ]
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
