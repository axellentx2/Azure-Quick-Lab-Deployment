using 'main.bicep'

param vNetName = 'DemovNet'
param bastionName = 'DemoBastion'
param enableVmBackup = true
param rsVaultName = 'DemoVault'
param timeZoneId = 'W. Europe Standard Time'
param vmConfigList = [
  {
    vmName: 'DemoVM'
    vmSize: 'Standard_D2_v5'
  }
  {
    vmName: 'DemoVM2'
    vmSize: 'Standard_D2_v5'
  }
]
param adminUsername = 'DemoAdmin'
param adminPassword = ''
