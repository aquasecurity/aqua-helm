## 5.3.1 (April 5th, 2021)

Improvements:
* Adding Changelog

# 5.3.2 (May 4th, 2021)

Improvements:
* Updated Readme
* Added Maintenance Db support [#246](https://github.com/aquasecurity/aqua-helm/pull/246)
* added annotations support for SA creation  [#249](https://github.com/aquasecurity/aqua-helm/pull/249)

# 5.3.3 (May 24th, 2021)

Bug Fixes:
* Fixed LoadBalancerIP issue [#142](https://github.com/aquasecurity/aqua-helm/issues/142) for server chart in aks environment - [#269](https://github.com/aquasecurity/aqua-helm/pull/269)

Improvements:
* added simple way to add certificates to enable mTLS/SSL for server gateway components and updated relevant Readme - [#268](https://github.com/aquasecurity/aqua-helm/pull/268)
* Updated Readme - [#274](https://github.com/aquasecurity/aqua-helm/pull/272)

## 5.3.4 (June 15th, 2021)

Fixes:
* Fixed disabling DB persistence doesn't working issue [#289](https://github.com/aquasecurity/aqua-helm/pull/289)
* Fixed issue [#290](https://github.com/aquasecurity/aqua-helm/issues/290) - [#292](https://github.com/aquasecurity/aqua-helm/pull/292)

Improvements:
* Envoy config templated and TLS certs for listener and cluster [#284](https://github.com/aquasecurity/aqua-helm/pull/284)
