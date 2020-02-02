# terraform-azurerm-aks
Deploy an Azure Kubernetes Service (AKS) cluster

## Description
This module lets you create two types of AKS clusters: basic & advanced.
The module is configured by overriding the required variables defined in the
'variables.tf' file

## Using the module
1. Run 'apply' to creat service principals in AAD (unless you provide them yourself; then skip to '3')
2. <b>[MANUAL]</b> Grant the requested admin permissions for the created application(s) in Azure
3. Override the 'initialized' variable to 'true' & apply module again to deploy cluster

## Granting Admin permissions in Azure AD
#### Using CLI
```bash
$ az ad app permission admin-consent --id $<applicationId>
```
#### Using Azure Portal
- Log on to portal
- Locate your application(s) under 'Home > Azure Active Directory > App Registrations' (See under All Applications)
- Select 'API Permissions' in the application(s)
- Select 'Grant Admin Concent' > 'Yes'

#### Using this module (automatic)
TODO (includes null_resource, delays & running cli-commands that are os-specific)

## Retrieving & testing credentials
```bash
$ az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```
7. Check if you are able to connect to the cluster:
```bash
$ kubectl get nodes
```

# TODO:
- Add log monitoring / analytics
- Add cluster role administration
- Add advanced networking
