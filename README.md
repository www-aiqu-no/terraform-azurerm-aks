# terraform-azurerm-aks
Deploy an Azure Kubernetes Service (AKS) cluster.
(The official module sadly doesn't seem to be updated too often)

Please note that this is a work in progress, and any feedback & improvements are welcome!

## Description
This module lets you create two types of AKS clusters: basic & advanced.
The module is configured by overriding the required variables defined in the 'variables.tf' file

## Start using the module
  1. Run 'apply' to creat service principals in AAD (unless you provide them yourself; then skip to '3')
  2. <b>[MANUAL]</b> Grant the requested admin permissions for the created application(s) in Azure
  3. Override the 'initialized' variable to 'true' & apply module again to deploy cluster

### Granting Admin permissions in Azure AD
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
$ az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
```

Check if you are able to connect to the cluster:
```bash
$ kubectl get nodes
```

## Configuring the deployed aks cluster
It is possible to do some basic configuration of the deployed cluster.
  - Set the variable 'kube_management_enabled' to 'true'
  - Use variables prefixed with kube_* to change k8s settings

These modules are nested under the 'kube-modules' moduleto keep the main module easier to read:
  - role-bindings: Add aad-group as kube-administrators

..more to come


# TODO:
- Add management of network resources
- Add more kube-customization options
- Add automated testing

# Links
- [Terraform Modules documentation](https://www.terraform.io/docs/modules/index.html)
- [Terraform Registry](https://registry.terraform.io)
- [Official AKS module](https://registry.terraform.io/modules/Azure/aks/azurerm/2.0.0)
