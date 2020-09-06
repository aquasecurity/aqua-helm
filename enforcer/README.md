<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Enforcer Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Enforcer

## Contents

- [Aqua Security Enforcer Helm Chart](#aqua-security-enforcer-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
  - [Configurable Variables](#configurable-variables)
    - [Enforcer](#enforcer)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Chart

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

```bash
helm upgrade --install --namespace aqua aqua-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,enforcerToken=<aquasec-token>
```

## Guide how to create enforcer group in Kubernetes

[Link](https://docs.aquasec.com/docs/kubernetes#section-step-4-deploy-aqua-enforcers)

## Configurable Variables

### Enforcer

Parameter | Description | Default
--------- | ----------- | -------
`imageCredentials.create` | Set if to create new pull image secret | `false`
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`
`enforcerToken` | enforcer token value | `""`
`enforcerTokenSecretName` | enforcer token secret name if exists | `null`
`enforcerTokenSecretKey` | enforcer token secret key if exists | `null`
`enforcerLogicalName` | Specify the Logical Name the Aqua Enforcer will register under. if not specify the name will be `<Helm Release>-helm` | `unset`
`securityContext.privileged` | determines if any container in a pod can enable privileged mode. | `true`
`securityContext.capabilities` | Linux capabilities provide a finer grained breakdown of the privileges traditionally associated with the superuser. | `unset`
`hostRunPath` |	for changing host run path for example for pks need to change to /var/vcap/sys/run/docker	| `unset`
`gate.host` | gateway host | `aqua-gateway-svc`
`gate.port` | gateway port | `8443`
`image.repository` | the docker image name to use | `enforcer`
`image.tag` | The image tag to use. | `5.3`
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`resources` |	Resource requests and limits | `{}`
`nodeSelector` |	Kubernetes node selector	| `{}`
`tolerations` |	Kubernetes node tolerations	| `[]`
`affinity` |	Kubernetes node affinity | `{}`
`extraEnvironmentVars` | is a list of extra enviroment variables to set in the enforcer daemonset. | `{}`
`extraSecretEnvironmentVars` | is a list of extra enviroment variables to set in the scanner daemonset, these variables take value from existing Secret objects. | `[]`
`envoy.enabled` | enabled envoy deployment to support in envoy deployment. | `false`
`envoy.configMap` | config map name with aqua certs for agent. | ``

> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true. and set the username and password for the registry.

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
