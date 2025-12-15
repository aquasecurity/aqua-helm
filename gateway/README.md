<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Gateway Helm Chart

Helm chart for installation and maintenance of Aqua Container Security Platform Gateway component to support multi-cluster use-case.

## Contents

- [Aqua Security Gateway Helm Chart](#aqua-security-gateway-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Gateway from GitHub Repo](#installing-aqua-gateway-from-github-repo)
        - [Edit values.yaml file in gateway directory with following details as prerequisite](#edit-valuesyaml-file-in-gateway-directory-with-following-details-as-prerequisite)
    - [Installing Aqua Gateway from Helm Private Repository](#installing-aqua-gateway-from-helm-private-repository)
  - [Configure mTLS between server/gateway and external DB](#configure-mtls-between-servergateway-and-external-db)
  - [Configurable Variables](#configurable-variables)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)


## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Gateway from GitHub Repo

1. Clone the GitHub repository with the charts
    ```shell
    git clone https://github.com/aquasecurity/aqua-helm.git
    cd aqua-helm/
    ```

##### Edit values.yaml file in gateway directory with following details as prerequisite
```
  1. global.db.external.name - External database name
  2. global.db.external.host - External database public IP or endpoint URL
  3. global.db.external.port - External database port
  4. global.db.external.user - External database username
  5. global.db.external.password - External database password
  6. global.db.external.auditName - External audit database name
  7. global.db.external.auditHost - External audit database public IP or endpoint URL
  8. global.db.external.auditPort - External audit database port
  9. global.db.external.auditUser - External audit database username
  10. global.db.external.auditPassword - External audit database password
  11. console.publicIP - Aqua CSP console public IP or endpoint URL
  12. console.publicPort - Aqua CSP console public port
  // To load DB passswords from secrets:
  // change passwordFromSecret.enable to true
  // for loading DB password from secret edit passwordFromSecret.dbPasswordName  passwordFromSecret.dbPasswordName with secret name and secret key
  // for loading Audit-DB password from secret edit passwordFromSecret.dbAuditPasswordName  passwordFromSecret.dbAuditPasswordName with secret name and secret key
  // for loading PubSub DB password from secret edit passwordFromSecret.dbPubsubPasswordName  passwordFromSecret.dbPubsubPasswordName with secret name and secret key
```

2. Create `aqua` namespace if gateway is being deployed to a new cluster.
    ```
    kubectl create namespace aqua
    ```

3. Install Aqua
    ```shell
    helm upgrade --install --namespace aqua gateway ./gateway --set imageCredentials.username=<>,imageCredentials.password=<>,platform=<>
    ```

### Installing Aqua Gateway from Helm Private Repository

1. Add Aqua Helm Repository
    ```shell
    helm repo add aqua-helm https://helm.aquasec.com
    ```

2. Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
    ```shell
    helm search repo aqua-helm/gateway --versions
    ```

3. Create `aqua` namespace if gateway is being deployed to a new cluster.
    ```shell
    kubectl create namespace aqua
    ```

4. copy the values.yaml content from  [Values.yaml](./values.yaml) to a file and make the respective changes [values](#edit-valuesyaml-file-in-gateway-directory-with-following-details-as-prerequisite) then run the following command:
    ```shell
    helm upgrade --install --namespace aqua gateway aqua-helm/gateway --values values.yaml --version <>
    ```

## Configure mTLS between server/gateway and external DB
   1. Add the external DB values under `global.db.external` section
   2. Change `global.db.ssl` and `global.db.auditssl` to true
   3. Create secret with external DB public certificate
      ```shell
      kubectl create secret generic <<dbcert_secret_name>> --from-file <<db_certificate.pem_file_path>> -n aqua
      ```
   4. Set the following variables
      ```shell
      global.db.externalDBCerts.enable: true
      global.db.externalDBCerts.certSecretName: <<dbcert_secret_name>>
      ```
   5. Select ssl mode for external databases
      ```shell
      sslmode: require          # accepts: allow | prefer | require | verify-ca | verify-full (Default: Require)
      auditsslmode: require     # accepts: allow | prefer | require | verify-ca | verify-full (Default: Require)
      ```
   6. Note: In Active-Active mode set respective values to pubsub variables

## Configurable Variables

| Parameter                                           | Description                                                                                                                                                    | Default                | Mandatory                                                                                        |
|-----------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|--------------------------------------------------------------------------------------------------|
| `imageCredentials.create`                           | Set if to create new pull image secret                                                                                                                         | `true`                 | `YES`                                                                                            |
| `imageCredentials.name`                             | Your Docker pull image secret name                                                                                                                             | `aqua-registry-secret` | `YES`                                                                                            |
| `imageCredentials.repositoryUriPrefix`              | Repository uri prefix for dockerhub set `docker.io`                                                                                                            | `registry.aquasec.com` | `YES`                                                                                            |
| `imageCredentials.registry`                         | Set the registry url for dockerhub set `index.docker.io/v1/`                                                                                                   | `registry.aquasec.com` | `YES`                                                                                            |
| `imageCredentials.username`                         | Your Docker registry (DockerHub, etc.) username                                                                                                                | `aqua-registry-secret` | `YES`                                                                                            |
| `imageCredentials.password`                         | Your Docker registry (DockerHub, etc.) password                                                                                                                | `unset`                | `YES`                                                                                            |
| `rbac.create`                                       | To create RBAC for gateway component                                                                                                                           | `false`                | `YES` <br />`if gateway alone is deploying in new cluster`                                       |
| `clusterRole.roleRef`                               | Cluster role reference name for cluster roleBinding                                                                                                            | `unset`                | `NO`                                                                                             |
| `console.publicIP`                                  | Address of the server                                                                                                                                          | `aqua-console-svc`     | `YES`                                                                                            |
| `console.publicPort`                                | Server endpoint Port value                                                                                                                                     | `443`                  | `YES`                                                                                            |
| `serviceAccount.name`                               | Name of the ServiceAccount                                                                                                                                     | `aqua-sa`              | `YES`                                                                                            |
| `serviceAccount.annotations`                        | Annotations of the ServiceAccount                                                                                                                              | ``                     | `NO`                                                                                             |
| `serviceAccount.attachImagePullSecret`                               | Attach image pull secret to created service account                                                                 | `true`                                             |                                                                                                  |
| `headlessService`                                   | Create headless service for envoy                                                                                                                              | `true`                 | `YES`                                                                                            |
| `global.platform`                                   | Specify the Kubernetes (k8s) platform acronym, allowed values are: aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s, mke.                            | `unset`                | `YES`                                                                                            |
| `global.db.external.enabled`                        | Avoid installing a Postgres container and use an external database instead                                                                                     | `false`                | `YES`                                                                                            |
| `global.db.external.name`                           | PostgreSQL DB name                                                                                                                                             | `unset`                | `YES`<br />`if db.external.enabled is set to true`                                               |
| `global.db.external.host`                           | PostgreSQL DB hostname                                                                                                                                         | `unset`                | `YES`<br />`if db.external.enabled is set to true`                                               |
| `global.db.external.port`                           | PostgreSQL DB port                                                                                                                                             | `unset`                | `YES`<br />`if db.external.enabled is set to true`                                               |
| `global.db.external.user`                           | PostgreSQL DB username                                                                                                                                         | `unset`                | `YES`<br />`if db.external.enabled is set to true`                                               |
| `global.db.external.password`                       | PostgreSQL DB password                                                                                                                                         | `unset`                | `YES`<br />`if db.external.enabled is set to true`                                               |
| `global.db.external.auditName`                      | PostgreSQL DB audit name                                                                                                                                       | `unset`                | `NO`                                                                                             |
| `global.db.external.auditHost`                      | PostgreSQL DB audit hostname                                                                                                                                   | `unset`                | `NO`                                                                                             |
| `global.db.external.auditPort`                      | PostgreSQL DB audit port                                                                                                                                       | `unset`                | `NO`                                                                                             |
| `global.db.external.auditUser`                      | PostgreSQL DB audit username                                                                                                                                   | `unset`                | `NO`                                                                                             |
| `global.db.external.auditPassword`                  | PostgreSQL DB audit password                                                                                                                                   | `unset`                | `NO`                                                                                             |
| `global.db.external.pubsubName`                     | PostgreSQL DB pubsub name                                                                                                                                      | `unset`                | `NO`                                                                                             |
| `global.db.external.pubsubHost`                     | PostgreSQL DB pubsub hostname                                                                                                                                  | `unset`                | `NO`                                                                                             |
| `global.db.external.pubsubPort`                     | PostgreSQL DB pubsub port                                                                                                                                      | `unset`                | `NO`                                                                                             |
| `global.db.external.pubsubUser`                     | PostgreSQL DB pubsub username                                                                                                                                  | `unset`                | `NO`                                                                                             |
| `global.db.external.pubsubPassword`                 | PostgreSQL DB pubsub password                                                                                                                                  | `unset`                | `NO`                                                                                             |
| `global.db.passwordFromSecret.enabled`              | Enable to load DB passwords from Secrets                                                                                                                       | `false`                | `YES`                                                                                            |
| `global.db.passwordFromSecret.dbPasswordName`       | Password secret name                                                                                                                                           | `null`                 | `NO`                                                                                             |
| `global.db.passwordFromSecret.dbPasswordKey`        | Password secret key                                                                                                                                            | `null`                 | `NO`                                                                                             |
| `global.db.passwordFromSecret.dbAuditPasswordName`  | Audit password secret name                                                                                                                                     | `null`                 | `NO`                                                                                             |
| `global.db.passwordFromSecret.dbAuditPasswordKey`   | Audit password secret key                                                                                                                                      | `null`                 | `NO`                                                                                             |
| `global.db.passwordFromSecret.dbPubsubPasswordName` | Pubsub password secret name                                                                                                                                    | `null`                 | `NO`                                                                                             |
| `global.db.passwordFromSecret.dbPubsubPasswordKey`  | Pubsub password secret key                                                                                                                                     | `null`                 | `NO`                                                                                             |
| `global.db.ssl`                                     | If require an SSL-encrypted connection to the Postgres configuration database.                                                                                 | 	`false`               | `NO`                                                                                             |
| `global.db.sslmode`                                 | If `ssl` is true, select the type of SSL mode between db and console/gateway  accepts: allow, prefer, require, verify-ca, verify-full (Default: Require)       | `require`              | `NO`                                                                                             |
| `global.db.auditssl`                                | If require an SSL-encrypted connection to the Postgres configuration audit database.                                                                           | 	`false`               | `NO`                                                                                             |
| `global.db.auditsslmode`                            | If `auditssl` is true, select the type of SSL mode between db and console/gateway  accepts: allow, prefer, require, verify-ca, verify-full (Default: Require)  | `require`              | `NO`                                                                                             |
| `global.db.pubsubssl`                               | If require an SSL-encrypted connection to the Postgres configuration pubsub database.                                                                          | 	`false`               | `NO`                                                                                             |
| `global.db.pubsubsslmode`                           | If `pubsubssl` is true, select the type of SSL mode between db and console/gateway  accepts: allow, prefer, require, verify-ca, verify-full (Default: Require) | `require`              | `NO`                                                                                             |
| `global.db.externalDbCerts.enable`                  | If true, external db can connect with mTLS i.e.., verify-ca/verify-full ssl mode by mounting the ca cert to console & gateway                                  | `false`                | `NO`                                                                                             |
| `global.db.externalDbCerts.certSecretName`          | If `global.db.externalDbCerts.enable` true, Secret name which holds external db ca certificate files                                                           | `null`                 | `NO`                                                                                             |
| `image.repository`                                  | The docker image name to use                                                                                                                                   | `gateway`              | `NO`                                                                                             |
| `image.tag`                                         | The image tag to use.                                                                                                                                          | `10`               | `NO`                                                                                             |
| `image.pullPolicy`                                  | The kubernetes image pull policy.                                                                                                                              | `IfNotPresent`         | `NO`                                                                                             |
| `service.type`                                      | Kubernetes service type                                                                                                                                        | `ClusterIP`            | `NO`                                                                                             |
| `service.loadbalancerIP`                            | Can specify loadBalancerIP address for aqua-gateway in AKS platform                                                                                            | `null`                 | `NO`                                                                                             |
| `service.loadBalancerSourceRanges`                  | In order to limit which client IP's can access the Network Load Balancer, specify a list of CIDRs                                                              | `null`                 | `NO`                                                                                             |
| `service.annotations`                               | Service annotations	                                                                                                                                           | `{}`                   | `NO`                                                                                             |
| `service.ports`                                     | Array of ports settings                                                                                                                                        | `array`                | `NO`                                                                                             |
| `publicIP`                                          | Gateway public ip                                                                                                                                              | `aqua-gateway`         | `NO`                                                                                             |
| `replicaCount`                                      | Replica count                                                                                                                                                  | `1`                    | `NO`                                                                                             |
| `resources`                                         | Resource requests and limits                                                                                                                                   | `{}`                   | `NO`                                                                                             |
| `nodeSelector`                                      | Kubernetes node selector	                                                                                                                                      | `{}`                   | `NO`                                                                                             |
| `tolerations`                                       | Kubernetes node tolerations	                                                                                                                                   | `[]`                   | `NO`                                                                                             |
| `affinity`                                          | Kubernetes node affinity                                                                                                                                       | `{}`                   | `NO`                                                                                             |
| `podAnnotations`                                    | Kubernetes pod annotations                                                                                                                                     | `{}`                   | `NO`                                                                                             |
| `securityContext`                                   | Set of security context for the container                                                                                                                      | `nil`                  | `NO`                                                                                             |
| `pdb.minAvailable`                                  | Set minimum available value for gate                                                                                                                           | `1`                    | `NO`                                                                                             |
| `pdb.apiVersion`                                    | Override the API version of the gate PDB                                                                                                                       | ``                     | `NO`                                                                                             |
| `TLS.enabled`                                       | If require secure channel communication                                                                                                                        | `false`                | `NO`                                                                                             |
| `TLS.secretName`                                    | Certificates secret name                                                                                                                                       | `nil`                  | `YES` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.publicKey_fileName`                            | Filename of the public key eg: aqua_gateway.crt                                                                                                                | `nil`                  | `YES` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.privateKey_fileName`                           | Filename of the private key eg: aqua_gateway.key                                                                                                               | `nil`                  | `YES` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.rootCA_fileName`                               | Filename of the rootCA, if using self-signed certificates eg: rootCA.crt                                                                                       | `nil`                  | `NO` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `TLS.aqua_verify_enforcer`                          | Change it to "1" or "0" for enabling/disabling mTLS between enforcer and gateway/envoy                                                                         | `0`                    | `YES` <br /> `if gate.TLS.enabled is set to true`                                                |
| `extraEnvironmentVars`                              | Is a list of extra environment variables to set in the gateway deployments.                                                                                    | `{}`                   | `NO`                                                                                             |
| `extraSecretEnvironmentVars`                        | Is a list of extra environment variables to set in the gateway deployments, these variables take value from existing Secret objects.                           | `[]`                   | `NO`                                                                                             |
| `extraVolumes`                                      | extraVolumes is a list of volumes that can be mounted inside the KubeEnforcer deployment                                                                                                          | `[]`                  | `NO`                                                                      |
| `extraVolumeMounts`                                 | extraVolumeMounts is a list of extra volumes to mount into the container's filesystem of the KubeEnforcer deployment                                                                                                         | `[]`                  | `NO`                                                                     |
