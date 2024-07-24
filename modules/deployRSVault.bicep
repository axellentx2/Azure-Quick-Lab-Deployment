targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Name of the recovery services vault.')
param rsVaultName string

@description('''
The ID of the time zone. For a list of all available time zone IDs, use the following PowerShell command:  
`Get-TimeZone -ListAvailabe | Sort-Object DisplayName | Format-Table Id, DisplayName`
''')
param timeZoneId string


resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2024-04-01' = {
  name: rsVaultName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }

  resource trustedLaunchVMPolicy 'backupPolicies' = {
    name: 'TrustedLaunchVMPolicy'
    properties: {
      backupManagementType: 'AzureIaasVM'
      policyType: 'V2'
      schedulePolicy: {
        schedulePolicyType: 'SimpleSchedulePolicyV2'
        scheduleRunFrequency: 'Daily'
        dailySchedule: {
          scheduleRunTimes: [
            '2024-07-01T03:00:00Z'
          ]
        }
      }
      retentionPolicy: {
        retentionPolicyType: 'LongTermRetentionPolicy'
        dailySchedule: {
          retentionTimes: [
            '2024-07-01T03:00:00Z'
          ]
          retentionDuration: {
          count: 7
          durationType: 'Days'
          }
        }
      }
      instantRpRetentionRangeInDays: 1
      timeZone: timeZoneId
    }
  }
}
