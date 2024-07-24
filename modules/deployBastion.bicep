targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Name of the vNet.')
param vNetName string

@description('Name of the Bastion Host resource.')
param bastionName string


resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vNetName
}

/*
    If the empty "tags" property is left out, the deployment of the Bastion resource with the Develepor sku
    will fail with an InternalServer error. Also note that the Developer sku is not yet available in the
    westeurope region, so make sure to deploy to a resource group that's located in the northeurope region.
    Deployment to a westeurope resource group will actually succeed, but Bastion connection attempts will fail.
*/
resource bastionHost 'Microsoft.Network/bastionHosts@2023-11-01' = {
  name: bastionName
  location: location
  tags: {}
  sku: {
    name: 'Developer'
  }
  properties: {
    virtualNetwork: {
      id: vNet.id
    }
  }
}
