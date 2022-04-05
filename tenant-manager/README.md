<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Tenant Manager Helm Chart

These are Helm charts for the deployment and maintenance of the Aqua Tenant Manager.
## Contents

- [Aqua Security Tenant Manager Helm Chart](#aqua-security-tenant-manager-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container registry credentials](#container-registry-credentials)
    - [PostgreSQL database](#postgresql-database)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Tenant Manager from Github Repo](#installing-aqua-tenant-manager-from-github-repo)
    - [Installing Aqua Tenant Manager from Helm Private Repository](#installing-aqua-tenant-manager-from-helm-private-repository)
  - [Database](#database)
  - [Configuring HTTPS for the Aqua Tenant Manager](#configuring-https-for-the-aqua-tenant-manager)
  - [Configurable variables](#configurable-variables)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container registry credentials

See [Container registry credentials](../docs/imagepullsecret.md).

### PostgreSQL database

Aqua Security recommends implementing a highly-available PostgreSQL database. By default, the Tenant Manager chart will install a PostgreSQL database and attach it to persistent storage for POC usage and testing. For production use, you can override this default behavior and specify an existing PostgreSQL database by setting the following variables in values.yaml:

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
Follow the steps in this section for production-grade deployments. You can either clone the aqua-helm GitHub repo or you can add our private Helm repository ([https://helm.aquasec.com](https://helm.aquasec.com)).

### Installing Aqua Tenant Manager from Helm Private Repository
  
* Add the Aqua Helm repository

```shell
helm repo add aqua-helm https://helm.aquasec.com
```

* Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
```shell
helm search repo aqua-helm/tenant-manager --versions
```

* Deploy the Aqua Tenant Manager

```shell
helm upgrade --install --namespace aqua tenant-manager aqua-helm/tenant-manager --set imageCredentials.username=<>,imageCredentials.password=<>,platform=<>
```

## Database

   1. By default, the Aqua Helm chart will deploy a database container. If you wish to use an external database, set `db.external.enabled` to true and the following with appropriate values:
      ```shell
      1. db.external.name
      2. db.external.host
      3. db.external.port
      4. db.external.user
      5. db.external.password
      ```
   2. By default, the same database (Packaged DB Container | Managed DB like AWS RDS) will be used to host both the main DB and the audit DB. If you want to use a different database for the audit DB, set the following variables in the values.yaml file:
      ```shell
      1. db.external.auditName
      2. db.external.auditHost
      3. db.external.auditPort
      4. db.external.auditUser
      5. db.external.auditPassword      
      ```
   3. If you are using the Aqua packaged DB container then:
   
      * The `AQUA_ENV_SIZE` variable can be used to define the size of your DB container in terms of the number of connections and optimized configuration (but not the PV size). Choose the appropriate PV size as per your requirements.
      * By default, `AQUA_ENV_SIZE` is set to `"S"`; other allowed values are `"M"` and `"L"`.
   
## Configuring HTTPS for the Aqua Tenant Manager

   By default, Aqua will generate a self-signed cert and will use the same for HTTPS communication. If you wish to use your own SSL/TLS certs, you can do this in two different ways:

   e.g., LoadBalancer(Default): Use the `AQUA_PUBLIC_KEY`, `AQUA_PRIVATE_KEY`, and `AQUA_ROOT_CA` environment variables to specify the TLS cert path. Make sure to mount the TLS cert into the container.


## Configurable variables

Parameter | Description | Default                | Mandatory 
--------- | ----------- |------------------------| ------- 
`imageCredentials.create` | Whether to create a new pull image secret | `true`                 | `YES` 
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret` | `YES` 
`imageCredentials.repositoryUriPrefix` | Repository URI prefix for Docker Hub set `docker.io` | `registry.aquasec.com` | `YES` 
`imageCredentials.registry` | Registry URL for Docker Hub `index.docker.io/v1/` | `registry.aquasec.com` | `YES` 
`imageCredentials.username` | Your Docker registry (Docker Hub, etc.) username | `aqua-registry-secret` | `YES` 
`imageCredentials.password` | Your Docker registry (Docker Hub, etc.) password | `unset`                | `YES` 
`platform` | Orchestration platform (allowed values are aks, eks, gke, openshift, tkg, tkgi, k8s) | `unset`                | `YES`
`clusterRole.roleRef` | cluster role reference name for cluster rolebinding | `unset`                | `NO`
`admin.token`| Use this Aqua license token | `unset`                | `NO` 
`admin.password` | Use this Aqua admin password | `unset`                | `NO` 
`db.external.enabled` | Avoid installing the packaged DB (Postgres container); use an external database instead | `false`                | `YES` 
`db.external.name` | PostgreSQL DB name | `unset`                | `YES`<br />`if db.external.enabled is set to true` 
`db.external.host` | PostgreSQL DB hostname | `unset`                | `YES`<br />`if db.external.enabled is set to true` 
`db.external.port` | PostgreSQL DB port | `unset`                | `YES`<br />`if db.external.enabled is set to true` 
`db.external.user` | PostgreSQL DB username | `unset`                | `YES`<br />`if db.external.enabled is set to true` 
`db.external.password` | PostgreSQL DB password | `unset`                | `YES`<br />`if db.external.enabled is set to true` 
`db.external.auditName` | PostgreSQL DB audit name | `unset`                | `NO` 
`db.external.auditHost` | PostgreSQL DB audit hostname | `unset`                | `NO` 
`db.external.auditPort` | PostgreSQL DB audit port | `unset`                | `NO` 
`db.external.auditUser` | PostgreSQL DB audit username | `unset`                | `NO` 
`db.external.auditPassword` | PostgreSQL DB audit password | `unset`                | `NO` 
`db.passwordFromSecret.enabled` | Enable to load DB passwords from ecrets | `false`                | `YES`
`db.passwordFromSecret.dbPasswordName` | Password secret name | `null`                 | `NO`
`db.passwordFromSecret.dbPasswordKey` | Password secret key | `null`                 | `NO`
`db.passwordFromSecret.dbAuditPasswordName` | Audit password secret name | `null`                 | `NO`
`db.passwordFromSecret.dbAuditPasswordKey` | Audit password secret key | `null`                 | `NO`
`db.persistence.enabled` | If true, a PVC (persistent volume claim) will be created | 	`true`                | `NO` 
`db.persistence.accessModes` |	Persistent volume access mode | 	`ReadWriteOnce`       | `NO` 
`db.persistence.size` |	Persistent volume size | `30Gi`                 | `NO` 
`db.persistence.storageClass` |	Persistent volume storage class | `unset`                | `NO` 
`db.image.repository` | Docker image name to use | `database`             | `NO` 
`db.image.tag` | Image tag to use | `2022.4`               | `NO`
`db.image.pullPolicy` | Kubernetes image pull policy | `IfNotPresent`         | `NO` 
`db.service.type` | Kubernetes service type | `ClusterIP`            | `NO` 
`db.resources` |	Resource requests and limits | `{}`                   | `NO` 
`db.nodeSelector` |	Kubernetes node selector	| `{}`                   | `NO` 
`db.tolerations` |	Kubernetes node tolerations	| `[]`                   | `NO` 
`db.affinity` |	Kubernetes node affinity | `{}`                   | `NO` 
`db.podAnnotations` | Kubernetes pod annotations | `{}`                   | `NO`
`db.securityContext` | Set of security context for the container | `nil`                  | `NO` 
`db.extraEnvironmentVars` | List of extra environment variables to set in the database deployments | `{}`                   | `NO`
`db.extraSecretEnvironmentVars` | List of extra environment variables to set in the database deployments; these variables take values from existing Secret objects | `[]`                   | `NO`
`tenantmanager.image.repository` | Docker image name to use | `tenantmanager`        | `NO` 
`tenantmanager.image.tag` | Image tag to use | `2022.4`               | `NO`
`tenantmanager.image.pullPolicy` | Kubernetes image pull policy | `IfNotPresent`         | `NO` 
`tenantmanager.service.type` | Kubernetes service type | `LoadBalancer`         | `NO` 
`tenantmanager.service.annotations` |	Service annotations	| `{}`                   | `NO`
`tenantmanager.service.ports` | Array of port settings | `array`                | `NO` 
`tenantmanager.replicaCount` | Replica count | `1`                    | `NO` 
`tenantmanager.resources` |	Resource requests and limits | `{}`                   | `NO` 
`tenantmanager.nodeSelector` |	Kubernetes node selector	| `{}`                   | `NO` 
`tenantmanager.tolerations` |	Kubernetes node tolerations	| `[]`                   | `NO` 
`tenantmanager.affinity` |	Kubernetes node affinity | `{}`                   | `NO` 
`tenantmanager.podAnnotations` | Kubernetes pod annotations | `{}`                   | `NO`
`tenantmanager.ingress.enabled` |	If true, Ingress will be created | `false`                | `NO` 
`tenantmanager.ingress.annotations` |	Ingress annotations	| `[]`                   | `NO` 
`tenantmanager.ingress.hosts` | Ingress hostnames | 	`[]`                  | `NO` 
`tenantmanager.ingress.tls` |	Ingress TLS configuration (YAML) | `[]`                   | `NO` 
`tenantmanager.securityContext` | Set of security context for the container | `nil`                  | `NO` 
`tenantmanager.TLS.enabled` | Whether to require secure channel communication | `false`                | `NO`
`tenantmanager.TLS.secretName` | Certificates secret name | `nil`                  | `NO`
`tenantmanager.maintenance_db.name` | If Configured to use custom maintanance DB specify the DB name | `nil`                  | `NO` 
`tenantmanager.extraEnvironmentVars` | List of extra environment variables to set in the Tenant Manager deployments | `{}`                   | `NO`
`tenantmanager.extraSecretEnvironmentVars` | List of extra environment variables to set in the Tenant Manager deployments; these variables take values from existing Secret objects. | `[]`                   | `NO`


## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
