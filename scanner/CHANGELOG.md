# Changelog

All notable changes to this project will be documented in this file.

## 2022.4.13 (Today)
* Add support for global.commonLabels to apply custom labels to all resources - [#978](https://github.com/aquasecurity/aqua-helm/issues/978)

## 2022.4.12 (Aug 6th, 2025)
* SLK-99202 Adding conditional imagePullSecret attachement - [#963](https://github.com/aquasecurity/aqua-helm/issues/963) 

## 2022.4.11 (Aug 6th, 2025)
* SLK-94741 Adding emptyDir when persistence is disabled - [#962](https://github.com/aquasecurity/aqua-helm/issues/962) 

## 2022.4.10 (Dec 30th, 2024)
* Fixed additionalCert errors

## 2022.4.9 (Dec 6th, 2024)
* Fixed enableLivenessProbe related errors - [#909](https://github.com/aquasecurity/aqua-helm/issues/909)

## 2022.4.8 (June 18th, 2024)
* Added Liveness probe Configuration spec - [#871](https://github.com/aquasecurity/aqua-helm/pull/871)
* Add missing annotations field to values.yaml and scanner-deployment - [#873](https://github.com/aquasecurity/aqua-helm/pull/873)

## 2022.4.6 (Sep 28th, 2023)
* Add RBAC configuration - SLK-72111
* 
## 2022.4.5 (Jul 19th, 2023)
* Fix scanner persistence volume

## 2022.4.4 (May 4th, 2023)
* Added persistence to scanner (Change deploy to statefulset if persistence enabled)

## 2022.4.3 (Mar 7th, 2023)
* Added support for custom Scanner token secret
* Add support for default scanner name based on pod name, keep nameOverride empty

## 2022.4.2 (Sep 13th, 2022)
* Add support for scanner name override

## 2022.4.1 (May 4th, 2022)
* Add token authentication support to scanner

## 2022.4.0 (Apr 5th, 2022)
* Init commit
