
## 6.5.14 ( Feb 7th, 2023 )
* Fix typo in gateway configMap
## 6.5.13 ( June 20th, 2022 )
* Fix gateway console.publicPort [616](https://github.com/aquasecurity/aqua-helm/issues/616)
## 6.5.12 ( June 7th, 2022 )
* Fix serviceaccount name
## 6.5.11 ( May 18th, 2022 )
* Rename RoleBinding to ClusterRole vmware-system-privileged if platform=tkg
## 6.5.10 ( April 10th, 2022 )
* Make pod labels configurable - [559](https://github.com/aquasecurity/aqua-helm/pull/559)
## 6.5.9 ( March 25th, 2022)
* * Add new static label
## 6.5.8 ( February 4th, 2022)
* Align labels
## 6.5.7 ( January 16th, 2022)
* Update gateway.serviceAccount to support different from aqua namespace - [486](https://github.com/aquasecurity/aqua-helm/pull/486/)
* Fix minor bugs
## 6.5.6 ( December 29th, 2021)
* Update gateway service type to ClusterIP by default - [470](https://github.com/aquasecurity/aqua-helm/pull/470)
* Fix db secret value paths - [474](https://github.com/aquasecurity/aqua-helm/pull/474)
## 6.5.5 ( December 14th, 2021)
* Update RBAC | default to non-privilege mode and remove capabilities in openshift SCC - [454](https://github.com/aquasecurity/aqua-helm/pull/454)
* Add gateway service label support - [454](https://github.com/aquasecurity/aqua-helm/pull/454)

## 6.5.4 ( December 2nd, 2021 )
* Move platform variable to global scope - [444](https://github.com/aquasecurity/aqua-helm/pull/444)
## 6.5.3 ( December 2nd, 2021 )
* Add gateway headless service - [436](https://github.com/aquasecurity/aqua-helm/pull/436)
## 6.5.2 ( November 24th, 2021 )
* Updated gateway chart to support deployment as a dependency chart - [412](https://github.com/aquasecurity/aqua-helm/pull/412)
* Added separate config map for gateway chart and updated template with annotations for configmap checksum - [401](https://github.com/aquasecurity/aqua-helm/pull/401)
* Updated image pullpolicy to Always
## 6.5.1 ( November 1st, 2021)
* Added PDB support for Gateway components - [387](https://github.com/aquasecurity/aqua-helm/pull/387)
## 6.5.0 ( Sep 11th, 2021)
* First 6.5 changelog
* adding 6.5 image tag
