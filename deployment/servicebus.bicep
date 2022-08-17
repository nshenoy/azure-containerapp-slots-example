// -----------
// Parameters
// -----------
param commandQueueName string
param commandQueuePolicy string 
param serviceBusNamespace string

var queueName = '${serviceBusNamespace}/${commandQueueName}'
var policyName = '${queueName}/${commandQueuePolicy}'

// -----------
// Resources
// -----------
resource sbnsQueue 'Microsoft.ServiceBus/namespaces/queues@2017-04-01' = {
  name: queueName
  properties: {
    maxDeliveryCount: 10
    maxSizeInMegabytes: 1024
  }
}

resource sbnsQueuePolicy 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2017-04-01' = {
  name: policyName
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}
