## 6.2.7 (September 6th, 2021)
Fixes:
* Fixed database annotations for Audit-DB - [#356](https://github.com/aquasecurity/aqua-helm/pull/356)

Improvements:
* Added namespace default to all components - [#354](https://github.com/aquasecurity/aqua-helm/pull/354)
 
## 6.2.6 (August 4th, 2021)

Fixes:
* Fixed Serviceaccount imagepull secret name - [#323](https://github.com/aquasecurity/aqua-helm/pull/323)
* Fixing rootca file not found issue when using CA certificates - [#329](https://github.com/aquasecurity/aqua-helm/pull/329)
* Fixing Serviceaccount name in RBAC clusterrolebinding - [#334](https://github.com/aquasecurity/aqua-helm/pull/334)

Improvements:
* Allowing web ingress path to be configured - [#313](https://github.com/aquasecurity/aqua-helm/pull/313)
* Adding aquasec envoy image and making certs mount for envoy optional - [#333](https://github.com/aquasecurity/aqua-helm/pull/333)

## 6.2.5 (July 15th, 2021)

Fixes:
* Fixed envoy config template issue - [#304](https://github.com/aquasecurity/aqua-helm/pull/304)

Improvements:
* Updating Image tag -> 6.2
* Added Giant Swarm platform support - [#304](https://github.com/aquasecurity/aqua-helm/pull/304)
* Added K3s platform support - [#304](https://github.com/aquasecurity/aqua-helm/pull/304)
* Added pod annotations support to templates - [#316](https://github.com/aquasecurity/aqua-helm/pull/316)

## 6.2.4 (June 15th, 2021)

Fixes:
* Fixed disabling DB persistence doesn't working issue [#288](https://github.com/aquasecurity/aqua-helm/pull/288)

Improvements:
* Envoy config templated and TLS certs for listener and cluster [#285](https://github.com/aquasecurity/aqua-helm/pull/285)
* Updating Image -> 6.2.RC2

## 6.2.3 (May 24th, 2021)

Bug Fixes:
* Fixed LoadBalancerIP issue [#142](https://github.com/aquasecurity/aqua-helm/issues/142) for server chart in aks environment - [#271](https://github.com/aquasecurity/aqua-helm/pull/271)

Improvements:
* added simple way to add certificates to enable mTLS/SSL for server gateway components and updated relevant Readme - [#266](https://github.com/aquasecurity/aqua-helm/pull/266)
* Updated Readme - [#273](https://github.com/aquasecurity/aqua-helm/pull/273)

## 6.2.2 (May 12th, 2021)

Improvements:
* Updating Image -> 6.2.RC1

## 6.2.1 (May 4th, 2021)

Improvements:
* Adding Changelog
* Updating Readme
* Updating Image ->  6.2.preview5