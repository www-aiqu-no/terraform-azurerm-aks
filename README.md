# Create an Azure Kubernetes Service (AKS) Cluster
![GitHub top language](https://img.shields.io/github/languages/top/www-aiqu-no/terraform-azurerm-aks)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/www-aiqu-no/terraform-azurerm-aks/terraform-validate)
![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/www-aiqu-no/terraform-azurerm-aks?include_prereleases)
![GitHub last commit](https://img.shields.io/github/last-commit/www-aiqu-no/terraform-azurerm-aks)
![GitHub issues](https://img.shields.io/github/issues/www-aiqu-no/terraform-azurerm-aks)

This module will deploy a managed AKS cluster in Azure.
It takes ~10 minutes to provision from scratch.

Please see the 'Sample Usage' before trying to deploy, as there is a manual step involved

#### Why not the official azurerm-module?
The official module doesn't seem to be updated too often, and isn't as flexible as it should be

#### Main Features
- Azure AD rbac enabled cluster with minimal configuration
- Optional 'Log Analytics Solution'
- More to come..

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
```bash
# This assumes your module is named 'aks'
$ terraform init
# --
# 1) Create the Azure AD services & principals:
$ terraform apply -auto-approve -target module.aks.module.aad.azuread_service_principal.server -target module.aks.module.aad.azuread_service_principal.client
# --
# 2) Manually grant the requested administrative privileges in Azure AD for the new principals in the new applications (see further below)
# --
# 3) Deploy the rest of the module:
$ terraform apply -auto-approve
# --
# Deployment should take ~10 minutes
$ terraform output
```

Example configuration
```hcl
terraform {
  required_version = "~> 0.12"
}

module "aks" {
  source  = "www-aiqu-no/aks/azurerm"
  version = "0.1.2"

  # Prefix for your resources
  prefix       = "Demo"

  # You can optionally enable log analytics
  log_analytics_enabled = true
}

# NOTE: To print output from modules, you need to export it in root:
output "kube_info" {
  value = module.aks.info
}

output "kube_public_ssh_key" {
  value = module.aks.public_ssh_key
}
```

## <a name="grant"></a>Granting Admin Permissions (Azure AD)
You need to manually grant the permissions requested by azure ad
applications created by this module in Azure

#### Using CLI
```bash
$ az ad app permission admin-consent --id $<applicationId>
```

#### Using Azure Portal (click, click!)
```bash
# 1) Log on to portal
# 2) Locate your application(s) under 'Home > Azure Active Directory > App Registrations' (See under All Applications)
# 3) Select 'API Permissions' in the application(s)
# 4) Select 'Grant Admin Concent' > 'Yes'
```

#### Automatic
TODO: Includes null_resource, delays & running cli-commands that are os-specific.

## Retrieving & testing credentials
```bash
$ az aks get-credentials --resource-group <resource-group> --name <cluster-name> --admin
```

Check if you are able to connect to the cluster:
```bash
$ kubectl get nodes
```

## <a name="role_perm"></a>Extra provisioner permissions (not in use)
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

## Updating existing roles (not in use)
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
