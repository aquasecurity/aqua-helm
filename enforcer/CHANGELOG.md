## 6.5.10 ( March 24th, 2022 )
* Fix [539](https://github.com/aquasecurity/aqua-helm/issues/539), Add support to modify updateStrategy.
* Add priority-class for aqua enforcer
## 6.5.9 ( February 27th)
* Fix extraEnvironmentVars to support proxy variables in lowercase
## 6.5.8 ( February 4th, 2022 )
* Align labels + update NOTES.txt
## 6.5.7 ( January 21th)
* Fix issue - [497](https://github.com/aquasecurity/aqua-helm/issues/497)
## 6.5.6 ( January 18th, 2022 )
* Fix serviceAccount and pull image registry secret to support deployment on same cluster 
  with the server and gateway or separate cluster
## 6.5.5 ( December 14th, 2021 )
* Add AQUA_LOGICAL_NAME and AQUA_NODE_NAME - [454](https://github.com/aquasecurity/aqua-helm/pull/454)
* Fixing OCP SCC capabilities names - [464](https://github.com/aquasecurity/aqua-helm/pull/464)
## 6.5.4 ( December 8th, 2021 )
* Adding capabilities for Behavioral detection
* Making enforcer deployment default to non-privilege mode
* Updating Readme
## 6.5.3 ( December 6th, 2021 )
* Update service account name - [447](https://github.com/aquasecurity/aqua-helm/pull/447)
## 6.5.2 ( November 24th, 2021 )
* Added separate config map for Enforcer chart and updated template with annotations for configmap checksum - [401](https://github.com/aquasecurity/aqua-helm/pull/401)
* Fixed readiness and liveness probes failure due to env AQUA_HEALTH_MONITOR_ENABLED missing - [408](https://github.com/aquasecurity/aqua-helm/pull/408)
* Updating image pullpolicy to Always
## 6.5.1 ( November 1st, 2021)
* Added Liveness and Readiness probes - [#395](https://github.com/aquasecurity/aqua-helm/pull/395)
## 6.5.0 ( Sep 11th, 2021)
* First 6.5 changelog
* adding 6.5 image tag
