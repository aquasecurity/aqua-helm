# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.26 (Jul 29th, 2024)
* Fix 'volumes' & 'volumeMounts' indentation in job-check-db-upgrade job (SLK-83783)
* Add AQUA_PUBSUB_DBPASSWORD env variable in job-check-db-upgrade job (SLK-84299)

## 2022.4.25 (Jul 26th, 2024)
* Fix indentation and formatting for external DB - [#790](https://github.com/aquasecurity/aqua-helm/pull/790)

## 2022.4.24 (Apr 16th, 2024)
* Fixed a bug in the database password value references, that linked to wrong, non exitend values
* Fixed some typos and formatting style related aspects

## 2022.4.23 (Dec 24th, 2023)
* Add support for ArgoCD deployment - [#799](https://github.com/aquasecurity/aqua-helm/issues/799)
* Immutable Secrets - Preventing changes to the data of an existing Secret (DB)

## 2022.4.22 (Dec 10th, 2023)
* Fix indentation and formatting for external DB - [#790](https://github.com/aquasecurity/aqua-helm/issues/790) 
* Fix envoy configuration

## 2022.4.21 (Dec 5 th, 2023)
* Allow the API version of PodDisruptionBudget to be overridden [#807](https://github.com/aquasecurity/aqua-helm/pull/807)

## 2022.4.20 (Nov 9th, 2023)
* Fix db crashing during the helm upgrade

## 2022.4.19 (Sep 21st, 2023)
* Update pre-upgrade hook to support mtls with external DB
* Update server deployment for extra volumes / volumemounts - PR[#776](https://github.com/aquasecurity/aqua-helm/pull/776)

## 2022.4.18 (Jun 30th, 2023)
* Fix openshift scc

## 2022.4.17 (Jun 27th, 2023)
* Add vault agent injection support for db secrets

## 2022.4.16 (May 28, 2023)
* Add support for external web secret

## 2022.4.15 (May 16, 2023)
* Add support appProtocol in helm for L7 LB
* Add NodeSelectors to check-db-upgrade job
* Add namespace definition to check-db-upgrade job
* Fix API version check for ingress

## 2022.4.14 (Apr 10th, 2023)
* Add securitycontext for job check-db-upgrade - Issue [#726](https://github.com/aquasecurity/aqua-helm/issues/726)
* Update gateway chart version to `2022.4.12`

## 2022.4.13 (Mar 6th, 2023)
* Add support policy/v1beta1 and policy/v1 based on cluster version
* Add option to add annotation to the gateway serviceAccount

## 2022.4.12 (Feb 7th, 2023)
* Allow the ApiVersion of the Ingress to be specified via values.yaml

## 2022.4.11 (Jan 16th, 2023)
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

