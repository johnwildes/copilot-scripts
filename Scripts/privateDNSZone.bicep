param privateDnsZoneNames array = [
    'privatelink.api.azureml.ms'
    'privatelink.notebooks.azure.net'
    'privatelink.cognitiveservices.azure.com'
    'privatelink.openai.azure.com'
    'privatelink.directline.botframework.com'
    'privatelink.token.botframework.com'
    'privatelink.azuredatabricks.net'
    'privatelink.database.windows.net'
    'privatelink.documents.azure.com'
    'privatelink.azure-automation.net'
    'privatelink.monitor.azure.com'
    'privatelink.oms.opinsights.azure.com'
    'privatelink.ods.opinsights.azure.com'
    'privatelink.agentsvc.azure-automation.net'
    'privatelink.blob.core.windows.net'
    'privatelink.table.core.windows.net'
    'privatelink.queue.core.windows.net'
    'privatelink.file.core.windows.net'
    'privatelink.azure.com'
    'privatelink.vaultcore.azure.net'

]

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2021-05-01' = [for name in privateDnsZoneNames: {
    name: name
    location: resourceGroup().location
    properties: {
        registrationVirtualNetworks: [
            {
                id: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}'
            }
        ]
    }
}]
