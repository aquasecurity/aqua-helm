# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.11 (Jan 16th, 2022)
* Added support for Init containers and sidecar containers.

## 2022.4.10 (Dec 6th, 2022)
* Fix labels in the pre-upgrade hook job

## 2022.4.9 (Dec 1st, 2022)
* Add pre-upgrade hook job, to fail the upgrade if the DB upgrade is detected to fail.

## 2022.4.8 (Oct 31st, 2022)
* Fix Cluster Role Binding SA name

## 2022.4.7 (Oct 14th, 2022)
* Fix external DB certificate mounts in mtls connection

## 2022.4.6 (Sep 19th, 2022)
* Add support to switch rbac creation in server chart

## 2022.4.5 (Aug 22nd, 2022)
* Fix gateway serviceaccount naming in custom namespace deployment - PR [#641](https://github.com/aquasecurity/aqua-helm/pull/641)

## 2022.4.4 ( Aug 12th, 2022)
* Fix mTLS config between external DB and server/gateway
* Update documentation

## 2022.4.3 ( Jul 6th, 2022 )
* Support to load to db certs for external DB - PR fix [#493](https://github.com/aquasecurity/aqua-helm/issues/493)

## 2022.4.2 ( June 8th, 2022 )
* Add PSP support in rbac for backward compatibility - issue [#606](https://github.com/aquasecurity/aqua-helm/issues/606)
* Fix hard-coded serviceaccount name to dynamic - issue [#605](https://github.com/aquasecurity/aqua-helm/issues/605)

## 2022.4.1 ( May 18th, 2022 )
* Rename RoleBinding to ClusterRole vmware-system-privileged if platform=tkg
* Separate db volume size

## 2022.4.0 ( Apr 4th, 2022)
* Init commit

