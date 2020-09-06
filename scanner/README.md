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

Clone the GitHub repository with the chart

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

before installing scanner chart the recommandation is to create user with scanning permissions, [Link to documentations](https://docs.aquasec.com/docs/add-scanners#section-add-a-scanner-user)

```bash
helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>
```

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Scanner

Parameter | Description | Default
--------- | ----------- | -------
`repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`
`dockerSocket.mount` | boolean parameter if to mount docker socket | `unset`
`dockerSocket.path` | docker socket path | `/var/run/docker.sock`
`serviceAccount` | k8s service account to use | `aqua-sa`
`server.serviceName` | service name for server to connect | `aqua-console-svc`
`server.port` | service port for server to connect | `8080`
`image.repository` | the docker image name to use | `scanner`
`image.tag` | The image tag to use. | `5.3`
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`user` | scanner username | `unset`
`password` | scanner password | `unset`
`replicaCount` | replica count | `1`
`resources` |	Resource requests and limits | `{}`
`nodeSelector` |	Kubernetes node selector	| `{}`
`tolerations` |	Kubernetes node tolerations	| `[]`
`affinity` |	Kubernetes node affinity | `{}`
`extraEnvironmentVars` | is a list of extra enviroment variables to set in the scanner deployments. | `{}`
`extraSecretEnvironmentVars` | is a list of extra enviroment variables to set in the scanner deployments, these variables take value from existing Secret objects. | `[]`
## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
