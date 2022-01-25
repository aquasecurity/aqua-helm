## 6.5.4 ( January 23)
* Fix serviceAccount and pull image registry secret to support deployment on same cluster
  with the server and gateway or separate cluster
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
