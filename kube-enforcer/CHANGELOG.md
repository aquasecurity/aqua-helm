## 6.0.1 (April 5th, 2021)

Improvements:
* Adding Changelog

## 6.0.2 (May 5th, 2021)

Improvements:
* Updated Readme
* Added timeouts for KE webhooks #[245](https://github.com/aquasecurity/aqua-helm/pull/245)

## 6.0.3 (May 12th, 2021)

Fixes:
* Fixed KE image pull secrets #[264](https://github.com/aquasecurity/aqua-helm/pull/264)

## 6.0.4 (July 15th, 2021)

Improvements:
* Added TLS/mTLS support by loading certs from secrets - [#306](https://github.com/aquasecurity/aqua-helm/pull/306)
* Added pod annotations support to templates - [#317](https://github.com/aquasecurity/aqua-helm/pull/317)

## 6.0.5 (August 4th, 2021)

Fixes:
* Fixing rootca file not found issue when using CA certificates - [#337](https://github.com/aquasecurity/aqua-helm/pull/337)

Improvements:
* Adding NodeSelector support to the Kube Enforcer chart - [#335](https://github.com/aquasecurity/aqua-helm/pull/335)
* Allowing creation of the kube-enforcer-token secret to be disabled - [#335](https://github.com/aquasecurity/aqua-helm/pull/335)