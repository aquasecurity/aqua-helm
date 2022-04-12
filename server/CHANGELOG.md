## 6.5.16 ( April 10th, 2022 )
* Make pod labels configurable - [559](https://github.com/aquasecurity/aqua-helm/pull/559)
## 6.5.15 ( March 25th, 2022 )
* Add new static label
## 6.5.14 ( March 2nd, 2022 )
* Adds additional capability to add a configmap file containing a PEM certificate bundle. - [512](https://github.com/aquasecurity/aqua-helm/pull/512)
## 6.5.13 ( February 4th, 2022)
* Align server labels + NOTES.txt- [515](https://github.com/aquasecurity/aqua-helm/pull/515)
* Separate ocp scc declaration
* Update gateway version
## 6.5.12 ( January 16th, 2022)
* Update Gateway version to 6.5.7
## 6.5.11 ( December 29th, 2021)
* Update web ingress to support different Kubernetes versions - [469](https://github.com/aquasecurity/aqua-helm/pull/469)
* Update gateway service type to ClusterIP by default - [470](https://github.com/aquasecurity/aqua-helm/pull/470)
## 6.5.10 ( December 23th, 2021 )
* Issue [461](https://github.com/aquasecurity/aqua-helm/issues/461) - Fix duplicate global ref in password secrets PR - [464](https://github.com/aquasecurity/aqua-helm/pull/464)
## 6.5.9 ( December 14th, 2021 )
* Update RBAC | default to non-privilege mode and remove capabilities in openshift SCC - [454](https://github.com/aquasecurity/aqua-helm/pull/454)
## 6.5.8 ( December 12th, 2021 )
* Fix Openshift route configuration - [453](https://github.com/aquasecurity/aqua-helm/pull/453)
* Add web service label support
## 6.5.7 ( December 5th, 2021 )
* Move platform variable to global scope - [445](https://github.com/aquasecurity/aqua-helm/pull/445)
## 6.5.6 ( December 2nd, 2021 )
* Add support for gateway headless service - [437](https://github.com/aquasecurity/aqua-helm/pull/437)
## 6.5.5 ( December 1st, 2021 )
* Ingress definition updated for kubernetes versions up to 1.22 - [432](https://github.com/aquasecurity/aqua-helm/pull/432)
## 6.5.4 ( November 30th, 2021 )
* Fixing Server chart deployment from helm repo
## 6.5.3 ( November 29th, 2021 )
* Fix Web Ingress pathType - [423](https://github.com/aquasecurity/aqua-helm/pull/423)
## 6.5.2 ( November 24th, 2021 )
* Added gateway as a dependency chart - [413](https://github.com/aquasecurity/aqua-helm/pull/413)
* Added separate config maps for server chart components - server, gateway, db and updated templates with annotations for configmap checksum - [401](https://github.com/aquasecurity/aqua-helm/pull/401)
* Updated image pullpolicy to Always
## 6.5.1 ( November 1st, 2021)
* Added PDB support for Server, Gateway, Envoy components - [387](https://github.com/aquasecurity/aqua-helm/pull/387)
## 6.5.0 ( Sep 11th, 2021)
* First 6.5 changelog
* adding 6.5 image tag
