using 'main.bicep'

param vNetName = 'DemovNet'
param bastionName = 'DemoBastion'
param vmConfigList = [
  {
    vmName: 'DemoVM'
    vmSize: 'Standard_D2_v5'
    adminUsername: 'DemoAdmin'
    adminPassword: 'Azee12345678'
  }
  {
    vmName: 'DemoVM2'
    vmSize: 'Standard_D2_v5'
    adminUsername: 'DemoAdmin2'
    adminPassword: 'Azee12345678'
  }
]
