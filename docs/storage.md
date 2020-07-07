# Storage

for setting StorageClasses or PersistentVolumeClaims.

## Persistence

By default persistence is enabled, and a PersistentVolumeClaim is created and mounted in that directory. As a result, a persistent volume will need to be defined, [Examples](https://kubernetes.io/docs/user-guide/persistent-volumes/)

In order to disable this functionality you can change the values.yaml to disable persistence and use an emptyDir instead.

## Storage Class

 Most managed Kubernetes deployments do NOT include all possible storage provider variations at setup time. Refer to the [official Kubernetes guidance on storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) for your platform. Three examples are shown below.

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