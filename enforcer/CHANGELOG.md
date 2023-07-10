# Changelog
All notable changes to this project will be documented in this file.

## 2022.4.14 ( Jun 27th, 2023 )
* Add windows enforcer support
## 2022.4.13 ( Apr 20th, 2023 )
* Increase enforcer memory limit in lightning to allow AMP - PR[#741](https://github.com/aquasecurity/aqua-helm/pull/741)
## 2022.4.12 ( Apr 10th, 2023 )
* Adjust default resource requests and limits - PR[#729](https://github.com/aquasecurity/aqua-helm/pull/729)
## 2022.4.11 ( Mar 22nd, 2023 )
* Update tolerations [723](https://github.com/aquasecurity/aqua-helm/issues/723)
## 2022.4.10 ( Feb 13th, 2023 )
* Update agent resource limits definition
## 2022.4.9 ( Nov 27th, 2022 )
* Change DS name when deployed using Express Mode.
* Add mount for Podman
## 2022.4.8 ( Nov 24th, 2022 )
* Add new capability LINUX_IMMUTABLE (SLK-59669)
* Change volume mount for tkg (SLK-58184)
## 2022.4.7 ( Nov 20th, 2022 )
* Added support for Ndots DNS configuration.
* Fix PodSecurityPolicy #[666](https://github.com/aquasecurity/aqua-helm/pull/666/)
## 2022.4.6 ( Jul 11th, 2022 )
* Add multi container engine support for different TKGi versions based only on platform choice
## 2022.4.5 ( Jul 6th, 2022 )
* Add HashiCorp Vault support to load token
## 2022.4.4 ( Jun 29th, 2022 )
* Fix hard-coded name of aqua enforcer in express mode deployment
## 2002.4.3 ( June 2nd, 2022 )
* Add resource definition in case of express-mode
## 2002.4.2 ( May 18th, 2022 )
* Rename RoleBinding to ClusterRole vmware-system-privileged if platform=tkg
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
