<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" heigth="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" heigth="100"/>

# Aqua Security Helm Charts

Helm charts for installation and maintainence of Aqua Container Security Platform server and enforcer componants.

## Charts Details

This repository includes two charts that may be installed separately:

* [**Server**](server/) - installs the console, gateway and optional componants. Ie; database, scanner CLI
* [**Enforcer**](enforcer/) - installs the enforcer daemonset

## Prerequsites

### Container Registry Credentials

The Aqua server components are available in our private repository which requires authentication. The charts by default create a secret based on the values.yaml. One may manually pre-create this secret via the following command:

```bash
kubectl create secret docker-registry csp-registry-secret  --docker-server="registry.aquasec.com" --namespace aqua --docker-username="jg@example.com" --docker-password="Truckin" --docker-email="jg@example.com"
```

### PostgreSQL database

Aqua Security recommends implementing a highly available PostgreSQL database. By default the console chart will install a PostgreSQL database and attach it to persistent storage for POC useage and testing. For production use one may override this default behavour and specify an existing PostgreSQL database by setting the following variables in values.yaml:

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

### High Volume Scanner Installation

Aqua CSP has the ability to deploy an scanning pod external to the Console. This dedicated scanning pod allows the console to run unpriviliged, as well as providing a high throughput scanning queue anywhere you choose. To install the Scanner CLI alongside the console components set the following variables in values.yaml:

```yaml
scanner:
  enabled: true
scanner.replicas: "Set quantity"
```

### Helm Customizations / Troubleshooting

***This section not all-inclusive. It includes information regarding common issues Aqua has encountered during deployments***

**Error:** UPGRADE/INSTALL FAILED, configmaps is forbidden

  ```sh
  Error: UPGRADE FAILED: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
  ```

**Solution:** create a service account for tiller to utilize
  ```sh
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
  helm init --service-account tiller --upgrade
  ```

**Error:** no persistent volumes available for this claim and no storage class is set
  
**Solution:** Most managed kubernetes do NOT include all possible storage provider variations at setup time. Refer to kubernetes official guidance https://kubernetes.io/docs/concepts/storage/storage-classes for your platform. Three primary examples are below.

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

**Error:** When executing `kubectl get events -n aqua` you encounter one of the following errors:
  *no persistent volumes available for this claim and no storage class is set* **or** *PersistentVolumeClaim is not bound*

**Solution:** 
  If you see this error, you need to create a persistant volume prior to chart installation with a generic or existing storage class and specify `db.persistence.storageClass` within the values.yaml. An example file using `aqua-storage` is included in the repo. 

  ```sh
  kubectl apply -f pv-example.yaml
  ```

* **Creating an ingress to access the Aqua Console**
* IBM Cloud Private includes a bundled ingress controller. An example ingress yaml is included in the repo.
```sh
kubectl apply -f ingress-example.yaml
```

* **Alternative Ingress Configuration**
* The services charts are set to create `ClusterIP' ingress types An example ingress yaml is included in the repo.


## Installing the Charts

Clone the github repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

***Optional*** - Update the helm charts values.yaml file with your environments custom values. This eliminates the need to pass the parameters to the helm command

Then, run one of the commands below to install the relevant services.

### Server (console)

```bash
helm upgrade --install --namespace aqua csp ./server --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

### Enforcer

```bash
helm upgrade --install --namespace aqua csp-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>,enforcerToken=<aquasec-token>
```

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Console

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `csp-registry-secret`                                                                   |
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
| `scanner.user`                | Username for the scanner user assigned to the scanner role  | N/A                                        |
| `scanner.password`                | Password for scanner user  | N/A                                        |


### Enforcer

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `false`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.usernmae`               | Your Docker registry (DockerHub and etc) username    | N/A                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub and etc) password    | N/A                                                                   |
| `imageCredentials.email`                  | Your Docker registry (DockerHub and etc) email    | N/A                                                                   |
| `enforcerToken`                           | Aquasec Enforcer token    | N/A                                                     |
| `server`                          | Gateways host name    | `aqua-gateway`                                                     |
| `port`                            | Gateway port    | `3622`                                                     |
    ```

## Issues and feedback
If you come across any problems or would like to give us feedback on deployments we encourage you to raise issues here on GitHub.