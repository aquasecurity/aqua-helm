## 6.2.8 (January 11th, 2022)
* Adding openshift and mke platform support - [#481](https://github.com/aquasecurity/aqua-helm/pull/481)
## 6.2.7 (November 1st, 2021)
* Updating admissionReviewVersions in webhooks to "v1beta1" from "v1", "v1beta1" - [#392](https://github.com/aquasecurity/aqua-helm/pull/392)
* Added Affinity, nodeSelector, Tolerations, Annotations support - [#394](https://github.com/aquasecurity/aqua-helm/pull/394)

## 6.2.6 (September 11th, 2021)
Fixes:
* Added validating webhook missing UPDATE capability - [#363](https://github.com/aquasecurity/aqua-helm/pull/363)

Improvements:
* Adding Aqua registry image for Envoy
## 6.2.5 (September 6th, 2021)
Fixes:
*  Fixed envoy resources block ignored by deployment template - [#352](https://github.com/aquasecurity/aqua-helm/pull/352)
*  Replacing deprecated admissionregistration.k8s.io/v1beta1 -> admissionregistration.k8s.io/v1 - [#352](https://github.com/aquasecurity/aqua-helm/pull/352)
*  Fixed AQUA_LOGICAL_NAME missing in values - [#352](https://github.com/aquasecurity/aqua-helm/pull/352)

Improvements:
* Added namespace default to all components - [#354](https://github.com/aquasecurity/aqua-helm/pull/354)
* Added an option to use CLUSTER_NAME - [#359](https://github.com/aquasecurity/aqua-helm/pull/359)

## 6.2.4 (August 4th, 2021)

Fixes:
* Fixing rootca file not found issue when using CA certificates - [#329](https://github.com/aquasecurity/aqua-helm/pull/329)

Improvements:
* Updated README file - [#323](https://github.com/aquasecurity/aqua-helm/pull/323), [#327](https://github.com/aquasecurity/aqua-helm/pull/327)
* Adding NodeSelector support to the Kube Enforcer chart - [#315](https://github.com/aquasecurity/aqua-helm/pull/315)
* Allow creation of the kube-enforcer-token secret to be disabled - [#316](https://github.com/aquasecurity/aqua-helm/pull/316)
## 6.2.3 (July 15th, 2021)

Fixes:
* Fixed static namepace value "aqua" to load from values.yaml - [#309](https://github.com/aquasecurity/aqua-helm/pull/309)

Improvements:
* Updating Image tag -> 6.2
* Added TLS/mTLS support by loading certs from secrets - [#307](gen_ke_certs.sh307)
* Added pod annotations support to templates - [#316](https://github.com/aquasecurity/aqua-helm/pull/316)
## 6.2.2 (May 12th, 2021)

Bug Fixes:
* Fixed KE image pull secrets #[263](https://github.com/aquasecurity/aqua-helm/pull/263)

Improvements:
* Updating Image tag -> 6.2.RC1

## 6.2.1 (May 4th, 2021)

Improvements:
* Adding Changelog
* Updating Readme
* Updating Image tag -> 6.2.preview5