<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Helm Charts

This topic contains Helm charts and instructions for the deployment and maintenance of Aqua Cloud Native Security (CSP).

CSP deployments include the following components:
- Server (Console, Database, and Gateway)
- Enforcer
- KubeEnforcer
- Scanner (optional)

## Contents

- [Aqua Security Helm Charts](#aqua-security-helm-charts)
  - [Contents](#contents)
  - [Helm charts](#helm-charts)
- [Deployment instructions](#deployment-instructions)
  - [Add Aqua Helm repository](#add-aqua-helm-repository)
  - [Container registry credentials](#container-registry-credentials)
  - [PostgreSQL database](#postgresql-database)
  - [Customize your configuration](#customize-your-configuration)
    - [Server](#server)
    - [Enforcer](#enforcer)
    - [Scanner](#scanner)
    - [KubeEnforcer](#KubeEnforcer)
  - [Deploy the Helm charts](#deploy-the-helm-charts)
    - [Server chart](#server-chart)
    - [Enforcer chart](#enforcer-chart)
    - [Scanner chart (optional)](#scanner-chart-optional)
- [Additional deployment items](#additional-deployment-items)
  - [High-volume scanner installation](#high-volume-scanner-installation)
  - [Non-public cloud provider deployments (examples)](#non-public-cloud-provider-deployments-examples)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

## Helm charts

This repository includes three charts that may be deployed separately:

* [**Server**](server/) - deploys the Console, Database, and Gateway components; and (optionally) the Scanner component
* [**Enforcer**](enforcer/) - deploys the Enforcer daemonset
* [**Scanner**](scanner/) - deploys the Scanner deployment
* [**KubeEnforcer**](kube-enforcer/) - deploys the KubeEnforcer deployment

# Deployment instructions

Follow the steps in this section.

### Add Aqua Helm Repository

First, you need to add the Aqua Helm repository to your local Helm repos, instead of cloning this aqua-helm source code repository, by executing the following command:

```bash
helm repo add aqua-helm https://helm.aquasec.com
```

* Search for all components of the latest version in our Aqua Helm repository

```bash
helm search aqua-helm
```

for helm 3.x
```bash
helm search repo aqua-helm
```

Example output:

```csv
NAME                      CHART VERSION		    APP VERSION		      DESCRIPTION
aqua-helm/enforcer        5.0.0        			  5.0        				  A Helm chart for the Aqua Enforcer
aqua-helm/scanner 	      5.0.0        			  5.0        				  A Helm chart for the aqua scanner cli component
aqua-helm/server  	      5.0.0        			  5.0        				  A Helm chart for the Aqua Console Componants
aqua-helm/kube-enforcer   5.0.0                   5.0                         A helm chart for the Aqua KubeEnforcer
```

* Search for all components of a specific version in our Aqua Helm repository

Example: for Version 5.0

```bash
helm search aqua-helm -v 5.0
```

for helm 3.x
```bash
helm search repo aqua-helm --version 5.0
```

* Search for all components:

for helm 3.x
```bash
helm search repo aqua-helm --versions
```

## Container registry credentials

The Aqua Server (Console and Gateway) components are available in our private repository, which requires authentication. By default, the charts create a secret based on the values.yaml file.

1. Create a new namespace named "aqua":

```bash
kubectl create namespace aqua
```

2. ***Optional:*** Create the secret:

```bash
kubectl create secret docker-registry csp-registry-secret  --docker-server="registry.aquasec.com" --namespace aqua --docker-username="jg@example.com" --docker-password="Truckin" --docker-email="jg@example.com"
```

## PostgreSQL database

Aqua Security recommends implementing a highly-available PostgreSQL database for production use of Aqua CSP.

By default, the console chart will install a PostgreSQL database and attach it to persistent storage; this is recommended only for POC usage and testing.

**For production use,** you can override this default behavior and specify an existing PostgreSQL database by setting the following variables in values.yaml:

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

## Customize your configuration

The following tables list the configurable parameters for the Server, Enforcer, and Scanner charts.

Change some or all of these parameters per the requirements of your deployment, if the default values are not appropriate.

### Server

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
| `activeactive`               | change to true to enable active active mode    | `false`                                                                 |
| `db.external.enabled`             | Use an external database (instead of deploying a Postgres container)    | `false`                          |
| `db.external.name`                | PostgreSQL DB name    | ``N/A``                                        |
| `db.external.host`                | PostgreSQL DB hostname    | ``N/A``                                        |
| `db.external.port`                | PostgreSQL DB port    | `N/A`                                        |
| `db.external.user`                | PostgreSQL DB username    | `N/A`                                        |
| `db.external.password`            | PostgreSQL DB password    | `N/A`                                        |
| `db.image.repository`                   | Default PostgreSQL Docker image repository    | `database`                                        |
| `db.image.tag`                    | Default PostgreSQL Docker image tag    | `5.0`                                        |
| `db.service.type`                      | Default PostgreSQL service type    | `ClusterIP`                                        |
| `db.persistence.enabled`          | Enable a use of a PostgreSQL PVC    | `true`                                        |
| `db.persistence.storageClass`     | PostgreSQL PVC StorageClass   | `default`                                        |
| `db.persistence.size`             | PostgreSQL PVC volume size  | `30Gi`                                        |
| `db.persistence.accessMode`       | PostgreSQL PVC volume AccessMode  | `ReadWriteOnce`                                        |
| `db.resources`       | PostgreSQL pod resources  | `{}`                                        |
| `web.service.type`                | Web service type  | `ClusterIP`                                        |
| `web.ingress.enabled`             | Install ingress for the web component  | `false`                                        |
| `web.image.repository`                   | Default Web Docker image repository    | `server`                                        |
| `web.image.tag`                    | Default Web Docker image tag    | `5.0`                                        |
| `web.ingress.annotations`         | Web ingress annotations  | `{}`                                        |
| `web.ingress.hosts`               | Web ingress hosts definition  | `[]`                                        |
| `web.ingress.tls`                 | Web ingress TLS  | `[]`                                        |
| `web.persistence.enabled` |   Enable persistent volume for fast scanning cache | `true` |
| `web.persistence.storageClass` |   Define the storage class if you don't want to use the default storage class | `` |
| `web.persistence.size` |   Size of the persistent volume in Gi | `4` |
| `web.persistence.accessMode` |   Access mode of the persistent volume | `ReadWriteOnce` |
| `gate.service.type`                | Gateway service type  | `ClusterIP`                                        |
| `gate.image.repository`                   | Default Gateway Docker image repository    | `gate`                                        |
| `gate.image.tag`                    | Default Gateway Docker image tag    | `5.0`                                        |
| `gate.publicIP`                    | Default Gateway service public IP    | ``                                        |
| `scanner.enabled`                 | Enable the Scanner component  | `false`                                        |
| `scanner.replicaCount`                | Number of Scanner replicas to run  | `1`                                        |
| `scanner.user`                | Username of the Scanner user assigned to the Scanner role  | `N/A`                                        |
| `scanner.password`                | Password of the Scanner user  | `N/A`                                        |


### Enforcer

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `false`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`                                                                   |
| `enforcerToken`                           | Aqua Enforcer token    | `N/A`                                                     |
| `server`                          | Gateway host name    | `aqua-gateway`                                                     |
| `port`                            | Gateway port    | `8443`                                                     |

### KubeEnforcer

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`                                                                   |
| `aquaSecret.aquaUsername`                           | Aqua Console Username    | `N/A`
| `aquaSecret.aquaPassword`                           | Aqua Console Password   | `N/A`
| `aquaSecret.kubeEnforcerToken`                           | Aqua KubeEnforcer token    | `N/A`    
| `certsSecret.serverCertificate`                           | Certificate for TLS authentication with Kubernetes api-server    | `N/A`
| `certsSecret.serverKey`                           | Certificate key for TLS authentication with Kubernetes api-server    | `N/A`
| `validatingWebhook.caBundle`                           | Root Certificate for TLS authentication with Kubernetes api-server   | `N/A`                                                 |
| `envs.gatewayAddress`                          | Gateway host Address    | `aqua-gateway:8443`                                                     |
 

### Scanner

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `rbac.enabled`                    | Create a service account and a ClusterRole    | `false`                                                                   |
| `rbac.roleRef`                    | Use an existing ClusterRole    | ``                                                                   |
| `admin.token`                    | Use this Aqua license token   | `N/A`                                                                   |
| `admin.password`                    | Use this Aqua admin password   | `N/A`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `serviceAccount`                    | Service account to use   | `csp-sa`                                                                  |
| `server.serviceName`                    | Service name of the Aqua Server (console) UI   | `csp-console-svc`                                                                  |
| `server.port`                    | Service svc port   | `8080`                                                                  |
| `docker.socket.path`                    | Docker socket path   | `/var/run/docker.sock`                                                                  |
| `docker.socket.path`                    | Docker socket path   | `/var/run/docker.sock`                                                                  |
| `enabled`                 | Enable the Scanner component  | `false`                                        |
| `replicaCount`                | Number of Scanner replicas to run  | `1`                                        |
| `user`                | Username of the Scanner user assigned to the Scanner role  | `N/A`                                        |
| `password`                | Password of the Scanner user  | `N/A`                                        |

## Deploy the Helm charts

First, clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

***Optional:*** Update the Helm charts values.yaml files with your environment's custom values. This eliminates the need to pass the parameters to the helm command. Then run one of the commands below to install the relevant services.

### Server chart

```bash
helm upgrade --install --namespace aqua csp ./server --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

### Enforcer chart

```bash
helm upgrade --install --namespace aqua csp-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>,enforcerToken=<aquasec-token>
```

### KubeEnforcer chart

```bash
helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer --set imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>,aquaSecret.kubeEnforcerToken=<kube-enforcer-token>,certsSecret.serverCertificate="$(cat server.crt)",certsSecret.serverKey="$(cat server.key)",validatingWebhook.caBundle="$(cat ca.crt)",aquaSecret.aquaUsername=<aqua-username>,aquaSecret.aquaPassword=<aqua-password>
```

### Scanner chart (optional)

```bash
helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

# Additional deployment items

## High-volume scanner installation

Aqua CSP can deploy a scanner pod that is external to the Aqua Server. This dedicated scanner pod allows the Server to run unprivileged, and provides a high-throughput scan queue anywhere you choose. To install the Scanner alongside the Server components, set the following variables in values.yaml:

```yaml
scanner:
  enabled: true
  replicaCount: "Set quantity"
```

## Non-public cloud provider deployments (examples)

**Creating an ingress to access the Aqua Server**

Example: IBM Cloud Private includes a bundled ingress controller. A sample ingress yaml file is included in the repo.

```sh
kubectl apply -f ingress-example.yaml
```

**Alternative ingress configuration**

Example: The services charts are set to create `ClusterIP' ingress types. You may tune these as appropriate for your environment.

# Troubleshooting

***This section not all-inclusive. It describes common issues that Aqua Security has encountered during deployments.***

**(1) Error:** *UPGRADE/INSTALL FAILED*, configmaps is forbidden.

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

**(2) Error:** No persistent volumes available for this claim and no storage class is set.

**Solution:** Most managed Kubernetes deployments do NOT include all possible storage provider variations at setup time. Refer to the [official Kubernetes guidance on storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) for your platform. Three examples are shown below.

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

**(3) Error:** When executing `kubectl get events -n aqua` you might encounter one of the following errors:
  *no persistent volumes available for this claim and no storage class is set* **or** *PersistentVolumeClaim is not bound*.

**Solution:** If you encounter this error, you need to create a persistent volume prior to chart installation with a generic or existing storage class, specifying `db.persistence.storageClass` in the values.yaml file. A sample file using `aqua-storage` is included in the repo.

  ```sh
  kubectl apply -f pv-example.yaml
  ```

# Support

If you encounter any problems, or would like to give us feedback, we encourage you to raise issues here on GitHub. Please contact us at https://github.com/aquasecurity.
