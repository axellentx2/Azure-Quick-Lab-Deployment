targetScope = 'resourceGroup'

param vNetName string
param bastionName string
param vmConfigList array


module vNet 'modules/deployvNet.bicep' = {
  name: 'deployvNet'
  params: {
    vNetName: vNetName
  }
}

module bastion 'modules/deployBastion.bicep' = {
  name: 'deployBastion'
  params: {
    bastionName: bastionName
    vNetName: vNetName
  }
  dependsOn: [
    vNet
  ]
}

module VM 'modules/deployVM.bicep' = [for vmConfig in vmConfigList: {
  name: 'depploy${vmConfig.vmName}'
  params: {
    vNetName: vNetName
    vmName: vmConfig.vmName
    vmSize: vmConfig.vmSize
    adminUsername: vmConfig.adminUsername
    adminPassword: vmConfig.adminPassword
  }
  dependsOn: [
    vNet
  ]
}]
