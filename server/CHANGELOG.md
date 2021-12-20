## 6.5.10 ( December 20th, 2021 )
* Move serviceAccount and pull secret to global scope
* Align serviceAccount and pull secret names
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
