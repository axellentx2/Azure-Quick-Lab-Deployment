targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vNetName string


resource defaultNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'default-nsg'
  location: location
}

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }

  resource defaultSubnet 'subnets' = {
    name: 'default'
    properties: {
      addressPrefix: '10.0.0.0/24'
      networkSecurityGroup: {
        id: defaultNsg.id
      }
    }
  }
}
