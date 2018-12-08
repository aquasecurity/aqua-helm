<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" heigth="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" heigth="100"/>

# Aqua Security Helm Charts

Helm charts for installing and maintaining Aqua Container Security Platform server componants and enforcer.

## Charts Details

This repository includes two charts that can be installed separately:

* [**Console**](aquasec-server/) - installs the console, gateway and optionally a database and/or scanner CLI component
* [**Enforcer**](aquasec-enforcer/) - installs the enforcer daemonset

## Install the Chart

Clone the github repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

Then, run one of the commands below to install the relevant services.

> Note: ***Optional*** - Update the helm charts values.yaml file with your values you. This eliminates the need to pass the parameters to the helm command

### Server (console)

```bash
helm upgrade --install --namespace aqua csp ./console --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

### Enforcer

```bash
helm upgrade --install --namespace aqua enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>,token=<aquasec-token>
```

## Configuration

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Console

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
| `db.image.repository`                   | Default PostgreSQL Docker image repository    | `database`                                        |
| `db.image.tag`                    | Default PostgreSQL Docker image tag    | `3.5`                                        |
| `db.service.type`                      | Default PostgreSQL service type    | `ClusterIP`                                        |
| `db.persistence.enabled`          | Enable a use of a PostgreSQL PVC    | `true`                                        |
| `db.persistence.storageClass`     | PostgreSQL PVC StorageClass   | `default`                                        |
| `db.persistence.size`             | PostgreSQL PVC volume size  | `30Gi`                                        |
| `db.persistence.accessMode`       | PostgreSQL PVC volume AccessMode  | `ReadWriteOnce`                                        |
| `db.resources`       | PostgreSQL pod resources  | `{}`                                        |
| `web.service.type`                | Web service type  | `ClusterIP`                                        |
| `web.ingress.enabled`             | Install ingress for the web component  | `false`                                        |
| `web.image.repository`                   | Default Web Docker image repository    | `server`                                        |
| `web.image.tag`                    | Default Web Docker image tag    | `3.5`                                        |
| `web.ingress.annotations`         | Web ingress annotations  | `{}`                                        |
| `web.ingress.hosts`               | Web ingress hosts definition  | `[]`                                        |
| `web.ingress.tls`                 | Web ingress tls  | `[]`                                        |
| `gate.service.type`                | Gate service type  | `ClusterIP`                                        |
| `gate.image.repository`                   | Default Gate Docker image repository    | `gate`                                        |
| `gate.image.tag`                    | Default Gate Docker image tag    | `3.5`                                        |
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

The Aqua console components are available in our private repository, and you will need to set up an imagePullSecret.

You can do this manually by running:

```bash
kubectl create secret docker-registry dockerhub --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

Or by setting your Dockerhub or external docker registry credentials when you're running the Helm install commands as specified above, in which case Helm will create a new imagePullSecret for you.

## PostgreSQL database

Aqua Security recommends implementing a highly available PostgreSQL database. By default the console chart will install a PostgreSQL database and attach it to persistent storage for POC useage and testing.

For production use one may override this default behavour and specify an existing PostgreSQL database by setting the following variables in values.yaml:

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

Aqua CSP includes the ability to deploy a scanning pod. This dedicated scanning pod allows the console to run unpriviliged, as well as providing a high scanning throughput scanning queue for proction useage.
To install the scanner CLI along with the console components set the following variables in values.yaml:

```yaml
scanner:
  enabled: true
```

## Helm troubleshooting

* Error: **UPGRADE FAILED**: configmaps is forbidden
  ```sh
  Error: UPGRADE FAILED: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
  ```
  **Solution:**
  ```sh
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'     
  helm init --service-account tiller --upgrade
  ```

* **no persistent volumes available for this claim and no storage class is set** 
  
  * ***For EKS, AKE or other managed kubernetes***
  
    *for examples:*

    * **Amazon EKS - Managed Kubernetes Services**
      ```yaml
      kind: StorageClass
      apiVersion: storage.k8s.io/v1
      metadata:
        name: aqua-console-db-data
      provisioner: kubernetes.io/aws-ebs
      parameters:
        type: gp2
      reclaimPolicy: Retain
      mountOptions:
        - debug
      volumeBindingMode: Immediate
      ```
  * ***For non-cloud provider based deployment***

    Most kubernetes service providers do not add all possible storage providers during initial deployment of workers. It is possible when you execute kubectl 'get events' you will encounter the following **error:**

    *no persistent volumes available for this claim and no storage class is set*

    **or**

    *PersistentVolumeClaim is not bound*

    If you see this error, you will have to create a persistant volume with a generic storage class or to use existing storage class. Update the values.yaml `db.persistence.storageClass` to the storage class you have chosen. An example file using `aqua-storage` included in the repo and applied as below prior to installation.

    ```bash
    kubectl apply -f pv-example.yaml
    ```

## Issues and feedback
If you come across any problems or would like to give us feedback on deployments we encourage you to raise issues here on GitHub.