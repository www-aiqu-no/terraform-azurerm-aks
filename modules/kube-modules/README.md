# Configure Kubernetes Cluster
This module is used for configuring basic settings in your kubernetes deployment.

Credentials are provided in the variable 'kube_config' (by default, they are provided by the parent module automatically)

## TODO:
- Set up RBAC. Ref. https://github.com/shanepeckham/AKS_Security/tree/master/Azure/AD_RBAC

Azure AD teminology:
```yaml
# Can <Subject> <Verb> <Object> in this <Scope> ?
Kubernetes:
  Subjects:
    UserAccounts: Global, external ('normal') users managed by AAD or similar
    ServiceAccounts: Namespaced, internal accounts managed by kubernetes
  ClusterRoles: Cluster-wide permissions
  Roles: Namespace-limited permissions
  ClusterRoleBinding: Binds subjects to roles for entire cluster
  RoleBinding: Binds subjects to roles for namespace
```
