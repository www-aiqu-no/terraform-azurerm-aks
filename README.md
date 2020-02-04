# Create an Azure Kubernetes Service (AKS) Cluster
![GitHub top language](https://img.shields.io/github/languages/top/www-aiqu-no/terraform-azurerm-aks)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/www-aiqu-no/terraform-azurerm-aks/terraform-validate)
![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/www-aiqu-no/terraform-azurerm-aks?include_prereleases)
![GitHub last commit](https://img.shields.io/github/last-commit/www-aiqu-no/terraform-azurerm-aks)
![GitHub issues](https://img.shields.io/github/issues/www-aiqu-no/terraform-azurerm-aks)

This module will deploy a managed AKS cluster in Azure.
It takes ~10 minutes to provision from scratch.
The official module doesn't seem to be updated too often, and isn't as flexible as it should be

#### Main Features
- basic or advanced deployment
- minimal configuraion required
- Optional customization of roles
- Optional deploy of 'Log Analytics Solution'

Please note that this is a work in progress, and any feedback & improvements are welcome

- [Terraform Registry](https://registry.terraform.io/modules/www-aiqu-no/aks/azurerm)
- [Github](https://github.com/www-aiqu-no/terraform-azurerm-aks)
- [Issues](https://github.com/www-aiqu-no/terraform-azurerm-aks/issues)

## Providers
```hcl
# See 'versions.tf'
provider "azurerm"    { version = "~> 1.42" }
provider "azuread"    { version = "~> 0.7"  }
provider "random"     { version = "~> 2.2"  }
provider "local"      { version = "~> 1.4"  }
provider "tls"        { version = "~> 2.1"  }

# Added in sub-module 'kube-modules', with authentication from the deployment
#provider "kubernetes" { version = "~> 1.10" }
```

## Sample Usage
1. Run 'apply' to creat service principals in Azure AD (unless you provide them yourself; then skip to '3'), and also the log analytics workspace
(if enabled)
2. [Manual](#grant): Grant the requested admin permissions for the aks-application(s) in Azure
3. Override the 'initialized' variable to 'true' & apply module again to deploy & configure cluster

The below example will deploy the 'basic' version of the aks cluster, without any monitoring or cluster settings
```hcl
terraform {
  required_version = "~> 0.12"
}

module "aks" {
  source  = "www-aiqu-no/aks/azurerm"
  version = "0.1.2"

  # Prefix for your resources
  prefix       = "AksExample"

  # Two options: basic (no rbac & cni networking) or advanced
  cluster_type = "basic"

  # Change this to 'true' after granting permissions in Azure AD, and run apply again
  #initialized  = true

  # You can optionally enable more configuration
  # Note that provisioner (terraform user) need additional permissions to
  # manage roles for the cluster (described below)
  #log_analytics_enabled   = true
  #kube_management_enabled = true
  #kube_admin_group = "<Group Id or Name>"
}

# NOTE: To print output from modules, you need to export it in root:
output "kube_info" {
  value = module.aks.info
}

output "kube_public_ssh_key" {
  value = module.aks.public_ssh_key
}
```

## <a name="grant"></a>Grant Admin Permissions (Azure AD)
You need to manually grant the permissions requested by azure ad
applications created by this module in Azure

#### Using CLI
```bash
$ az ad app permission admin-consent --id $<applicationId>
```

#### Using Azure Portal (click, click!)
  - Log on to portal
  - Locate your application(s) under 'Home > Azure Active Directory > App Registrations' (See under All Applications)
  - Select 'API Permissions' in the application(s)
  - Select 'Grant Admin Concent' > 'Yes'

#### Using this module (automatic)
TODO: Includes null_resource, delays & running cli-commands that are os-specific.

## Retrieving & testing credentials
```bash
$ az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
```

Check if you are able to connect to the cluster:
```bash
$ kubectl get nodes
```

## Configuring the AKS cluster
It is possible to do some basic configuration of the deployed cluster.
  - Set the variable 'kube_management_enabled' to 'true'
  - Use variables prefixed with kube_* to change k8s settings

These modules are nested under the 'kube-modules' moduleto keep the main module easier to read:
  - role-bindings: Add aad-group as kube-administrators

..more to come

## <a name="role_perm"></a>Extra provisioner permissions
By default, the terraform provisioner doesn't provide enough permissions (if you follow the official guide). To enable management of roles for your cluster, you need to add custom some permissions for your subscription:
```json
{
  "Name": "Terraform - Custom Permissions",
  "IsCustom": true,
  "Description": "Extra permissions for terraform",
  "Actions": [
    "Microsoft.Authorization/roleAssignments/*"
  ],
  "NotActions": [],
  "DataActions": [],
  "NotDataActions": [],
  "AssignableScopes": [
    "/subscriptions/<your-subscription-id-is-requred-here>"
  ]
}
```

## Updating existing roles
If you want to update role, you might have to taint them first (since update is not supported, and unique name is required)
```bash
# Example
$ terraform taint module.testing.module.kube_management.module.role_bindings.kubernetes_cluster_role_binding.<name-of-role-resource>[0]
```

## Output values
Since terraform v0.12+, outputs from modules are no longer stored in the state.
To print them (terraform output), you need to export them in your root module:
```hcl
output "some_name_you_want" {
  value = <name-of-module>.<output-from-module>
}
```
Sensitive output values can not be exported (then you need to set
'sensitive = false' first)

## TODO:
- REMOVE separate role for basic... (grr)
- Add management of network resources & change sku to 'standard'
- Add more kube-customization options
- Add automated testing
- Optional Azure Application Gateway integration (ingress)
- Add possibility for deploying multiple clusters in multiple regions

## External Links
- [Terraform Modules documentation](https://www.terraform.io/docs/modules/index.html)
- [Terraform Registry](https://registry.terraform.io)
- [Official AKS module](https://registry.terraform.io/modules/Azure/aks/azurerm/2.0.0)
