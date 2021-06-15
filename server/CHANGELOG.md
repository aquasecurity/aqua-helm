## 6.0.1 (April 5th, 2021)

Improvements:
* Adding Changelog

## 6.0.2 (May 5th, 2021)

Improvements:
* Updated Readme
* Added Maintenance DB support [#245](https://github.com/aquasecurity/aqua-helm/pull/245)
* added annotations support foe SA creation [#248](https://github.com/aquasecurity/aqua-helm/pull/248)

## 6.0.3 (May 24th, 2021)

Bug Fixes:
* Fixed LoadBalancerIP issue [#142](https://github.com/aquasecurity/aqua-helm/issues/142) for server chart in aks environment - [#270](https://github.com/aquasecurity/aqua-helm/pull/270)

Improvements:
* added simple way to add certificates to enable mTLS/SSL for server gateway components and updated relevant Readme - [#267](https://github.com/aquasecurity/aqua-helm/pull/267)
* Updated Readme - [#272](https://github.com/aquasecurity/aqua-helm/pull/272)

## 6.0.4 (June 15th, 2021)

Fixes:
* Fixed disabling DB persistence doesn't working issue [#288](https://github.com/aquasecurity/aqua-helm/pull/288)
* Fixed issue [#290](https://github.com/aquasecurity/aqua-helm/issues/290) - [#293](https://github.com/aquasecurity/aqua-helm/pull/293)

Improvements:
* Envoy config templated and TLS certs for listener and cluster [#283](https://github.com/aquasecurity/aqua-helm/pull/283)
