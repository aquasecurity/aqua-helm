## 6.2.4 (November 1st, 2021)
* Updating admissionReviewVersions in webhooks to "v1beta1" from "v1", "v1beta1"
* Added Affinity, nodeSelector, Tolerations, Annotations support - [#394](https://github.com/aquasecurity/aqua-helm/pull/394)
## 6.2.3 (September 11th, 2021)
Fixes:
* Added validating webhook missing UPDATE capability - [#363](https://github.com/aquasecurity/aqua-helm/pull/363)

Improvements:
* Adding Aqua registry image for Envoy
## 6.2.2 (September 6th, 2021)
Fixes:
*  Fixed envoy resources block ignored by deployment template - [#352](https://github.com/aquasecurity/aqua-helm/pull/352)
*  Replacing deprecated admissionregistration.k8s.io/v1beta1 -> admissionregistration.k8s.io/v1 - [#352](https://github.com/aquasecurity/aqua-helm/pull/352)

Improvements:
* Added namespace default to all components - [#354](https://github.com/aquasecurity/aqua-helm/pull/354)
* Added an option to use CLUSTER_NAME - [#359](https://github.com/aquasecurity/aqua-helm/pull/359)


## 6.2.1 (July 15th, 2021)

Improvements:
* Updating Image tag -> 6.2
* Added pod annotations support to templates - [#316](https://github.com/aquasecurity/aqua-helm/pull/316)
## 6.2.0 ( Jun 8th, 2021)

* Adding KubeEnforcer Starboard Charts [#286](https://github.com/aquasecurity/aqua-helm/pull/286)