# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.3 (Oct 16th, 2026)
* KubeEnforcer admission for deploymentconfigs, persistentvolumes, persistentvolumeclaims, ingresses, networkpolicies and globalnetworkpolicies
* Fix replicationcontrollers/scale admission rule
* KubeEnforcer admission for Argo Rollouts (`argoproj.io/v1alpha1` `rollouts` and `rollouts/scale`) and read-only Rollout access in the KubeEnforcer ClusterRole
* KubeEnforcer read permissions for the new resources and serviceaccounts, plus the OpenShift permissions of the kube-enforcer chart
* KubeEnforcer webhook timeout configurable, default 2s; remove duplicated webhook fields that overrode failurePolicy
* Replace starboard-operator with trivy-operator 0.31.1
* Remove the committed KubeEnforcer webhook certificate, key and CA bundle; generate them at install time by default (`ke.certsSecret.autoGenerate`)
* Remove the unused `AQUA_WATCH_CONFIG_AUDIT_REPORT` KubeEnforcer setting

## 2022.4.2 (Aug 25th, 2025)
* Resolving issue [#869](https://github.com/aquasecurity/aqua-helm/issues/869)
* Aligning PSP references to correct K8s versions
* PR[#984](https://github.com/aquasecurity/aqua-helm/pull/984)

## 2022.4.1 (Mar 6th, 2023)
* Add support policy/v1beta1 and policy/v1 based on cluster version

## 2022.4.0 ( Apr 5th, 2022)
* Init commit