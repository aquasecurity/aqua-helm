# Changelog

All notable changes to this project will be documented in this file.

## 2022.4.1 (May 5th, 2022)
* fix issue #[581](https://github.com/aquasecurity/aqua-helm/issues/581) of duplicate hostPID parameter

## 2022.4.0 ( Apr 5th, 2022)
* Init commit
* Add new variable `expressMode`, default value is `false`

### ⚠ BREAKING CHANGES
* From release 2022.4 the Kube Enforcer chart will support Express Mode, when variable `global.enforcer.enabled` defined as `true` in the Kube Enforcer chart, the Enforcer chart will be installed also
* The following variables moved to the global scope
    * platform --> global.platform
    * gateway.host --> global.gateway.address
    * gateway.port --> global.gateway.port
    * imageCredentials.* --> global.imageCredentials.*