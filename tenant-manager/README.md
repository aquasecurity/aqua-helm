<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security tenantmanager Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Tenant Manager.
## Contents

- [Prerequisites](#prerequisites)
  - [Container Registry Credentials](#container-registry-credentials)
  - [PostgreSQL database](#postgresql-database)
- [Installing the Chart](#installing-the-chart)
- [Configurable Variables](#configurable-variables)
- [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

### PostgreSQL database

Aqua Security recommends implementing a highly-available PostgreSQL database. By default, the tenantmanager chart will install a PostgreSQL database and attach it to persistent storage for POC usage and testing. For production use, one may override this default behavior and specify an existing PostgreSQL database by setting the following variables in values.yaml:

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
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

* 1. Using Github repo 
    a. Clone the GitHub repository with the charts

    ```bash
    git clone https://github.com/aquasecurity/aqua-helm.git
    cd aqua-helm/
    ```
    b. Install Aqua Tenant Manager

    ```bash
    helm upgrade --install --namespace aqua aqua ./tenant-manger --set imageCredentials.username=<>,imageCredentials.password=<>,platform=<>
    ```

* 2. Using Helm Repo 
    a. Add Aqua Helm Repository

    ```bash
    $ helm repo add aqua-helm https://helm.aquasec.com
    ```
    b.Install Aqua Tenant Manager

    ```bash
    helm upgrade --install --namespace aqua <release_name> aqua-helm/tenant-manager --set imageCredentials.username=<>,imageCredentials.password=<>,platform=<>


2. Database

   1. By default aqua helm chart will deploy a database container. If you wish to use an external database please set `db.external.enabled` to true and the following with appropriate values.
      ```shell
      1. db.external.name
      2. db.external.host
      3. db.external.port
      4. db.external.user
      5. db.external.password
      ```
   2. By default same database (Packaged DB Container | Managed DB like AWS RDS) will be used to host both main DB and Audit DB. If you want to use a different database for audit db then set following variables in the values.yaml file
      ```shell
      1. db.external.auditName
      2. db.external.auditHost
      3. db.external.auditPort
      4. db.external.auditUser
      5. db.external.auditPassword      
      ```
   3. If you are using packaged DB container then
      1. AQUA_ENV_SIZE variable can be used to define the sizing of your DB container in terms of number of connections and optimized configuration but not the PV size. Please choose appropriate PV size as per your requirements.
      2. By default AQUA_ENV_SIZE is set to `"S"` and the possible values are `"M", "L"`
   
3. Configuring HTTPS for Aqua's tenantmanager

   By default Aqua will generate a self signed cert and will use the same for HTTPS communication. If you wish to use your own SSL/TLS certs you can do this in two different ways

   eg: LoadBalancer(Default): Use AQUA_PUBLIC_KEY, AQUA_PRIVATE_KEY, and AQUA_ROOT_CA environment variables to specify the TLS cert path. Make sure to mount the TLS cert into the container.


## Configurable Variables

Parameter | Description | Default| Mandatory 
--------- | ----------- | ------- | ------- 
`imageCredentials.create` | Set if to create new pull image secret | `true`| `YES` 
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`| `YES` 
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`| `YES` 
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`| `YES` 
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`| `YES` 
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`| `YES` 
`platform` | Orchestration platform name (Allowed values are aks, eks, gke, openshift, tkg, tkgi, k8s) | `unset` | `YES`
`rbac.enabled` | if to create rbac configuration for aqua | `true`| `YES` 
`rbac.privileged` | determines if any container in a pod can enable privileged mode. | `true`| `NO` 
`rbac.roleRef` | name of rbac role to set in not create by helm | `unset`| `NO` 
`admin.token`| Use this Aqua license token | `unset`| `NO` 
`admin.password` | Use this Aqua admin password | `unset`| `NO` 
`db.external.enabled` | Avoid installing a Postgres container and use an external database instead | `false`| `YES` 
`db.external.name` | PostgreSQL DB name | `unset`| `YES`<br />`if db.external.enabled is set to true` 
`db.external.host` | PostgreSQL DB hostname | `unset`| `YES`<br />`if db.external.enabled is set to true` 
`db.external.port` | PostgreSQL DB port | `unset`| `YES`<br />`if db.external.enabled is set to true` 
`db.external.user` | PostgreSQL DB username | `unset`| `YES`<br />`if db.external.enabled is set to true` 
`db.external.password` | PostgreSQL DB password | `unset`| `YES`<br />`if db.external.enabled is set to true` 
`db.external.auditName` | PostgreSQL DB audit name | `unset`| `NO` 
`db.external.auditHost` | PostgreSQL DB audit hostname | `unset`| `NO` 
`db.external.auditPort` | PostgreSQL DB audit port | `unset`| `NO` 
`db.external.auditUser` | PostgreSQL DB audit username | `unset`| `NO` 
`db.external.auditPassword` | PostgreSQL DB audit password | `unset`| `NO` 
`db.passwordFromSecret.enabled` | Enable to load DB passwords from Secrets | `false` | `YES`
`db.passwordFromSecret.dbPasswordName` | password secret name | `null`| `NO`
`db.passwordFromSecret.dbPasswordKey` | password secret key | `null`| `NO`
`db.passwordFromSecret.dbAuditPasswordName` | Audit password secret name | `null`| `NO`
`db.passwordFromSecret.dbAuditPasswordKey` | Audit password secret key | `null`| `NO`
`db.persistence.enabled` | If true, Persistent Volume Claim will be created |	`true`| `NO` 
`db.persistence.accessModes` |	Persistent Volume access mode |	`ReadWriteOnce`| `NO` 
`db.persistence.size` |	Persistent Volume size | `30Gi`| `NO` 
`db.persistence.storageClass` |	Persistent Volume Storage Class | `unset`| `NO` 
`db.image.repository` | the docker image name to use | `database`| `NO` 
`db.image.tag` | The image tag to use. | `5.3`| `NO` 
`db.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`db.service.type` | k8s service type | `ClusterIP`| `NO` 
`db.resources` |	Resource requests and limits | `{}`| `NO` 
`db.nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`db.tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`db.affinity` |	Kubernetes node affinity | `{}`| `NO` 
`db.securityContext` | Set of security context for the container | `nil`| `NO` 
`db.extraEnvironmentVars` | is a list of extra environment variables to set in the database deployments. | `{}`| `NO`
`db.extraSecretEnvironmentVars` | is a list of extra environment variables to set in the database deployments, these variables take value from existing Secret objects. | `[]`| `NO`
`tenantmanager.image.repository` | the docker image name to use | `tenantmanager`| `NO` 
`tenantmanager.image.tag` | The image tag to use. | `5.3`| `NO` 
`tenantmanager.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`tenantmanager.service.type` | k8s service type | `LoadBalancer`| `NO` 
`tenantmanager.service.annotations` |	service annotations	| `{}`| `NO`
`tenantmanager.service.ports` | array of ports settings | `array`| `NO` 
`tenantmanager.replicaCount` | replica count | `1`| `NO` 
`tenantmanager.resources` |	Resource requests and limits | `{}`| `NO` 
`tenantmanager.nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`tenantmanager.tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`tenantmanager.affinity` |	Kubernetes node affinity | `{}`| `NO` 
`tenantmanager.ingress.enabled` |	If true, Ingress will be created | `false`| `NO` 
`tenantmanager.ingress.annotations` |	Ingress annotations	| `[]`| `NO` 
`tenantmanager.ingress.hosts` | Ingress hostnames |	`[]`| `NO` 
`tenantmanager.ingress.tls` |	Ingress TLS configuration (YAML) | `[]`| `NO` 
`tenantmanager.securityContext` | Set of security context for the container | `nil`| `NO` 
`tenantmanager.TLS.enabled` | If require secure channel communication | `false` | `NO`
`tenantmanager.TLS.secretName` | certificates secret name | `nil` | `NO`
`tenantmanager.extraEnvironmentVars` | is a list of extra environment variables to set in the tenantmanager deployments. | `{}`| `NO`
`tenantmanager.extraSecretEnvironmentVars` | is a list of extra environment variables to set in the tenantmanager deployments, these variables take value from existing Secret objects. | `[]`| `NO`


## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
