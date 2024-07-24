## Bicp template for deploying a VM lab environment with a Bastion Host

### Introduction
This template will create a lab environment with a vNet (including NSG with only default rules), Bastion (Developer SKU) and one or several VMs. The VM(s) - with a secure profile - will be configured with an auto shutdown schedule at 7 PM in the time zone that's specified in the parameter file. Optionally, the VM(s) will be included in a daily backup in a recovery services vault.

Please note that the Developer SKU for Bastion is currently only available in the following regions: Central US EUAP, East US 2 EUAP, West Central US, North Central US, West US and North Europe. Since all resources that are deployed using this template derive their location from their parent resource group, you should create a resource group for this template deployment in one of the aforementioned regions. The template will actually successfully deploy to a resource group in another region, but subsequently connecting to a VM through Bastion will fail.  
See for the latest info on availability of this SKU: https://learn.microsoft.com/en-us/azure/bastion/quickstart-developer-sku.

The commands in the below list of steps are meant to be executed in the Azure CLI with the Bicep CLI extension. If the Azure CLI isn't yet installed on your computer, you can download and configure it using this link: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows. After installing the Azure CLI, the Bicep CLI extension should be installed autonatically as soon as a deployment of a Bicep template is executed. If for whatever reason the Bicep CLI extension needs to be installed explicitly, this can be accomplished using the command: `az bicep install`.
<br />
<br />

### Steps to deploy
1. Provide the desired values for the parameters in the bicepparam file (it has been prepopulated with example values). If you configure the parameter "enableVmBackup" with a value of "false" the value of the parameter "rsVaultName" can be left empty or the parameter can be removed altogether.
2. Log in to the tenant:
   ```bash
   az login
   az set account -s '<subscription name or ID>'
   az account show -o table
   ```
3. Then execute the below command to enable the Encryption at Host feature for the subscription:
   ```bash
   az feature register --name EncryptionAtHost  --namespace Microsoft.Compute
   ```
4. Finally deploy the template using the below command:
   ```bash
   az deployment group create -n LabDeployment -g '<resource group name>' -f ./main.bicep -p ./main.bicepparam -c -r ResourceIdOnly -o table
   ```
   