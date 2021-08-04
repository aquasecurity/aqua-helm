## 6.2.1 (May 4th, 2021)

Improvements:
* Adding Changelog
* Updating Readme
* Updating Image tag -> 6.2.preview5

## 6.2.2 (May 12th, 2021)

Bug Fixes:
* Fixed KE image pull secrets #[263](https://github.com/aquasecurity/aqua-helm/pull/263)

Improvements:
* Updating Image tag -> 6.2.RC1

## 6.2.3 (July 15th, 2021)

Fixes:
* Fixed static namepace value "aqua" to load from values.yaml - [#309](https://github.com/aquasecurity/aqua-helm/pull/309)

Improvements:
* Updating Image tag -> 6.2
* Added TLS/mTLS support by loading certs from secrets - [#307](gen_ke_certs.sh307)
* Added pod annotations support to templates - [#316](https://github.com/aquasecurity/aqua-helm/pull/316)

## 6.2.4 (August 4th, 2021)

Fixes:
* Fixing rootca file not found issue when using CA certificates - [#329](https://github.com/aquasecurity/aqua-helm/pull/329)

Improvements:
* Updated README file - [#323](https://github.com/aquasecurity/aqua-helm/pull/323), [#327](https://github.com/aquasecurity/aqua-helm/pull/327)
* Adding NodeSelector support to the Kube Enforcer chart - [#315](https://github.com/aquasecurity/aqua-helm/pull/315)
* Allow creation of the kube-enforcer-token secret to be disabled - [#316](https://github.com/aquasecurity/aqua-helm/pull/316)