## 6.5.10 ( May 4th, 2022 )
* Add token auth support to scanner - [582](https://github.com/aquasecurity/aqua-helm/pull/582)
## 6.5.9 ( April 10th, 2022 )
* Make pod labels configurable - [559](https://github.com/aquasecurity/aqua-helm/pull/559)
## 6.5.8 ( March 29nd, 2022 )
* Add new static label
## 6.5.7 ( March 2nd, 2022 )
* Adds additional capability to add a configmap file containing a PEM certificate bundle. - [512](https://github.com/aquasecurity/aqua-helm/pull/512)
## 6.5.6 ( February 28th, 2022 )
* Add option to specify which registries this scanner is allowed to scan - [520](https://github.com/aquasecurity/aqua-helm/pull/520)
## 6.5.5 ( February 4th, 2021 )
* Align labels + update NOTES.txt - [515](https://github.com/aquasecurity/aqua-helm/pull/515)
* Add support for Openshift scc
## 6.5.4 ( January 25th, 2021 )
* Update serviceAccount and image pull secret to support different options
* Fix server ssl certs volumemount issue - [505](https://github.com/aquasecurity/aqua-helm/pull/505)
## 6.5.3 ( December 5, 2021 )
* Remove duplicated namespace definition in serviceAccount - [446](https://github.com/aquasecurity/aqua-helm/pull/446)
## 6.5.2 ( November 24th, 2021 )
* Added separate config map for scanner chart and updated template with annotations for configmap checksum - [409](https://github.com/aquasecurity/aqua-helm/pull/409)
* Updated image pullpolicy to Always
## 6.5.1 ( November 1st, 2021)
* Added mTLS connection support to connect with offline-CyberCenter and SSL connection support to connect with Aqua Server - [#389](https://github.com/aquasecurity/aqua-helm/pull/389)
* Fixed scanner chart EOF error, reported issue - [397](https://github.com/aquasecurity/aqua-helm/issues/397)
## 6.5.0 ( Sep 11th, 2021)
* First 6.5 changelog
* adding 6.5 image tag
