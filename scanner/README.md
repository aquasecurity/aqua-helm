<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Scanner Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Scanner CLI.

## Contents

- [Aqua Security Scanner Helm Chart](#aqua-security-scanner-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
  - [Configurable Variables](#configurable-variables)
    - [Scanner](#scanner)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Scanner from Github Repo

* Clone the GitHub repository with the charts

```bash
$ git clone -b 5.3 https://github.com/aquasecurity/aqua-helm.git
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

* Check for the available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
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
`serviceAccount` | k8s service account to use | `aqua-sa`| `YES` 
`server.scheme` | scheme for server to connect | `http`| `NO`
`server.serviceName` | service name for server to connect | `aqua-console-svc`| `YES` 
`server.port` | service port for server to connect | `8080`| `YES` 
`image.repository` | the docker image name to use | `scanner`| `YES` 
`image.tag` | The image tag to use. | `5.3`| `YES` 
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`user` | scanner username | `unset`| `YES` 
`password` | scanner password | `unset`| `YES` 
`replicaCount` | replica count | `1`| `NO` 
`resources` |	Resource requests and limits | `{}`| `NO` 
`nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`affinity` |	Kubernetes node affinity | `{}`| `NO` 
`extraEnvironmentVars` | is a list of extra environment variables to set in the scanner deployments. | `{}`| `NO` 
`extraSecretEnvironmentVars` | is a list of extra environment variables to set in the scanner deployments, these variables take value from existing Secret objects. | `[]`| `NO` 
## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
