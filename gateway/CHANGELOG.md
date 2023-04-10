# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.12 (Apr 10th, 2023)
* Change standard name for gateway serviceaccount - PR[#725](https://github.com/aquasecurity/aqua-helm/pull/725)

## 2022.4.11 (Mar 6th, 2023)
* Add support policy/v1beta1 and policy/v1 based on cluster version
* Add option to add annotation to the gateway serviceAccount

## 2022.4.10 (Feb 14th, 2022)
* Fix headless service - PR [#706](https://github.com/aquasecurity/aqua-helm/pull/706)

## 2022.4.9 (Feb 07nd, 2022)
* Fix typo in a gateway configMap

## 2022.4.8 (Dec 22nd, 2022)
* In Gateway Service of type LoadBalancer, loadBalancerSourceRanges are now supported

## 2022.4.7 (Oct 14th, 2022)
* Fix external DB certificate mounts in mtls connection

## 2022.4.6 (Aug 22nd, 2022)
* Fix gateway serviceaccount naming in custom namespace deployment - PR [#641](https://github.com/aquasecurity/aqua-helm/pull/641)

## 2022.4.5 ( Aug 12th, 2022)
* Fix mTLS config between external DB and server/gateway
* Update documentation

## 2022.4.4 ( Jul 6th, 2022 )
* Support to load to db certs for external DB - PR fix [#493](https://github.com/aquasecurity/aqua-helm/issues/493)

## 2022.4.3 ( June 21, 2022 )
* Fix gateway console.publicPort [616](https://github.com/aquasecurity/aqua-helm/issues/616)

## 2022.4.2 ( June 8th, 2022 )
* Fix serviceaccount name

## 2022.4.1 ( May 18th, 2022 )
* Rename RoleBinding to ClusterRole vmware-system-privileged if platform=tkg

## 2022.4.0 ( Apr 4th, 2022)
* Init commit
