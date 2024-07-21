targetScope = 'resourceGroup'

param vNetName string
param bastionName string
param adminUsername string

@secure()
param adminPassword string

param vmConfigList array

@description('The ID of the time zone. For a list of all the available time zones, use the following PowerShell command: Get-TimeZone -ListAvailabe')
param timeZoneId string


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
    adminUsername: adminUsername
    adminPassword: adminPassword
    timeZoneId: timeZoneId
  }
  dependsOn: [
    vNet
  ]
}]
