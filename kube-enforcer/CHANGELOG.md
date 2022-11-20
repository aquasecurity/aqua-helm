# Changelog

All notable changes to this project will be documented in this file.
## 2022.4.10 ( Nov 16th, 2022 )
* Added Env variable for KubeBench
* Modified Cluster role for Openshift
* Added support for Ndots DNS configuration.
## 2022.4.9 ( Oct 10th, 2022 )
* Add support for starboard v0.15.10
## 2022.4.8 ( Sep 21st, 2022 )
* Change env of NODE_LABELS_TO_SKIP_KUBE_BENCH to AQUA_NODE_LABELS_TO_SKIP_KB [#644](https://github.com/aquasecurity/aqua-helm/pull/644)
* Fix typo in cds.yaml.tpl [#653](https://github.com/aquasecurity/aqua-helm/pull/653)
## 2022.4.7 ( Aug 12th, 2022 )
* Add support to exclude Nodes From Kube-Bench based on labels [#635](https://github.com/aquasecurity/aqua-helm/issues/635)
## 2022.4.6 ( Jul 28th, 2022 )
* Add podLables and resources to starboard deployment issue [#632](https://github.com/aquasecurity/aqua-helm/issues/632)
## 2022.4.5 ( Jul 6th, 2022 )
* Add HashiCorp Vault support to load token

## 2022.4.4 ( Jun 29th, 2022 )
* Add 2022.4 Update-3 environment variables support
* Fix hard-coded name of aqua enforcer in express mode deployment
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
