# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.26 ( Jul 13th, 2023 )
* Fix Openshift SecurityContextConstraints

## 2022.4.25 ( Jul 9th, 2023 )
* Update kube-bench version to v0.6.15
* Update starboard version to v0.15.13

## 2022.4.24 ( Jun 20th, 2023 )
* Remove categories from starboard crds (to solve ArgoCD OutOfSync)

## 2022.4.23 ( Apr 20th, 2023 )
* Adjust default resource requests and limits - PR[#741](https://github.com/aquasecurity/aqua-helm/pull/741)
* Update enforcer chart version to `2022.4.13`

## 2022.4.22 ( Apr 10th, 2023 )
* Add ability to define extraVolumes - PR [#728](https://github.com/aquasecurity/aqua-helm/pull/728)
* Adjust default resource requests and limits - PR[#729](https://github.com/aquasecurity/aqua-helm/pull/729)
* Add priorityClass - PR[#734](https://github.com/aquasecurity/aqua-helm/pull/734)
* Fix starboard namespace default assignment - Issue[#735](https://github.com/aquasecurity/aqua-helm/issues/735)
* Update enforcer chart version to `2022.4.12`

## 2022.4.21 ( Mar 22nd, 2023 )
* Fix starboard and KE tolerations

## 2022.4.20 ( Mar 2nd, 2023 )
* Update kube-bench version to v0.6.12
* Make timeout for validatingWebhook and mutatingWebhook configurable

## 2022.4.19 ( Feb 27th, 2023 )
* Fix the starboard deployment for eks

## 2022.4.18 ( Feb 25th, 2023 )
* Fix the starboard deployment

## 2022.4.17 ( Feb 13th, 2023 )
* Update KE and starboard resource limits definition
* Prevent starboard from been deployed on k8s earlier than v1.19

## 2022.4.16 ( Feb 07, 2023 )
* Fix [695](https://github.com/aquasecurity/aqua-helm/issues/695)

## 2022.4.15 ( Jan 27, 2023 )
* Fixed issue with Starboard to deploy in custom namespace
* Fix [695](https://github.com/aquasecurity/aqua-helm/issues/695)

## 2022.4.14 ( Jan 9, 2023 )
* Added new openshift-scc for kube-enforcer.
* Modify the default kube-enforcer service account name.

## 2022.4.13 ( Dec 22nd, 2022 )
* Added control of Rules for KE ClusterRole

## 2022.4.12 ( Nov 27, 2022 )
* Fix typo in KE role and cluster role.
* Added custom AquaEnforcer DaemonSet name support for KubEnforcer config map.

## 2022.4.11 ( Nov 20th, 2022 )
* Modify Kube Enforcer Role template to support release namespace.
## 2022.4.10 ( Nov 16th, 2022 )
* Added Env variable for KubeBench.
* Modified Cluster role for Openshift.
* Added support for Ndots DNS configuration.
* Modifying RBAC permissions for Kube-Enforcer and Starboard Operator
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
