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
- [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

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

* Install Aqua

```bash
helm upgrade --install --namespace aqua aqua ./server --set imageCredentials.username=<>,imageCredentials.password=<>,platform=<>
```
## Advanced Configuration

1. Envoy

   In order to support L7 / gRPC communication between gateway and enforcers Aqua recommends that customers use the latest alpine-based Envoy load balancer. Following are the detailed steps to enable and deploy a secure envoy based load balancer.

   1. Generate TLS certificates signed by a public CA or Self-Signed CA

      ```yaml
      # Self-Signed Root CA (Optional)
      #####################################################################################
      # Create Root Key
      # If you want a non password protected key just remove the -des3 option
      openssl genrsa -des3 -out rootCA.key 4096
      # Create and self sign the Root Certificate
      openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
      #####################################################################################
      # Create a certificate
      #####################################################################################
      # Create the certificate key
      openssl genrsa -out mydomain.com.key 2048
      # Create the signing (csr)
      openssl req -new -key mydomain.com.key -out mydomain.com.csr
      # Verify the csr content
      openssl req -in mydomain.com.csr -noout -text
      #####################################################################################
      # Generate the certificate using the mydomain csr and key along with the CA Root key
      #####################################################################################
      openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256
      #####################################################################################
      
      # If you wish to use a Public CA like GoDaddy or LetsEncrypt please
      # submit the mydomain csr to the respective CA to generate mydomain crt
      ```
   
   2. Create TLS cert secret
   
      ```bash
      # Please be notified that tls.key and tls.crt in the below command are same
      # as mydomain.com.key and mydomain.com.crt in the above openssl commands
      $ kubectl create secret tls aqua-lb-tls --key tls.key --cert tls.crt -n aqua
      ```
   
   3. Edit values.yaml file to include above secret name at `envoy.certsSecretName`
   
   4. Also set `envoy.enabled` to `true` 
   
   5. For more customizations please refer to [***Configurable Variables***](#configure-variables)
   
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
   
3. Configuring HTTPS for Aqua's server

   By default Aqua will generate a self signed cert and will use the same for HTTPS communication. If you wish to use your own SSL/TLS certs you can do this in two different ways

   1. Ingress(optional): Kubernetes ingress controller can be used to publicly expose aqua web UI over a HTTPS connection
   2. LoadBalancer(Default): Use AQUA_PUBLIC_KEY, AQUA_PRIVATE_KEY, and AQUA_ROOT_CA environment variables to specify the TLS cert path. Make sure to mount the TLS cert into the container.

4. Setting active-active mode

   1. Set `activeactive` to true in values.yaml
   2. Also set following configurable variables
      ```shell
      1. db.external.pubsubName
      2. db.external.pubsubHost
      3. db.external.pubsubPort
      4. db.external.pubsubUser
      5. db.external.pubsubPassword      
      ```

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
`openshift_route.create` | to create openshift routes for web and gateway | `false` | `NO`
`rbac.enabled` | if to create rbac configuration for aqua | `true`| `YES` 
`rbac.privileged` | determines if any container in a pod can enable privileged mode. | `true`| `NO` 
`rbac.roleRef` | name of rbac role to set in not create by helm | `unset`| `NO` 
`activeactive` |	set in active active mode | `false`| `NO` 
`clustermode` |	set in HA cluster mode | `false`| `NO` 
`admin.token`| Use this Aqua license token | `unset`| `NO` 
`admin.password` | Use this Aqua admin password | `unset`| `NO` 
`dockerSocket.mount` | boolean parameter if to mount docker socket | `unset`| `NO` 
`dockerSocket.path` | docker socket path | `/var/run/docker.sock`| `NO` 
`docker` | Scanning mode direct or docker [link](https://docs.aquasec.com/docs/scanning-mode#default-scanning-mode) | `-`| `NO` 
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
`db.external.pubsubName` | PostgreSQL DB pubsub name | `unset`| `NO` 
`db.external.pubsubHost` | PostgreSQL DB pubsub hostname | `unset`| `NO` 
`db.external.pubsubPort` | PostgreSQL DB pubsub port | `unset`| `NO` 
`db.external.pubsubUser` | PostgreSQL DB pubsub username | `unset`| `NO` 
`db.external.pubsubPassword` | PostgreSQL DB pubsub password | `unset`| `NO` 
`db.passwordFromSecret.enabled` | Enable to load DB passwords from Secrets | `false` | `YES`
`db.passwordFromSecret.dbPasswordName` | password secret name | `null`| `NO`
`db.passwordFromSecret.dbPasswordKey` | password secret key | `null`| `NO`
`db.passwordFromSecret.dbAuditPasswordName` | Audit password secret name | `null`| `NO`
`db.passwordFromSecret.dbAuditPasswordKey` | Audit password secret key | `null`| `NO`
`db.passwordFromSecret.dbPubsubPasswordName` | Pubsub password secret name | `null`| `NO`
`db.passwordFromSecret.dbPubsubPasswordKey` | Pubsub password secret key | `null`| `NO`
`db.ssl` | If require an SSL-encrypted connection to the Postgres configuration database. |	`true`| `NO` 
`db.auditssl` | If require an SSL-encrypted connection to the Postgres configuration database. |	`true`| `NO` 
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
`gate.image.repository` | the docker image name to use | `gateway`| `NO` 
`gate.image.tag` | The image tag to use. | `5.3`| `NO` 
`gate.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`gate.service.type` | k8s service type | `ClusterIP`| `NO` 
`gate.service.annotations` |	service annotations	| `{}` | `NO`
`gate.service.ports` | array of ports settings | `array`| `NO` 
`gate.publicIP` | gateway public ip | `aqua-gateway`| `NO` 
`gate.replicaCount` | replica count | `1`| `NO` 
`gate.resources` |	Resource requests and limits | `{}`| `NO` 
`gate.nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`gate.tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`gate.affinity` |	Kubernetes node affinity | `{}`| `NO` 
`gate.securityContext` | Set of security context for the container | `nil`| `NO` 
`gate.TLS.enabled` | If require secure channel communication | `false` | `NO`
`gate.TLS.secretName` | certificates secret name | `nil` | `NO`
`gate.extraEnvironmentVars` | is a list of extra environment variables to set in the gateway deployments. | `{}`| `NO` 
`gate.extraSecretEnvironmentVars` | is a list of extra environment variables to set in the gateway deployments, these variables take value from existing Secret objects. | `[]`| `NO` 
`web.image.repository` | the docker image name to use | `console`| `NO` 
`web.image.tag` | The image tag to use. | `5.3`| `NO` 
`web.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`web.service.type` | k8s service type | `LoadBalancer`| `NO` 
`web.service.annotations` |	service annotations	| `{}`| `NO`
`web.service.ports` | array of ports settings | `array`| `NO` 
`web.replicaCount` | replica count | `1`| `NO` 
`web.resources` |	Resource requests and limits | `{}`| `NO` 
`web.nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`web.tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`web.affinity` |	Kubernetes node affinity | `{}`| `NO` 
`web.ingress.enabled` |	If true, Ingress will be created | `false`| `NO` 
`web.ingress.annotations` |	Ingress annotations	| `[]`| `NO` 
`web.ingress.hosts` | Ingress hostnames |	`[]`| `NO` 
`web.ingress.tls` |	Ingress TLS configuration (YAML) | `[]`| `NO` 
`web.securityContext` | Set of security context for the container | `nil`| `NO` 
`web.TLS.enabled` | If require secure channel communication | `false` | `NO`
`web.TLS.secretName` | certificates secret name | `nil` | `NO`
`web.maintenance_db.name` | If Conifgured to use custom maintanance DB specify the DB name | `unset` | `NO` 
`web.extraEnvironmentVars` | is a list of extra environment variables to set in the web deployments. | `{}`| `NO` 
`web.extraSecretEnvironmentVars` | is a list of extra environment variables to set in the web deployments, these variables take value from existing Secret objects. | `[]`| `NO` 
`envoy.enabled` | enabled envoy deployment. | `false`| `NO` 
`envoy.replicaCount` | replica count | `1`| `NO` 
`envoy.image.repository` | the docker image name to use | `envoyproxy/envoy-alpine`| `NO` 
`envoy.image.tag` | The image tag to use. | `v1.14.1`| `NO` 
`envoy.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`envoy.service.type` | k8s service type | `LoadBalancer`| `NO` 
`envoy.service.ports` | array of ports settings | `array`| `NO` 
`envoy.certsSecretName` | tls certificates for envoy, **notice: required for current configuration in files envoy.yaml** | `nil`| `NO` 
`envoy.livenessProbe` | liveness probes configuration for envoy | `{}`| `NO` 
`envoy.readinessProbe` | readiness probes configuration for envoy | `{}`| `NO` 
`envoy.resources` |	Resource requests and limits | `{}`| `NO` 
`envoy.nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`envoy.tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`envoy.affinity` |	Kubernetes node affinity | `{}`| `NO` 
`envoy.securityContext` | Set of security context for the container | `nil`| `NO` 


`envoy.files.envoy\.yaml` | content of a full envoy configuration file as documented in https://www.envoyproxy.io/docs/envoy/latest/configuration/configuration | See [values.yaml](values.yaml)

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
