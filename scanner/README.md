<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Scanner Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Scanner CLI.

## Contents

- [Aqua Security Scanner Helm Chart](#aqua-security-scanner-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
    - [Scanner User Credentials](#scanner-user-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Scanner from Github Repo](#installing-aqua-scanner-from-github-repo)
    - [Installing Aqua Scanner from Helm Private Repository](#installing-aqua-scanner-from-helm-private-repository)
  - [Configurable Variables](#configurable-variables)
    - [Scanner](#scanner)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

### Scanner User Credentials

Before installing scanner chart the recommendation is to create user with scanning permissions, [Link to documentations](https://docs.aquasec.com/docs/add-scanners#section-add-a-scanner-user)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Scanner from Github Repo

* Clone the GitHub repository with the charts

```bash
$ git clone -b 6.2 https://github.com/aquasecurity/aqua-helm.git
$ cd aqua-helm/
```


* Install Aqua

```bash
$ helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>
```

### Installing Aqua Scanner from Helm Private Repository

* Add Aqua Helm Repository
```bash
$ helm repo add aqua-helm https://helm.aquasec.com
```

* Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
```bash
$ helm search repo aqua-helm/scanner --versions
```

* Install Aqua

```bash
$ helm upgrade --install --namespace aqua scanner aqua-helm/scanner --set imageCredentials.username=<>,imageCredentials.password=<> --version <>
```


Before installing scanner chart the recommendation is to create user with scanning permissions, [Link to documentations](https://docs.aquasec.com/docs/add-scanners#section-add-a-scanner-user)

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Scanner

Parameter | Description | Default| Mandatory 
--------- | ----------- | ------- | ------- 
`repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`| `YES` 
`dockerSocket.mount` | boolean parameter if to mount docker socket | `unset`| `NO` 
`dockerSocket.path` | docker socket path | `/var/run/docker.sock`| `NO` 
`serviceAccount.create` | Enable to create serviceaccount if not exist in the k8s | `false`| `NO`
`serviceAccount.name` | K8 service-account name either existing one or new name if create is enabled | `aqua-sa`  | `YES`
`server.scheme` | scheme for server to connect | `http`| `NO`
`server.serviceName` | service name for server to connect | `aqua-console-svc`| `YES` 
`server.port` | service port for server to connect | `8080`| `YES` 
`image.repository` | the docker image name to use | `scanner`| `YES` 
`image.tag` | The image tag to use. | `6.2.21166`| `YES` 
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`user` | scanner username | `unset`| `YES` 
`password` | scanner password | `unset`| `YES` 
`scannerUserSecret.enable` | change it to true for loading scanner user, scanner password from secret | `false` | `YES` <br /> `If password is not declared`
`scannerUserSecret.secretName` | secret name for the scanner user, scanner password secret | `null` | `YES` <br /> `If password is not declared`
`scannerUserSecret.userKey` | secret key of the scanner user | `null` | `YES` <br /> `If password is not declared`
`scannerUserSecret.passwordKey` | secret key of the scanner password | `null` | `YES` <br /> `If password is not declared`
`replicaCount` | replica count | `1`| `NO` 
`resources` |	Resource requests and limits | `{}`| `NO` 
`nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`affinity` |	Kubernetes node affinity | `{}`| `NO` 
`extraEnvironmentVars` | is a list of extra environment variables to set in the scanner deployments. | `{}`| `NO`
`extraSecretEnvironmentVars` | is a list of extra environment variables to set in the scanner deployments, these variables take value from existing Secret objects. | `[]`| `NO`
## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
