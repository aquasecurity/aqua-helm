## 6.5.24 ( Sep 14th, 2023 )
* Update Starboard to 0.15.15
## 6.5.23 ( Mar 21st, 2023 )
* Fix starboard tolerations
## 6.5.22 ( January 9th, 2023 )
* Added new openshift-scc for kube-enforcer.
* Modify the default kube-enforcer service account name.
## 6.5.21 ( October 10th, 2022 )
* Added custom AquaEnforcer DaemonSet name support for KubEnforcer config map.
## 6.5.20 ( October 10th, 2022 )
* Add support for starboard v0.15.10
## 6.5.19 ( July 28th, 2022 )
* Add podLables and resources to starboard deployment issue [#632](https://github.com/aquasecurity/aqua-helm/issues/632)
## 6.5.18 ( July 14th, 2022 )
* Add HashiCorp Vault support to load token
## 6.5.17 ( July 11th, 2022 )
* Add support for starboard v0.15.4
## 6.5.16 ( May 11th, 2022 )
* Remove all categories definition in configauditreports CRD spec
* Fix crds label issue [608](https://github.com/aquasecurity/aqua-helm/issues/608) by moving all custom resource definations to crds/
* Fix annotations for tolerations issue [599](https://github.com/aquasecurity/aqua-helm/issues/599) by adding tolerations at spec
* Add PodDisruptionBudget to kube-enforcer deployment [#610](https://github.com/aquasecurity/aqua-helm/pull/610)
## 6.5.15 ( April 10th, 2022 )
* Make pod labels configurable - [559](https://github.com/aquasecurity/aqua-helm/pull/559)
## 6.5.14( March 29th)
* Add new static label
## 6.5.13( March 23th)
* Update default starboard version to be 0.14.1
## 6.5.12 ( February 27th)
* Fix extraEnvironmentVars to support proxy variables in lowercase
* Add starboard pod annotation
## 6.5.11 ( February 22nd, 2022 )
> **_NOTE:_**  This new liveness & readiness probes only works with KE version >= 6.5.22054 or 6.5(latest)
* Update liveness & readiness probes
## 6.5.10 ( February 4th, 2022 )
* Align labels + update NOTES.txt
* Add support for extraEnvironmentVars
* Add support for extraSecretEnvironmentVars
## 6.5.9 ( February 2nd, 2022 )
* Add certsSecret.autoGenerate to support auto generated self-signed certificates
* Add cert-manager annotation description for webhook manifests in values.yaml
* Add instruction for cert-manager usage
## 6.5.8 ( January 25th, 2022 )
* Update kube-enforcer configMap to support custom names for TLS certificates
## 6.5.7 ( January 21th, 2022 )
* Fix issue - [497](https://github.com/aquasecurity/aqua-helm/issues/497)
## 6.5.6 ( January 19th, 2022 )
* Fix serviceAccount and pull image registry secret to support deployment on same cluster
  with the server and gateway or separate cluster
## 6.5.5 ( January 10th, 2022 )
* Add Mirantis kubernetes platform support [480](https://github.com/aquasecurity/aqua-helm/pull/480)
* Fix issue with duplicate parameters [483](https://github.com/aquasecurity/aqua-helm/issues/483)
* Add starboard nodeSelector [488](https://github.com/aquasecurity/aqua-helm/pull/488)
## 6.5.4 ( December 29th, 2021 )
* Fix namespace for starboard role - [470](https://github.com/aquasecurity/aqua-helm/pull/470)
## 6.5.3 ( December 22nd, 2021)
* Add openshift scc support - [465](https://github.com/aquasecurity/aqua-helm/pull/465)
* Issue [459](https://github.com/aquasecurity/aqua-helm/issues/459) - Add annotations support for Mutating and Validation webhooks - [464](https://github.com/aquasecurity/aqua-helm/pull/464)
## 6.5.2 ( November 24th, 2021 )
* Add separate config maps for Kube Enforcer chart and updated template with annotations for configmap checksum - [401](https://github.com/aquasecurity/aqua-helm/pull/401)
* Updating image pullpolicy to Always

## 6.5.1 ( November 1st, 2021)
* Add checksum/config support for automatic deployment restart after any configmap changes - [#388](https://github.com/aquasecurity/aqua-helm/pull/388)
* Update admissionReviewVersions in webhooks to "v1beta1" from "v1", "v1beta1" - [#391](https://github.com/aquasecurity/aqua-helm/pull/391)
## 6.5.0 ( Sep 11th, 2021)
* First 6.5 changelog
* adding 6.5 image tag
* Deploying Starboard as default