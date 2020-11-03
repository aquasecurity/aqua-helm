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
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

* Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

* Add Aqua Helm Repository
```bash
$ helm repo add aqua-helm https://helm.aquasec.com
```

* Install Aqua Enforcer

```bash
helm upgrade --install --namespace aqua aqua-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,enforcerToken=<aquasec-token>
```


## Guide how to create enforcer group in Kubernetes

Please login into Aqua Web UI then go to Enforcers section under Administrator tab to create a new enforcer group. Following are the required parameters to create a new group

| Parameter         | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| Enforcer Type     | Select **Aqua Enforcer**                                     |
| Group Name        | Enter the name for the Enforcer Group; this name will appear in the list of Enforcer groups |
| OS Type           | Select the OS type for the host                              |
| Orchestrator      | Select the orchestrator for which you are creating the Enforcer Group |
| Container Runtime | Select the container runtime environment from the drop-down list |
| Aqua Gateway      | Select the Aqua Gateway(s) that the Enforcer will use to communicate with the Aqua Server. If there is only one Gateway, you need not select anything. |

For more details please visit [Link](https://docs.aquasec.com/docs/kubernetes#section-step-4-deploy-aqua-enforcers)

## Configurable Variables

### Enforcer

Parameter | Description | Default| Mandatory 
--------- | ----------- | ------- | ------- 
`imageCredentials.create` | Set if to create new pull image secret | `false`| `YES - New cluster` 
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`| `YES - New cluster` 
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`| `YES - New cluster` 
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`| `YES - New cluster` 
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`| `YES - New cluster` 
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`| `YES - New cluster` 
`enforcerToken` | enforcer token value | `""`| `YES` 
`enforcerTokenSecretName` | enforcer token secret name if exists | `null`| `NO` 
`enforcerTokenSecretKey` | enforcer token secret key if exists | `null`| `NO` 
`enforcerLogicalName` | Specify the Logical Name the Aqua Enforcer will register under. if not specify the name will be `<Helm Release>-helm` | `unset`| `NO` 
`securityContext.privileged` | determines if any container in a pod can enable privileged mode. | `true`| `NO` 
`securityContext.capabilities` | Linux capabilities provide a finer grained breakdown of the privileges traditionally associated with the superuser. | `unset`| `NO` 
`hostRunPath` |	for changing host run path for example for pks need to change to /var/vcap/sys/run/docker	| `unset`| `NO` 
`gate.host` | gateway host | `aqua-gateway-svc`| `YES` 
`gate.port` | gateway port | `8443`| `YES` 
`image.repository` | the docker image name to use | `enforcer`| `YES` 
`image.tag` | The image tag to use. | `5.3`| `YES` 
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`resources` |	Resource requests and limits | `{}`| `NO` 
`nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`affinity` |	Kubernetes node affinity | `{}`| `NO` 
`extraEnvironmentVars` | is a list of extra enviroment variables to set in the enforcer daemonset. | `{}`| `NO` 
`extraSecretEnvironmentVars` | is a list of extra enviroment variables to set in the scanner daemonset, these variables take value from existing Secret objects. | `[]`| `NO` 
`envoy.enabled` | enabled envoy deployment to support in envoy deployment. | `false`| `NO` 
`envoy.configMap` | config map name with aqua certs for agent. | ``| `NO` 

> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true. and set the username and password for the registry.

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
