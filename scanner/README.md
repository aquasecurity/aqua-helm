<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Scanner Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Scanner CLI.

## Contents

- [Aqua Security Scanner Helm Chart](#aqua-security-scanner-helm-chart)
  - [Contents](#contents)
  - [Installing the Chart](#installing-the-chart)
  - [Configurable Variables](#configurable-variables)
    - [Scanner](#scanner)
  - [Support](#support)
  
## Installing the Chart

Clone the GitHub repository with the chart

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

```bash
helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>
```

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Scanner

Parameter | Description | Default
--------- | ----------- | -------
`repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`
`docker.socket.path` | docker socket path | `/var/run/docker.sock`
`docker` | Scanning mode direct or docker [link](https://docs.aquasec.com/docs/scanning-mode#default-scanning-mode) | `-`
`serviceAccount` | k8s service account to use | `aqua-sa`
`server.serviceName` | service name for server to connect | `aqua-console-svc`
`server.port` | service port for server to connect | `8080`
`image.repository` | the docker image name to use | `scanner`
`image.tag` | The image tag to use. | `4.6`
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`user` | scanner username | `unset`
`password` | scanner password | `unset`
`replicaCount` | replica count | `1`
`resources` |	Resource requests and limits | `{}`
`nodeSelector` |	Kubernetes node selector	| `{}`
`tolerations` |	Kubernetes node tolerations	| `[]`
`affinity` |	Kubernetes node affinity | `{}`

## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.