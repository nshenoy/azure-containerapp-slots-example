// -----------
// Parameters
// -----------
@maxLength(24)
param storageAccountName string

param location string

// -----------
// Resources
// -----------
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    encryption: {
      services:{
        blob: {
          enabled: true
        }
        file:{
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

