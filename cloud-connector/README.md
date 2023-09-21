<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Cloud-Connector Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Cloud-Connector

## Contents

- [Aqua Security Cloud-Connector Helm Chart](#aqua-security-cloud-connector-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Cloud-Connector from Helm Private Repository](#installing-aqua-cloud-connector-from-helm-private-repository)
  - [Configurable Variables](#configurable-variables)
    - [Cloud-Connector](#cloud-connector)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))
### Installing Aqua Cloud-Connector from Helm Private Repository

* Add Aqua Helm Repository
```shell
helm repo add aqua-helm https://helm.aquasec.com
helm repo update
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

| Parameter                              | Description                                                                        | Default                 | Mandatory                                    |
|----------------------------------------|------------------------------------------------------------------------------------|-------------------------|----------------------------------------------|
| `imageCredentials.create`              | Set if to create new pull image secret                                             | `false`                 | `YES - New cluster`                          |
| `imageCredentials.name`                | Your Docker pull image secret name                                                 | `aqua-registry-secret`  | `YES - New cluster`                          |
| `imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io`                                | `registry.aquasec.com`  | `YES - New cluster`                          |
| `imageCredentials.registry`            | set the registry url for dockerhub set `index.docker.io/v1/`                       | `registry.aquasec.com`  | `YES - New cluster`                          |
| `imageCredentials.username`            | Your Docker registry (DockerHub, etc.) username                                    | `aqua-registry-secret`  | `YES - New cluster`                          |
| `imageCredentials.password`            | Your Docker registry (DockerHub, etc.) password                                    | `""`                    | `YES - New cluster`                          |
| `serviceaccount.create`                | enable to create aqua-sa serviceaccount if it is missing in the environment        | `false`                 | `YES - New cluster`                          |
| `image.repository`                     | the docker image name to use                                                       | `cc-standard`           | `YES`                                        |
| `image.tag`                            | The image tag to use.                                                              | `2022.4`                | `YES`                                        |
|  `image.pullPolicy`                    | The kubernetes image pull policy                                                   | `Always`                | `NO`                                         |
| `replicaCount`                         | Kubernetes replica count                                                           | `1`                     | `YES`                                        |
| `authType.tokenAuth`                   | Boolean value to select authentication type as token                               | `true`                  | `YES`                                        |
| `authType.userCreds`                   | Boolean value to select authentication type as user/password                       | `false`                 | `YES`                                        |
| `token`                                | Token value generated from the UI                                                  | `""`                    | `YES - authtype selected as token`           |
| `tokenFromSecret.enable`               | Enable to true to load token from existing secret                                  | `false`                 | `NO`                                         |
| `tokenFromSecret.secretName`           | Loaded secret name for token                                                       | `""`                    | `NO`                                         |
| `tokenFromSecret.tokenKey`             | Loaded secret token key value                                                      | `""`                    | `NO`                                         |
| `userCreds.username`                   | Admin Username                                                                     | `""`                    | `YES`                                        |
| `userCreds.password`                   | Admin Password                                                                     | `""`                    | `YES`                                        |
| `userCredsFromSecret.enable`           | Enable to true to load user credentials from existing secret                       | `false`                 | `NO`                                         |
| `userCredsFromSecret.secretName`       | Loaded secret name for user credentials                                            | `""`                    | `NO`                                         |
| `userCredsFromSecret.userKey`          | Loaded secret username key value                                                   | `""`                    | `NO`                                         |
| `userCredsFromSecret.passwordKey`      | loaded secret password key value                                                   | `""`                    | `NO`                                         |
| `healthPort.port`                      | Aqua Cloud Connector Health Port                                                   | `8080`                  | `YES`                                        |
| `tunnels.azure.registryHost`           | Azure conatainer registry host, if ACR is in use for container images              | `""`                    | `NO`                                         |
| `tunnels.azure.registryPort`           | Azure conatainer registry port, if ACR is in use for container images              | `""`                    | `NO`                                         |
| `tunnels.aws.registryHost`             | AWS conatainer registry host, if ECR is in use for container images                | `""`                    | `NO`                                         |
| `tunnels.aws.registryPort`             | AWS conatainer registry type, if ECR is in use for container images                | `ecr`                   | `NO`                                         |
| `tunnels.aws.service.type`             | AWS conatainer registry region, if ECR is in use for container images              | `""`                    | `YES - if AWS ECR in use`                    |
| `tunnels.aws.service.region`           | AWS conatainer registry port, if ECR is in use for container images                | `""`                    | `YES - if AWS ECR in use`                    |
| `tunnels.gcp.registryHost`             | GCP conatainer registry host, if GCR is in use for container images                | `""`                    | `NO`                                         |
| `tunnels.gcp.registryPort`             | Azure conatainer registry port, if GCR is in use for container images              | `""`                    | `NO`                                         |
| `tunnels.jfrog.registryHost`           | JFrog conatainer registry host, if JFrog regostry is in use for container images   | `""`                    |                                              |
| `tunnels.jfrog.registryPort`           | JFrog conatainer registry port, if JFrog registry is in use for container images   | `""`                    | `NO`                                         |
| `tunnels.onprem.registryHost`          | onprem conatainer registry host, if onprem registry is in use for container images | `""`                    | `NO`                                         |
| `tunnels.onprem.registryPort`          | onprem conatainer registry port, if onprem registry is in use for container images | `""`                    | `NO`                                         |
| `gateway.host`                         | gateway host                                                                       | `aqua-gateway-svc.aqua` | `YES`                                        |
| `gateway.port`                         | gateway port                                                                       | `8443`                  | `YES`                                        |
| `TLS.aqua_verify_enforcer`             | change it to "1" or "0" for enabling/disabling mTLS between enforcer and envoy     | `0`                     | `YES` <br /> `if TLS.enabled is set to true` |
| `container_securityContext.privileged` | Container security context                                                         | `false`                 | `NO`                                         |
| `resources`                            | 	Resource requests and limits                                                   | `{}`                    | `NO`                                         |
| `nodeSelector`                         | 	Kubernetes node selector	                                                   | `{}`                    | `NO`                                         |
| `tolerations`                          | 	Kubernetes node tolerations	                                                   | `[]`                    | `NO`                                         |
| `podAnnotations`                       | Kubernetes pod annotations                                                         | `{}`                    | `NO`                                         |
| `extraEnvironmentVars`                 | is a list of extra environment variables to set in the cc deployments.             | `{}`                    | `NO`                                         |
| `affinity`                             | 	Kubernetes node affinity                                                       | `{}`                    | `NO`                                         |


> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true, set the username and password for the registry and `serviceAccount.create` is false and if you're environment is new or not having aqua-sa serviceaccount please update it to true.

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
