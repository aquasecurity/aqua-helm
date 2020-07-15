<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Tenant Manager Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Tenant Manager.

## Contents

- [Aqua Security Enforcer Tenant Manager Chart](#aqua-security-tenant-manager-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Charts](#installing-the-charts)
  - [Configurable Variables](#configurable-variables)
    - [Tenant Manager](#tenant-manager)
  - [Issues and feedback](#issues-and-feedback)
  - [Support](#support)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Charts

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

```bash
helm upgrade --install --namespace aqua aqua-tenant-manager ./tenant-manager --set imageCredentials.username=<>,imageCredentials.password=<>
```

## Configurable Variables

### Tenant Manager

Parameter | Description | Default
--------- | ----------- | -------
`imageCredentials.create` | Set if to create new pull image secret | `false`
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`
`image.repository` | the docker image name to use | `enforcer`
`image.tag` | The image tag to use. | `5.0`
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`resources` |	Resource requests and limits | `{}`
`nodeSelector` |	Kubernetes node selector	| `{}`
`tolerations` |	Kubernetes node tolerations	| `[]`
`affinity` |	Kubernetes node affinity | `{}`

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.

## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.
