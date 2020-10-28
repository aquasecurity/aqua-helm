<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Gateway Helm Chart

Helm chart for installation and maintenance of Aqua Container Security Platform Gateway component to support multi-cluster use-case.

## Contents

- [Prerequisites](#prerequisites)
  - [Container Registry Credentials](#container-registry-credentials)
- [Installing the Chart](#installing-the-chart)
- [Configurable Variables](#configurable-variables)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)


## Installing the Chart

1. Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```



2. Edit values.yaml file in gateway directory with following details as prerequisite
   1. db.external.name - External database name
   2. db.external.host - External database public IP or endpoint URL
   3. db.external.port - External database port
   4. db.external.user - External database username
   5. db.external.password - External database password
   6. db.external.auditName - External audit database name
   7. db.external.auditHost - External audit database public IP or endpoint URL
   8. db.external.auditPort - External audit database port
   9. db.external.auditUser - External audit database username
   10. db.external.auditPassword - External audit database password
   11. console.publicIP - Aqua CSP console public IP or endpoint URL
   12. console.publicPort - Aqua CSP console public port
3. Install gateway component


```bash
helm upgrade --install --namespace aqua gateway ./gateway --set imageCredentials.username=<>,imageCredentials.password=<>
```

## Configurable Variables

Parameter | Description | Default
--------- | ----------- | -------
`imageCredentials.create` | Set if to create new pull image secret | `true`
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`
`rbac.enabled` | if to create rbac configuration for aqua | `true`
`rbac.privileged` | determines if any container in a pod can enable privileged mode. | `true`
`rbac.roleRef` | name of rbac role to set in not create by helm | `unset`
`db.external.enabled` | Avoid installing a Postgres container and use an external database instead | `false`
`db.external.name` | PostgreSQL DB name | `unset`
`db.external.host` | PostgreSQL DB hostname | `unset`
`db.external.port` | PostgreSQL DB port | `unset`
`db.external.user` | PostgreSQL DB username | `unset`
`db.external.password` | PostgreSQL DB password | `unset`
`db.external.auditName` | PostgreSQL DB audit name | `unset`
`db.external.auditHost` | PostgreSQL DB audit hostname | `unset`
`db.external.auditPort` | PostgreSQL DB audit port | `unset`
`db.external.auditUser` | PostgreSQL DB audit username | `unset`
`db.external.auditPassword` | PostgreSQL DB audit password | `unset`
`db.external.pubsubName` | PostgreSQL DB pubsub name | `unset`
`db.external.pubsubHost` | PostgreSQL DB pubsub hostname | `unset`
`db.external.pubsubPort` | PostgreSQL DB pubsub port | `unset`
`db.external.pubsubUser` | PostgreSQL DB pubsub username | `unset`
`db.external.pubsubPassword` | PostgreSQL DB pubsub password | `unset`
`db.passwordSecret` | password secret name | `null`
`db.dbPasswordName` | password secret name | `null`
`db.dbPasswordKey` | password secret key | `null`
`db.dbAuditPasswordName` | Audit password secret name | `null`
`db.dbAuditPasswordKey` | Audit password secret key | `null`
`db.dbPubsubPasswordName` | Pubsub password secret name | `null`
`db.dbPubsubPasswordKey` | Pubsub password secret key | `null`
`db.ssl` | If require an SSL-encrypted connection to the Postgres configuration database. |	`true`
`db.auditssl` | If require an SSL-encrypted connection to the Postgres configuration database. |	`true`
`gate.image.repository` | the docker image name to use | `gateway`
`gate.image.tag` | The image tag to use. | `5.3`
`gate.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`gate.service.type` | k8s service type | `ClusterIP`
`gate.service.ports` | array of ports settings | `array`
`gate.publicIP` | gateway public ip | `aqua-gateway`
`gate.replicaCount` | replica count | `1`
`gate.resources` |	Resource requests and limits | `{}`
`gate.nodeSelector` |	Kubernetes node selector	| `{}`
`gate.tolerations` |	Kubernetes node tolerations	| `[]`
`gate.affinity` |	Kubernetes node affinity | `{}`
`gate.securityContext` | Set of security context for the container | `nil`
`gate.extraEnvironmentVars` | is a list of extra enviroment variables to set in the gateway deployments. | `{}`
`gate.extraSecretEnvironmentVars` | is a list of extra enviroment variables to set in the gateway deployments, these variables take value from existing Secret objects. | `[]` 
