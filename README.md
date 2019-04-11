<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Helm Charts

These are Helm charts for installation and maintenance of Aqua Container Security Platform Console, Database, Gateway, Scanner, and Enforcer components.

## Contents

- [Aqua Security Helm Charts](#aqua-security-helm-charts)
  - [Contents](#contents)
  - [Chart Details](#chart-details)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
    - [PostgreSQL database](#postgresql-database)
    - [High-Volume Scanner Installation](#high-volume-scanner-installation)
    - [Helm Customizations / Troubleshooting](#helm-customizations--troubleshooting)
    - [Non-public cloud provider deployments](#non-public-cloud-provider-deployments)
  - [Installing the Charts](#installing-the-charts)
    - [Server (console)](#server-console)
    - [Enforcer](#enforcer)
    - [Scanner](#scanner)
  - [Configurable Variables](#configurable-variables)
    - [Console](#console)
    - [Enforcer](#enforcer-1)
    - [Scanner](#scanner-1)
  - [Support](#support)

## Chart Details

This repository includes two charts that may be deployed separately:

* [**Server**](server/) - deploys the Console, Gateway, and Database components, and optionally the Scanner component
* [**Enforcer**](enforcer/) - deploys the Enforcer daemonset
* [**Scanner**](scanner/) - deploys the aqua scanner cli deployment

## Prerequisites

### Container Registry Credentials

The Aqua server (Console and Gateway) components are available in our private repository, which requires authentication. By default, the charts create a secret based on the values.yaml. 

First, create a new namespace named "aqua":

```bash
kubectl create namespace aqua
```

Next, **(Optional)** create the secret:

```bash
kubectl create secret docker-registry csp-registry-secret  --docker-server="registry.aquasec.com" --namespace aqua --docker-username="jg@example.com" --docker-password="Truckin" --docker-email="jg@example.com"
```

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

### High-Volume Scanner Installation

Aqua CSP has the ability to deploy a scanning pod that is external to the Aqua Server. This dedicated scanning pod allows the Server to run unprivileged, and provides a high-throughput scanning queue anywhere you choose. To install the Scanner-CLI alongside the Server components, set the following variables in values.yaml:

```yaml
scanner:
  enabled: true
scanner.replicas: "Set quantity"
```

### Helm Customizations / Troubleshooting

***This section not all-inclusive. It includes information regarding common issues Aqua has encountered during deployments***

**Error:** UPGRADE/INSTALL FAILED, configmaps is forbidden.

  ```sh
  Error: UPGRADE FAILED: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
  ```

**Solution:** Create a service account for Tiller to utilize.
  ```sh
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
  helm init --service-account tiller --upgrade
  ```

**Error:** No persistent volumes available for this claim and no storage class is set.
  
**Solution:** Most managed Kubernetes deployments do NOT include all possible storage provider variations at setup time. Refer to the official Kubernetes guidance https://kubernetes.io/docs/concepts/storage/storage-classes for your platform. Three primary examples are shown below.

  * Amazon EKS
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
  
  * Azure AKS
    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: slow
    provisioner: kubernetes.io/azure-disk
    parameters:
      storageaccounttype: Standard_LRS
      kind: Shared
    ```

  * Google GKE
    ```yaml
    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
      name: slow
    provisioner: kubernetes.io/gce-pd
    parameters:
      type: pd-standard
    replication-type: none
    ```

### Non-public cloud provider deployments

**Error:** When executing `kubectl get events -n aqua` you might encounter one of the following errors:
  *no persistent volumes available for this claim and no storage class is set* **or** *PersistentVolumeClaim is not bound*.

**Solution:** If you encounter this error, you need to create a persistent volume prior to chart installation with a generic or existing storage class, specifying `db.persistence.storageClass` within the values.yaml. A sample file using `aqua-storage` is included in the repo. 

  ```sh
  kubectl apply -f pv-example.yaml
  ```

* **Creating an ingress to access the Aqua Server**
* IBM Cloud Private includes a bundled ingress controller. A sample ingress yaml file is included in the repo.
```sh
kubectl apply -f ingress-example.yaml
```

* **Alternative Ingress Configuration**
* The services charts are set to create `ClusterIP' ingress types. You may tune these as appropriate for your environment.


## Installing the Charts

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

***Optional*** Update the Helm charts values.yaml file with your environment's custom values. This eliminates the need to pass the parameters to the helm command. Then run one of the commands below to install the relevant services.

### Server (console)

```bash
helm upgrade --install --namespace aqua csp ./server --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

### Enforcer

```bash
helm upgrade --install --namespace aqua csp-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>,enforcerToken=<aquasec-token>
```

### Scanner

```bash
helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Console

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `csp-registry-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`                                                                   |
| `rbac.enabled`                    | Create a service account and a ClusterRole    | `false`                                                                   |
| `rbac.roleRef`                    | Use an existing ClusterRole    | ``                                                                   |
| `admin.token`                    | Use this Aqua license token   | `N/A`                                                                   |
| `admin.password`                    | Use this Aqua admin password   | `N/A`                                                                  |
| `db.external.enabled`             | Avoid installing a Postgres container and use an external database instead    | `false`                          |
| `db.external.name`                | PostgreSQL DB name    | ``N/A``                                        |
| `db.external.host`                | PostgreSQL DB hostname    | ``N/A``                                        |
| `db.external.port`                | PostgreSQL DB port    | `N/A`                                        |
| `db.external.user`                | PostgreSQL DB username    | `N/A`                                        |
| `db.external.password`            | PostgreSQL DB password    | `N/A`                                        |
| `db.image.repository`                   | Default PostgreSQL Docker image repository    | `database`                                        |
| `db.image.tag`                    | Default PostgreSQL Docker image tag    | `4.0`                                        |
| `db.service.type`                      | Default PostgreSQL service type    | `ClusterIP`                                        |
| `db.persistence.enabled`          | Enable a use of a PostgreSQL PVC    | `true`                                        |
| `db.persistence.storageClass`     | PostgreSQL PVC StorageClass   | `default`                                        |
| `db.persistence.size`             | PostgreSQL PVC volume size  | `30Gi`                                        |
| `db.persistence.accessMode`       | PostgreSQL PVC volume AccessMode  | `ReadWriteOnce`                                        |
| `db.resources`       | PostgreSQL pod resources  | `{}`                                        |
| `web.service.type`                | Web service type  | `ClusterIP`                                        |
| `web.ingress.enabled`             | Install ingress for the web component  | `false`                                        |
| `web.image.repository`                   | Default Web Docker image repository    | `server`                                        |
| `web.image.tag`                    | Default Web Docker image tag    | `4.0`                                        |
| `web.ingress.annotations`         | Web ingress annotations  | `{}`                                        |
| `web.ingress.hosts`               | Web ingress hosts definition  | `[]`                                        |
| `web.ingress.tls`                 | Web ingress tls  | `[]`                                        |
| `gate.service.type`                | Gate service type  | `ClusterIP`                                        |
| `gate.image.repository`                   | Default Gate Docker image repository    | `gate`                                        |
| `gate.image.tag`                    | Default Gate Docker image tag    | `4.0`                                        |
| `gate.publicIP`                    | Default Gate service public IP    | ``                                        |
| `scanner.enabled`                 | Enable the Scanner-CLI component  | `false`                                        |
| `scanner.replicas`                | Number of Scanner-CLI replicas to run  | `1`                                        |
| `scanner.user`                | Username for the scanner user assigned to the Scanner role  | `N/A`                                        |
| `scanner.password`                | Password for scanner user  | `N/A`                                        |


### Enforcer

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `false`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`                                                                   |
| `enforcerToken`                           | Aqua Enforcer token    | `N/A`                                                     |
| `server`                          | Gateway host name    | `aqua-gateway`                                                     |
| `port`                            | Gateway port    | `3622`                                                     |


### Scanner

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `rbac.enabled`                    | Create a service account and a ClusterRole    | `false`                                                                   |
| `rbac.roleRef`                    | Use an existing ClusterRole    | ``                                                                   |
| `admin.token`                    | Use this Aqua license token   | `N/A`                                                                   |
| `admin.password`                    | Use this Aqua admin password   | `N/A`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `serviceAccount`                    | Service Account to use   | `csp-sa`                                                                  |
| `server.serviceName`                    | Service name of aqua server ui   | `csp-consul-svc`                                                                  |
| `server.port`                    | service svc port   | `8080`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `enabled`                 | Enable the Scanner-CLI component  | `false`                                        |
| `replicaCount`                | Number of Scanner-CLI replicas to run  | `1`                                        |
| `user`                | Username for the scanner user assigned to the Scanner role  | `N/A`                                        |
| `password`                | Password for scanner user  | `N/A`                                        |


## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.