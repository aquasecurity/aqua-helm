## 5.3.1 (April 5th, 2021)

Improvements:
* Adding Changelog

## 5.3.2 (May 4th 2021)

Improvements:
* Updated Readme
* Added timeouts for KE webhooks [#246](https://github.com/aquasecurity/aqua-helm/pull/246)

## 5.3.3 (May 12th, 2021)

Bug Fixes:
* Fixed KE image pull secrets [#265](https://github.com/aquasecurity/aqua-helm/pull/265)

## 5.3.4 (July 15th, 2021)

Improvements:
* Added TLS/mTLS support by loading certs from secrets - [#305](https://github.com/aquasecurity/aqua-helm/pull/305)

## 5.3.6 (Aug 4th, 2021)

Fixes:
* Fixing rootca file not found issue when using CA certificates - [#328](https://github.com/aquasecurity/aqua-helm/pull/328)

Improvements:
* Adding NodeSelector support to the Kube Enforcer chart - [#336](https://github.com/aquasecurity/aqua-helm/pull/336)
* Allowing creation of the kube-enforcer-token secret to be disabled - [#336](https://github.com/aquasecurity/aqua-helm/pull/336)