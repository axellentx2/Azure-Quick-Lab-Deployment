targetScope = 'resourceGroup'

@description('Name of the vNet.')
param vNetName string

@description('Name of the Bastion Host resource.')
param bastionName string

@description('Specifies whether to include the VM(s) in backup or not.')
param enableVmBackup bool

@description('Name of the recovery services vault. Can be left empty or left out if backup will not be enabled.')
param rsVaultName string = ''

@description('''
The ID of the time zone. For a list of all available time zone IDs, use the following PowerShell command:  
`Get-TimeZone -ListAvailabe | Sort-Object DisplayName | Format-Table Id, DisplayName`
''')
param timeZoneId string

@description('''
Array of objects that each specify the name and SKU of the VM. For example:
```
[
  {
    vmName: 'DemoVM'
    vmSize: 'Standard_D2_v5'
  }
  {
    vmName: 'DemoVM2'
    vmSize: 'Standard_B2ms'
  }
]
```
''')
param vmConfigList array

@description('User name of the VM\'s built-in local Administrator account.')
param adminUsername string

@description('Password of the VM\'s built-in local Administrator account.')
@secure()
param adminPassword string


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

module rsVault 'modules/deployRSVault.bicep' = if (enableVmBackup) {
  name: 'deployRSVault'
  params: {
    rsVaultName: rsVaultName
    timeZoneId: timeZoneId
  }
}

module VM 'modules/deployVM.bicep' = [for vmConfig in vmConfigList: {
  name: 'deploy${vmConfig.vmName}'
  params: {
    vNetName: vNetName
    vmName: vmConfig.vmName
    vmSize: vmConfig.vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    timeZoneId: timeZoneId
    enableVmBackup: enableVmBackup
    rsVaultName: rsVaultName
  }
  dependsOn: [
    vNet
    rsVault
  ]
}]
