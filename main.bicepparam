using 'main.bicep'

param vNetName = 'DemovNet'
param bastionName = 'DemoBastion'
param adminUsername = 'DemoAdmin'
param adminPassword = ''
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
param timeZoneId = 'Europe/Amsterdam'
