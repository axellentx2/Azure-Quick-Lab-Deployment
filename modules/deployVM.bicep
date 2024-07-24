targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Name of the existing vNet.')
param vNetName string

@description('Name of the VM.')
param vmName string

@description('SKU of the VM.')
param vmSize string

@description('User name of the VM\'s built-in local Administrator account.')
param adminUsername string

@description('Password of the VM\'s built-in local Administrator account.')
@secure()
param adminPassword string

@description('''
The ID of the time zone. For a list of all available time zone IDs, use the following PowerShell command:  
`Get-TimeZone -ListAvailabe | Sort-Object DisplayName | Format-Table Id, DisplayName`
''')
param timeZoneId string

@description('Specifies whether to include the VM(s) in backup or not.')
param enableVmBackup bool

@description('Name of the recovery services vault. Can be left empty or left out if backup will not be enabled.')
param rsVaultName string = ''


resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vNetName

  resource defaultSubnet 'subnets' existing = {
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
            id: vNet::defaultSubnet.id
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

resource rsVault 'Microsoft.RecoveryServices/vaults@2024-04-01' existing = if (enableVmBackup) {
  name: rsVaultName

  resource trustedLaunchVMPolicy 'backupPolicies' existing = {
    name: 'TrustedLaunchVMPolicy'
  }
}

var resourceGroupResourceName = '${resourceGroup().name};${VM.name}'
var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroupResourceName}'
var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroupResourceName}'

resource virtualMachineBackup 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-08-01' = if (enableVmBackup) {
  name: '${rsVaultName}/Azure/${protectionContainer}/${protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: rsVault::trustedLaunchVMPolicy.id
    sourceResourceId: VM.id
  }
}
