<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Server Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Console Server, Gateway, Database.

## Contents

- [Prerequisites](#prerequisites)
  - [Container Registry Credentials](#container-registry-credentials)
  - [Ingress](#ingress)
  - [PostgreSQL database](#postgresql-database)
- [Installing the Chart](#installing-the-chart)
- [Configurable Variables](#configurable-variables)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

### Ingress

[Link](../docs/ingress.md)

### PostgreSQL database

Aqua Security recommends implementing a highly-available PostgreSQL database. By default, the console chart will install a PostgreSQL database and attach it to persistent storage for POC usage and testing. For production use, one may override this default behavior and specify an existing PostgreSQL database by setting the following variables in values.yaml:

```yaml
db:
  external:
    enabled: true
    name: example-aquasec
    host: aquasec-db
    port: 5432
    user: aquasec-db-username
    password: verysecret
```
## Installing the Chart

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

```bash
helm upgrade --install --namespace aqua aqua ./server --set imageCredentials.username=<>,imageCredentials.password=<>
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
`activeactive` |	set in active active mode | `false`
`clustermode` |	set in HA cluster mode | `false`
`admin.token`| Use this Aqua license token | `unset`
`admin.password` | Use this Aqua admin password | `unset`
`admin.secretname` | use existing secret for admin password and token | `null`
`admin.tokenkey` | token key in the secret | `null`
`admin.passwordkey` | administrator password key in the secret | `null`
`docker.socket.path` | docker socket path | `/var/run/docker.sock`
`docker` | Scanning mode direct or docker [link](https://docs.aquasec.com/docs/scanning-mode#default-scanning-mode) | `-`
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
`db.persistence.enabled` | If true, Persistent Volume Claim will be created |	`true`
`db.persistence.accessModes` |	Persistent Volume access mode |	`ReadWriteOnce`
`db.persistence.size` |	Persistent Volume size | `30Gi`
`db.persistence.storageClass` |	Persistent Volume Storage Class | `unset`
`db.image.repository` | the docker image name to use | `database`
`db.image.tag` | The image tag to use. | `5.0`
`db.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`db.service.type` | k8s service type | `ClusterIP`
`db.resources` |	Resource requests and limits | `{}`
`db.nodeSelector` |	Kubernetes node selector	| `{}`
`db.tolerations` |	Kubernetes node tolerations	| `[]`
`db.affinity` |	Kubernetes node affinity | `{}`
`gate.image.repository` | the docker image name to use | `gateway`
`gate.image.tag` | The image tag to use. | `5.0`
`gate.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`gate.service.type` | k8s service type | `ClusterIP`
`gate.service.externalPort` | k8s service type | `3622`
`gate.service.nodePort` | k8s service type | `unset`
`gate.grpcservice.externalPort` | k8s service type | `8443`
`gate.grpcservice.nodePort` | k8s service type | `unset`
`gate.publicIP` | gateway public ip | `aqua-gateway`
`gate.replicaCount` | replica count | `1`
`gate.resources` |	Resource requests and limits | `{}`
`gate.nodeSelector` |	Kubernetes node selector	| `{}`
`gate.tolerations` |	Kubernetes node tolerations	| `[]`
`gate.affinity` |	Kubernetes node affinity | `{}`
`web.image.repository` | the docker image name to use | `console`
`web.image.tag` | The image tag to use. | `5.0`
`web.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`
`web.service.type` | k8s service type | `LoadBalancer`
`web.service.externalPort` | k8s service type | `8080`
`web.service.nodePort` | k8s service type | `unset`
`web.grpcservice.externalPort` | k8s service type | `443`
`web.grpcservice.nodePort` | k8s service type | `unset`
`web.replicaCount` | replica count | `1`
`web.resources` |	Resource requests and limits | `{}`
`web.nodeSelector` |	Kubernetes node selector	| `{}`
`web.tolerations` |	Kubernetes node tolerations	| `[]`
`web.affinity` |	Kubernetes node affinity | `{}`
`web.ingress.enabled` |	If true, Ingress will be created | `false`
`web.ingress.annotations` |	Ingress annotations	| `[]`
`web.ingress.hosts` | Ingress hostnames |	`[]`
`web.ingress.tls` |	Ingress TLS configuration (YAML) | `[]`

## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.
