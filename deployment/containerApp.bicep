// -----------
// Parameters
// -----------
param containerAppEnvironmentName string
param containerAppName string
param containerImageName string
param containerImageTag string // ghcr.io/username/namespace/containerImageName:tag
param containerPort int

param containerRegistryUri string //ghcr.io
param containerRegistryUsername string

#disable-next-line secure-secrets-in-params
param containerRegistryPassword string

param useExternalIngress bool = true

param storageAccountName string

param resourceLocation string = resourceGroup().location

// Configuration parameters
param SomeSection__SomeSensitiveString string
param SomeSection__SomeOtherSetting string

param containerapp_revision_uniqueid string = newGuid()
param containerAppProductionRevision string

// -----------
// Variables
// -----------
var containerAppEnvironmentId = resourceId('Microsoft.App/managedEnvironments', containerAppEnvironmentName)
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'

// -----------
// Resources
// -----------
resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: resourceLocation
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
          image: containerImageTag
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
