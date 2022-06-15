# Changelog

All notable changes to this project will be documented in this file.

## 2022.4.3 ( Jun 15th, 2022 )
* Add support for starboard v0.15.4
## 2022.4.2 ( Jun 8th, 2022 )
* Fix annotations for tolerations issue [#599](https://github.com/aquasecurity/aqua-helm/issues/599) by adding tolerations at spec
* Add PodDisruptionBudget to kube-enforcer deployment [#613](https://github.com/aquasecurity/aqua-helm/pull/613/files)
## 2022.4.1 ( Jun 7th, 2022 )
* Update Enforcer chart version
* Move CRD's to separate folder [#609](https://github.com/aquasecurity/aqua-helm/pull/609)

## 2022.4.0 ( Apr 5th, 2022 )
* Init commit
* Update KE role and cluster role
* Add POD_NAME variable to KE deployment

### ⚠ BREAKING CHANGES
* From release 2022.4 the Kube Enforcer chart will support Express Mode, when variable `global.enforcer.enabled` defined as `true` the Enforcer chart will be installed also 
* The following variables moved to the global scope
  * platform --> global.platform
  * gateway.* --> global.gateway.*
  * imageCredentials.* --> global.imageCredentials.*
