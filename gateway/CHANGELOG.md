## 6.0.1 (April 5th, 2021)

Improvements:
* Adding Changelog

## 6.0.2 (July 15th, 2021)

Fixes:
* Fixed service account missmatch [#issue](https://github.com/aquasecurity/aqua-helm/issues/276) - [#298](https://github.com/aquasecurity/aqua-helm/pull/298)


Improvements:
* Added TLS/mTLS support by loading certs from secrets - [#298](https://github.com/aquasecurity/aqua-helm/pull/298)
* Added support to load password for external DB from secrets - [#298](https://github.com/aquasecurity/aqua-helm/pull/298)
* Added pod annotations support to templates - [#317](https://github.com/aquasecurity/aqua-helm/pull/317)

## 6.0.3 (August 4th, 2021)

Fixes:
* Fixing rootca file not found issue when using CA certificates - [#337](https://github.com/aquasecurity/aqua-helm/pull/337)