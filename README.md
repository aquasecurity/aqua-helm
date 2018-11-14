<img src="https://www.aquasec.com/wp-content/uploads/2016/05/aqua_logo_fullcolor.png" heigth="89" width="246" />

# Aqua Security Helm Charts

Helm charts for installing and maintaining Aqua Security CSP server and agent components, and enforcers.

## Charts Details

This repository includes two charts that can be installed separately:

* [**Server**](aquasec-server/) - installs the web, gateway and optionally database and a scanner CLI components 
* [**Enforcer**](aquasec-enforcer/) - installs the enforcer daemonset by the specific token.

## Install the Chart

Clone the github repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

Then, run one of the commands below to install the relevant services.

### Server (console)

```bash
helm upgrade --install --namespace aquasec server ./aquasec-server --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

### Enforcer

```bash
helm upgrade --install --namespace aquasec enforcer ./aquasec-enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>,token=<aquasec-token>
```

## Configuration

The following tables list the configurable parameters of the Server and Enforcer charts and their default values.

### Server

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.usernmae`               | Your Docker registry (DockerHub and etc) username    | N/A                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub and etc) password    | N/A                                                                   |
| `imageCredentials.email`                  | Your Docker registry (DockerHub and etc) email    | N/A                                                                   |
| `rbac.enabled`                    | Create a service account and a ClusterRole    | `false`                                                                   |
| `rbac.roleRef`                    | Use an existing ClusterRole    | ``                                                                   |
| `admin.token`                    | Use this aqua license token   | N/A                                                                   |
| `admin.password`                    | Use this aqua admin password   | N/A                                                                  |
| `db.external.enabled`             | Avoid installing a Postgres container and use an external database instead    | `false`                          |
| `db.external.name`                | Postresql DB name    | N/A                                        |
| `db.external.host`                | Postresql DB hostname    | N/A                                        |
| `db.external.port`                | Postresql DB port    | N/A                                        |
| `db.external.user`                | Postresql DB username    | N/A                                        |
| `db.external.password`            | Postresql DB password    | N/A                                        |
| `db.image.repository`                   | Default Postgresql Docker image repository    | `aquasec/database`                                        |
| `db.image.tag`                    | Default Postgresql Docker image tag    | `3.2`                                        |
| `db.service.type`                      | Default Postgresql service type    | `ClusterIP`                                        |
| `db.persistence.enabled`          | Enable a use of a Postgresql PVC    | `true`                                        |
| `db.persistence.storageClass`     | Postgresql PVC StorageClass   | `default`                                        |
| `db.persistence.size`             | Postgresql PVC volume size  | `30Gi`                                        |
| `db.persistence.accessMode`       | Postgresql PVC volume AccessMode  | `ReadWriteOnce`                                        |
| `db.resources`       | Postgresql pod resources  | `{}`                                        |
| `web.service.type`                | Web service type  | `ClusterIP`                                        |
| `web.ingress.enabled`             | Install ingress for the web component  | `false`                                        |
| `web.image.repository`                   | Default Web Docker image repository    | `aquasec/server`                                        |
| `web.image.tag`                    | Default Web Docker image tag    | `3.2`                                        |
| `web.ingress.annotations`         | Web ingress annotations  | `{}`                                        |
| `web.ingress.hosts`               | Web ingress hosts definition  | `[]`                                        |
| `web.ingress.tls`                 | Web ingress tls  | `[]`                                        |
| `gate.service.type`                | Gate service type  | `ClusterIP`                                        |
| `gate.image.repository`                   | Default Gate Docker image repository    | `aquasec/gate`                                        |
| `gate.image.tag`                    | Default Gate Docker image tag    | `3.2`                                        |
| `gate.publicIP`                    | Default Gate service public IP    | ``                                        |
| `scanner.enabled`                 | Enable the Scanner CLI component  | `false`                                        |
| `scanner.replicas`                | Number of Scanner CLI replicas to run  | `1`                                        |
| `scanner.user`                | Username with the Scanner role  | N/A                                        |
| `scanner.password`                | Password for the username with the Scanner role  | N/A                                        |


### Enforcer

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `false`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.usernmae`               | Your Docker registry (DockerHub and etc) username    | N/A                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub and etc) password    | N/A                                                                   |
| `imageCredentials.email`                  | Your Docker registry (DockerHub and etc) email    | N/A                                                                   |
| `token`                           | Aquasec Enforcer token    | N/A                                                     |
| `server`                          | Gateways host name    | `aqua-gateway`                                                     |
| `port`                            | Gateway port    | `3622`                                                     |

## Create Docker Registry Secret Credentials

The Aqua server components are private, and you will need to set up an imagePullSecret.

You can do this manually by running:

```bash
kubectl create secret docker-registry dockerhub --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

Or by setting your Dockerhub or external docker registry credentials when you're running the Helm install commands as specified above, in which case Helm will create a new imagePullSecret for you.

## Use existing Postgresql database

By default the server chart will also install a Postgresql database and attach persistent storage to it.

If you want to override this behaviour and specify an existing Postgresql database, set the following variables when running Helm:

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

## Include Scanner CLI installation

To install the scanner CLI along with the server components set the following variables:

```yaml
scanner:
  enabled: true
```

## For non-cloud deployment

When you execute kubectl get events you will see the following **error:** 

*no persistent volumes available for this claim and no storage class is set*

**or**

*PersistentVolumeClaim is not bound*

This error comes in kubernetes set with kubeadm or kubespray and etc, you have an option to run this yaml to create presistent volume with generic storage class or to use existing storage class.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: aqua-console-db-data
  labels:
    type: local
spec:
  storageClassName: generic
  capacity:
    storage: 30Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/opt/aqua/data/db/"
```

## Issues and feedback
If you come across any problems or would like to give us feedback on deployments we encourage you to raise issues here on GitHub.
