<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Gateway Helm Chart

Helm chart for installation and maintenance of Aqua Container Security Platform Gateway component to support multi-cluster use-case.

## Contents

- [Aqua Security Gateway Helm Chart](#aqua-security-gateway-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Gateway from Github Repo](#installing-aqua-gateway-from-github-repo)
        - [Edit values.yaml file in gateway directory with following details as prerequisite](#edit-valuesyaml-file-in-gateway-directory-with-following-details-as-prerequisite)
    - [Installing Aqua Gateway from Helm Private Repository](#installing-aqua-gateway-from-helm-private-repository)
  - [Configurable Variables](#configurable-variables)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)


## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Gateway from Github Repo

1. Clone the GitHub repository with the charts
    ```shell
    git clone -b 6.5 https://github.com/aquasecurity/aqua-helm.git
    cd aqua-helm/
    ```

##### Edit values.yaml file in gateway directory with following details as prerequisite
```json
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
    ```shell
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


## Configurable Variables

Parameter | Description | Default | Mandatory |
--------- | ----------- | ------- | --------- |
`imageCredentials.create` | Set if to create new pull image secret | `true` | `YES`
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret` | `YES`
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com` | `YES`
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com` | `YES`
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret` | `YES`
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset` | `YES`
`rbac.enabled` | if to create rbac configuration for aqua | `true` | `YES`
`rbac.privileged` | determines if any container in a pod can enable privileged mode. | `true` | `YES`
`rbac.roleRef` | name of rbac role to set in not create by helm | `unset` | `NO`
`console.publicIP` | Address of the server | `aqua-console-svc` | `YES`
`console.publicPort` | Server endpoint Port value  | `443` | `YES`
`serviceAccount.name` | nams of the ServiceAccount | `aqua-sa` | `YES`
`global.db.external.enabled` | Avoid installing a Postgres container and use an external database instead | `false`| `YES`
`global.db.external.name` | PostgreSQL DB name | `unset`| `YES`<br />`if global.db.external.enabled is set to true`
`global.db.external.host` | PostgreSQL DB hostname | `unset`| `YES`<br />`if global.db.external.enabled is set to true`
`global.db.external.port` | PostgreSQL DB port | `unset`| `YES`<br />`if global.db.external.enabled is set to true`
`global.db.external.user` | PostgreSQL DB username | `unset`| `YES`<br />`if global.db.external.enabled is set to true`
`global.db.external.password` | PostgreSQL DB password | `unset`| `YES`<br />`if global.db.external.enabled is set to true`
`global.db.external.auditName` | PostgreSQL DB audit name | `unset`| `NO`
`global.db.external.auditHost` | PostgreSQL DB audit hostname | `unset`| `NO`
`global.db.external.auditPort` | PostgreSQL DB audit port | `unset`| `NO`
`global.db.external.auditUser` | PostgreSQL DB audit username | `unset`| `NO`
`global.db.external.auditPassword` | PostgreSQL DB audit password | `unset`| `NO`
`global.db.external.pubsubName` | PostgreSQL DB pubsub name | `unset`| `NO`
`global.db.external.pubsubHost` | PostgreSQL DB pubsub hostname | `unset`| `NO`
`global.db.external.pubsubPort` | PostgreSQL DB pubsub port | `unset`| `NO`
`global.db.external.pubsubUser` | PostgreSQL DB pubsub username | `unset`| `NO`
`global.db.external.pubsubPassword` | PostgreSQL DB pubsub password | `unset`| `NO`
`global.db.passwordFromSecret.enabled` | Enable to load DB passwords from Secrets | `false` | `YES`
`global.db.passwordFromSecret.dbPasswordName` | password secret name | `null`| `NO`
`global.db.passwordFromSecret.dbPasswordKey` | password secret key | `null`| `NO`
`global.db.passwordFromSecret.dbAuditPasswordName` | Audit password secret name | `null`| `NO`
`global.db.passwordFromSecret.dbAuditPasswordKey` | Audit password secret key | `null`| `NO`
`global.db.passwordFromSecret.dbPubsubPasswordName` | Pubsub password secret name | `null`| `NO`
`global.db.passwordFromSecret.dbPubsubPasswordKey` | Pubsub password secret key | `null`| `NO`
`global.db.ssl` | If require an SSL-encrypted connection to the Postgres configuration database. |	`false`| `NO`
`global.db.auditssl` | If require an SSL-encrypted connection to the Postgres configuration audit database. |	`false`| `NO`
`global.db.pubsubssl` | If require an SSL-encrypted connection to the Postgres configuration pubsub database. |	`false`| `NO`
`gate.image.repository` | the docker image name to use | `gateway`| `NO` 
`gate.image.tag` | The image tag to use. | `6.5`| `NO`
`gate.image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`gate.service.type` | k8s service type | `ClusterIP`| `NO` 
`gate.service.loadbalancerIP` | can specify loadBalancerIP address for aqua-gateway in AKS platform | `null` | `NO`
`gate.service.annotations` |	service annotations	| `{}` | `NO`
`gate.service.ports` | array of ports settings | `array`| `NO`
`gate.publicIP` | gateway public ip | `aqua-gateway`| `NO`
`replicaCount` | replica count | `1`| `NO`
`gate.resources` |	Resource requests and limits | `{}`| `NO`
`gate.nodeSelector` |	Kubernetes node selector	| `{}`| `NO`
`gate.tolerations` |	Kubernetes node tolerations	| `[]`| `NO`
`gate.affinity` |	Kubernetes node affinity | `{}`| `NO`
`gate.podAnnotations` | Kubernetes pod annotations | `{}` | `NO`
`gate.securityContext` | Set of security context for the container | `nil`| `NO`
`gate.pdb.minAvailable` | Set minimum available value for gate pod PDB | `1` | `NO`
`gate.TLS.enabled` | If require secure channel communication | `false` | `NO`
`gate.TLS.secretName` | certificates secret name | `nil` | `YES` <br /> `if gate.TLS.enabled is set to true`
`gate.TLS.publicKey_fileName` | filename of the public key eg: aqua_gateway.crt | `nil`  |  `YES` <br /> `if gate.TLS.enabled is set to true`
`gate.TLS.privateKey_fileName`   | filename of the private key eg: aqua_gateway.key | `nil`  |  `YES` <br /> `if gate.TLS.enabled is set to true`
`gate.TLS.rootCA_fileName` |  filename of the rootCA, if using self-signed certificates eg: rootCA.crt | `nil`  |  `NO` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS`
`gate.TLS.aqua_verify_enforcer` | change it to "1" or "0" for enabling/disabling mTLS between enforcer and gateway/envoy | `0`  |  `YES` <br /> `if gate.TLS.enabled is set to true`
`gate.extraEnvironmentVars` | is a list of extra environment variables to set in the gateway deployments. | `{}`| `NO`
`gate.extraSecretEnvironmentVars` | is a list of extra environment variables to set in the gateway deployments, these variables take value from existing Secret objects. | `[]`| `NO`
