# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.3 (Sep 25th, 2026)
* KubeEnforcer admission for deploymentconfigs, persistentvolumes, persistentvolumeclaims, ingresses, networkpolicies and globalnetworkpolicies
* Fix replicationcontrollers/scale admission rule
* KubeEnforcer read permissions for the new resources and serviceaccounts, plus the OpenShift permissions of the kube-enforcer chart
* KubeEnforcer webhook timeout configurable, default 2s; remove duplicated webhook fields that overrode failurePolicy
* Replace starboard-operator with trivy-operator 0.31.1

## 2022.4.2 (Aug 25th, 2025)
* Resolving issue [#869](https://github.com/aquasecurity/aqua-helm/issues/869)
* Aligning PSP refernces to correct K8s versions
* PR[#984](https://github.com/aquasecurity/aqua-helm/pull/984)

## 2022.4.1 (Mar 6th, 2023)
* Add support policy/v1beta1 and policy/v1 based on cluster version

## 2022.4.0 ( Apr 5th, 2022)
* Init commit