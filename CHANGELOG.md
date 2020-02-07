# v0.1.3 (Unreleased)
#### NOTES
- Modified creating of resource. [[Issue #9](https://github.com/www-aiqu-no/terraform-azurerm-aks/issues/9)]
- Added extra SP for cluster itself
- Split everything into sub-modules again (Sigh!)

# v0.1.2 (February 06, 2020)
#### NOTES
- SIMPLIFIED module... Like, a lot. Removed all submodules. Tried adding basic
  management of the deployed cluster, but ran into problems with provider & empty credentials. Keeping things separate is best, I now believe.. Do this in another module! Use this one to deploy the cluster & logging, then export the credentials for modifying your cluster.

#### BUG FIXES
- N/A

#### IMPROVEMENTS
- N/A

#### FEATURES
- N/A

# v0.1.1 (February 02, 2020)
#### NOTES
- Initial release
- Support for basic & advanced cluster deployment
