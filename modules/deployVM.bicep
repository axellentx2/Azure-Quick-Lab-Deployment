targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vNetName string
param vmName string
param vmSize string
param adminUsername string

@secure()
param adminPassword string

param timeZoneId string


resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vNetName

  resource subnet 'subnets' existing = {
    name: 'default'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          subnet: {
            id: vNet::subnet.id
          }
        }
      }
    ]
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  properties: {
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    hardwareProfile: {
      vmSize: vmSize
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      adminUsername: adminUsername
      adminPassword: adminPassword
      computerName: vmName
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'AutomaticByOS'
        }
        provisionVMAgent: true
        timeZone: timeZoneId
      }
    }
    securityProfile: {
      encryptionAtHost: true
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    storageProfile: {
      osDisk: {
        name: '${vmName}-osDisk'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        osType: 'Windows'
      }
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
    }
  }
}

resource autoShutdownSchedule 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: timeZoneId
    notificationSettings: {
      status: 'Disabled'
    }
    targetResourceId: VM.id
  }
}
