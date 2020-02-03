# Create an Azure Kubernetes Service (AKS) Cluster
This module will deploy & configure (optional) a managed AKS cluster in Azure. The official module sadly doesn't seem to be updated too often, and isn't as flexible

Please note that this is a work in progress, and any feedback & improvements are welcome!

## Providers used
```hcl
provider "azurerm"    { version = "~> 1.42" }
provider "azuread"    { version = "~> 0.7"  }
provider "random"     { version = "~> 2.2"  }
provider "local"      { version = "~> 1.4"  }
provider "tls"        { version = "~> 2.1"  }

# Added in sub-module 'kube-modules', with authentication from the deployment
#provider "kubernetes" { version = "~> 1.10" }
```

## Sample Usage
1. Run 'apply' to creat service principals in Azure AD (unless you provide them yourself; then skip to '3')
2. [Manual Step](#grant): Grant the requested admin permissions for the aks-application(s) in Azure
3. Override the 'initialized' variable to 'true' & apply module again to deploy & configure cluster

The below example will deploy the 'basic' version of the aks cluster, without any monitoring or cluster settings
```hcl
terraform {
  required_version = ">= 0.12"
}

module "aks" {
  source  = "www-aiqu-no/aks/azurerm"
  version = "0.1.0"

  # Prefix for your resources
  prefix       = random_string.prefix.result

  # Two options: basic (no rbac & cni networking) or advanced
  cluster_type = "basic"

  # Change this to 'true' after granting permissions in Azure AD, and run apply again
  #initialized  = true

  # You can optionally enable more configuration
  #log_analytics_enabled   = true
  #kube_management_enabled = true
  #kube_admin_group = "<Group Id or Name>"
}
```

### <a name="grant"></a>Grant Admin Permissions (Azure AD)
Using CLI
```bash
$ az ad app permission admin-consent --id $<applicationId>
```
Using Azure Portal
  - Log on to portal
  - Locate your application(s) under 'Home > Azure Active Directory > App Registrations' (See under All Applications)
  - Select 'API Permissions' in the application(s)
  - Select 'Grant Admin Concent' > 'Yes'

TODO: Using this module (automatic). Includes null_resource, delays & running cli-commands that are os-specific.

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

### Extra provisioner permissions
By default, the terraform provisioner doesn't provide enough permissions (if you follow the official guilde). To enable managing roles, you need to add custom permission as well:

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

### Updating existing roles
If you want to update role, you might have to taint them first (since update is not supported, and unique name is required)
```bash
# Example
$ terraform taint module.testing.module.kube_management.module.role_bindings.kubernetes_cluster_role_binding.<name-of-role-resource>[0]
```

# TODO:
- Add management of network resources
- Add more kube-customization options
- Add automated testing
- Add optional deployments of consul-, vault- and nomad control-planes

# Links
- [Terraform Modules documentation](https://www.terraform.io/docs/modules/index.html)
- [Terraform Registry](https://registry.terraform.io)
- [Official AKS module](https://registry.terraform.io/modules/Azure/aks/azurerm/2.0.0)
