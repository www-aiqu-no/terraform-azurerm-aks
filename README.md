# terraform-azurerm-aks
Deploy an Azure Kubernetes Service (AKS) cluster

## Description
This module lets you create two types of AKS clusters: basic & advanced.
The module is configured by overriding the required variables defined in the
'variables.tf' file

## Using the module
1. Decide if you want basic cluster or advanced (rbac/azure cni)
2. Override variables with any settings you want to change
3. Apply configuration to create your service principals (unless you provide them yourself)
4. <b>[MANUAL]</b> Grant the requested admin permissions for the created applications in Azure
5. Override 'initialized' variable to 'true' & apply module again
6. Connect to azure & retrieve credentials:
```bash
$ az aks get-credentials --resource-group <resource-group> --name <cluster-name>
```
7. Check if you are able to connect to the cluster:
```bash
$ kubectl get nodes
```
