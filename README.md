## Bicp template for deploying a VM lab environment with a Bastion Host

### Introduction
This template will create a lab environment with a vNet, Bastion and one or several VMs (depending on the contents of the parameter file).

The commands in the below list of steps are meant to be executed in the Azure CLI with the Bicep CLI extension. If the Azure CLI isn't yet installed on your computer, you can download and configure it using this link: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows. After installing the Azure CLI, the Bicep CLI extension should be installed autonatically as soon as a deployment of a Bicep template is executed. If for whatever reason the Bicep CLI extension needs to be installed explicitly, this can be accomplished using the command: `az bicep install`.
<br />
<br />

### Steps to deploy
1. Log in to the tenant:
   ```bash
   az login
   az set account -s '<subscription name or ID>'
   az account show -o table
   ```
2. Then execute the below command to enable the Encryption at Host feature for the subscription:
   ```bash
   az feature register --name EncryptionAtHost  --namespace Microsoft.Compute
   ```
3. Finally deploy the template using the below command:
   ```bash
   az deployment group create -n LabDeployment -g '<resource group name>' -f ./main.bicep -p ./main.bicepparam -c -r ResourceIdOnly -o table
   ```
   