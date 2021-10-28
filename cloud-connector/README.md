<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Cloud-Connector Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Cloud-Connector

## Contents

- [Aqua Security Cloud-Connector Helm Chart](#aqua-security-cloud-connector-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Cloud-Connector from Github Repo](#installing-aqua-cloud-connector-from-github-repo)
    - [Installing Aqua Cloud-Connector from Helm Private Repository](#installing-aqua-cloud-connector-from-helm-private-repository)
  - [Configurable Variables](#configurable-variables)
    - [Cloud-Connector](#cloud-connector)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Cloud-Connector from Github Repo

* Clone the GitHub repository with the charts

```shell
git clone -b 6.5 https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

* Install Aqua Cloud-Connector

```shell
helm upgrade --install --namespace aqua aqua-cloud-connector ./cloud-connector --set imageCredentials.username=<>,imageCredentials.password=<>
```

### Installing Aqua Cloud-Connector from Helm Private Repository

* Add Aqua Helm Repository
```shell
helm repo add aqua-helm https://helm.aquasec.com
```

* Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
```shell
helm search repo aqua-helm/cloud-connector --versions
```

* Install Aqua Cloud-Connector

```shell
helm upgrade --install --namespace aqua aqua-cloud-connector aqua-helm/cloud-connector --set imageCredentials.username=<>,imageCredentials.password=<> --version <>
```

## Configurable Variables

### Cloud-Connector

Parameter | Description | Default| Mandatory
--------- | ----------- | ------- | -------
`imageCredentials.create` | Set if to create new pull image secret | `false`| `YES - New cluster`
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`| `YES - New cluster`
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`| `YES - New cluster`
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`| `YES - New cluster`
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`| `YES - New cluster`
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`| `YES - New cluster`
`serviceAccount.create` | enable to create aqua-sa serviceaccount if it is missing in the environment | `false` | `YES - New cluster`
`image.repository` | the docker image name to use | `cc-standard`| `YES`
`image.tag` | The image tag to use. | `6.5`| `YES`
`image.pullPolicy` | The kubernetes image pull policy | `Always`| `NO`
`admin.username` | Admin Username |`unset`|`YES`
`admin.password` | Admin Password |`unset`|`YES`
`healthPort.port` | Aqua Cloud Connector Health Port | `8080` | `YES`
`tunnels.azure.registryHost` |Azure conatainer registry host, if ACR is in use for container images|`unset`| `NO`
`tunnels.azure.registryPort` |Azure conatainer registry port, if ACR is in use for container images|`unset`| `NO`
`tunnels.aws.registryHost` |AWS conatainer registry host, if ECR is in use for container images|`unset`| `NO`
`tunnels.aws.registryPort` |AWS conatainer registry type, if ECR is in use for container images|`ecr`| `NO`
`tunnels.aws.service.type` |AWS conatainer registry region, if ECR is in use for container images|`unset`| `YES - if AWS ECR in use`
`tunnels.aws.service.region` |AWS conatainer registry port, if ECR is in use for container images|`unset`| `YES - if AWS ECR in use`
`tunnels.gcp.registryHost` |GCP conatainer registry host, if GCR is in use for container images|`unset`| `NO`
`tunnels.gcp.registryPort` |Azure conatainer registry port, if GCR is in use for container images|`unset`| `NO`
`tunnels.jfrog.registryHost` |JFrog conatainer registry host, if JFrog regostry is in use for container images|`unset`|
`tunnels.jfrog.registryPort` |JFrog conatainer registry port, if JFrog registry is in use for container images|`unset`| `NO`
`tunnels.onprem.registryHost` |onprem conatainer registry host, if onprem registry is in use for container images|`unset`| `NO`
`tunnels.onprem.registryPort` |onprem conatainer registry port, if onprem registry is in use for container images|`unset`| `NO`
`gateway.host` | gateway host | `aqua-gateway-svc.aqua`| `YES`
`gateway.port` | gateway port | `8443`| `YES`
`TLS.aqua_verify_enforcer` | change it to "1" or "0" for enabling/disabling mTLS between enforcer and ay/envoy | `0`  |  `YES` <br /> `if TLS.enabled is set to true`
`container_securityContext.privileged` | Container security context | `false`| `NO`


> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true, set the username and password for the registry and `serviceAccount.create` is false and if you're environment is new or not having aqua-sa serviceaccount please update it to true.

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
