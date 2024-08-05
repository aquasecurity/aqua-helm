# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.47 ( Aug 5th, 2024 )
* remove imagepullsecret from the service account SLK-84166

## 2022.4.46 ( May 21st, 2024 )
* Add pod hostNetwork option for KE deployment

## 2022.4.45 ( May 15th, 2024 )
* upgraded kube-bench version to v0.7.3
* upgraded trivy-operator version to 0.20.1
* added CONTROLLER_CACHE_SYNC_TIMEOUT to resolve CRD sync issue

## 2022.4.44 ( May 6rd, 2024 )
* Enforcer version changed to 2022.4.22

## 2022.4.43 ( Apr 3rd, 2024 )
* Enforcer version changed to 2022.4.21

## 2022.4.42 ( Feb 19th, 2024 )
* Fix namespaceSelector for KE admission controller

## 2022.4.41 ( Feb 19th, 2024 )
* Add a new environment variable AQUA_HEALTH_MONITOR_PORT
* Add namespaceSelector to KE admission controller
* Add additional permissions required for kube-bench checks in openshift container platform

## 2022.4.40 ( Feb 9th, 2024 )
* starboard-operator version upgrade to 0.15.20
* kube-bench version upgrade to v0.7.1

## 2022.4.39 ( Jan 21st, 2024 )
* Add priority class to starboard-operator
* Updated cluster-role.yaml to include additional permissions required for running kube-bench cis benchmarks in openshift container platform

## 2022.4.38 ( Jan 8th, 2024 )
* Updated trivy-operator.yaml to include sbom env variable
* New enforcer version 2022.4.20

## 2022.4.37 ( Jan 3rd, 2024 )
* Updated enforcer chart version to 2022.4.19
* Update startboard version to 0.15.19
* Update kube-bench version to v0.7.0

## 2022.4.36 ( Dec 14th, 2023 )
* Updated trivy-operator version to v0.16.1

## 2022.4.35 ( Dec 10th, 2023 )
### ⚠ BREAKING CHANGES
* SLK-68752 - Change dnsNdots to global value
* Fix dependencies repository - [#808](https://github.com/aquasecurity/aqua-helm/issues/808)
* Fix README.md [#806](https://github.com/aquasecurity/aqua-helm/issues/806)
* Add option to configure trivy securityContext

## 2022.4.34 ( Dec 7th, 2023 )
* Updated starboard version to v0.15.18

## 2022.4.33 ( Dec 5th, 2023 )
* Add option to enable/disable validating and mutating webhook PR[#805](https://github.com/aquasecurity/aqua-helm/pull/805)

## 2022.4.32 ( Nov 8th, 2023 )
* Change starboard operator as default, and Trivy operator as optional with KE deployment

## 2022.4.31 ( Oct 24th, 2023 )
* Add support for trivy resource definition SLK-74400
* Add support for trivy images pull for private registry SLK-74401
* Fix AQUA_ENFORCER_DS_NAME KubeEnforcer configMap value SLK-74436
* Add certs secret to checksum/config of deployment PR[#784](https://github.com/aquasecurity/aqua-helm/pull/784)
* Add nodeSelector to trivy operator PR[#786](https://github.com/aquasecurity/aqua-helm/pull/786)

## 2022.4.30 ( Oct 4th, 2023 )
* Update auto-generate-tls.yaml timeoutSeconds

## 2022.4.29 ( Sep 26th, 2023 )
* Add Trivy installation to kube-enforcer

### ⚠ BREAKING CHANGES
The following upgrade will uninstall Starboard and replace it with Trivy.
The ```clusterconfigauditreports.aquasecurity.github.io``` and ```configauditreports.aquasecurity.github.io``` CustomResourceDefinitions need to be deleted before upgrading.

## 2022.4.28 ( Sep 21st, 2023 )
* Update enforcer chart version to `2022.4.16`

## 2022.4.27 ( Sep 14th, 2023 )
* Update starboard version to v0.15.15
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
