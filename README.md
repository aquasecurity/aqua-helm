<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Overview

This page contains instructions for deploying Aqua Enterprise in a Kubernetes cluster, using the [Helm package manager](https://helm.sh/).

Refer to the Aqua Enterprise product documentation for the broader context: [Kubernetes with Helm Charts](https://docs.aquasec.com/v6.5/docs/kubernetes-with-helm).

## Contents

- [Overview](#overview)
  - [Contents](#contents)
  - [Helm charts](#helm-charts)
- [Deployment instructions](#deployment-instructions)
    - [(Optional) Add the Aqua Helm repository](#optional-add-the-aqua-helm-repository)
        - [For Helm 2.x](#for-helm-2x)
        - [For Helm 3.x](#for-helm-3x)
    - [Deploy the Helm charts](#deploy-the-helm-charts)
    - [Troubleshooting](#troubleshooting)
      - [Error 1](#error-1)
      - [Error 2](#error-2)
      - [Error 3](#error-3)
- [Quick-start deployment (not for production purposes)](#quick-start-deployment-not-for-production-purposes)
- [Issues and feedback](#issues-and-feedback)

## Helm charts

This repository includes the following charts; they can be deployed separately:

| Chart | Description | Latest Chart Version |
|-|-|-|
| [Server](server/) | Deploys the Console, Database, and Gateway components; optionally deploys Envoy component | 6.5.0 |
| [Enforcer](enforcer/) | Deploys the Aqua Enforcer daemonset | 6.5.0 |
| [Scanner](scanner/)  | Deploys the Aqua Scanner deployment | 6.5.0 |
| [KubeEnforcer](kube-enforcer/)| Deploys Aqua KubeEnforcer | 6.5.0 |
| [Gateway](gateway)| Deploys the Aqua Standalone Gateway | 6.5.0 |
| [Tenant-Manager](tenant-manager/)| Deploys the Aqua Tenant Manager | 6.5.0 |
| [QuickStart](aqua-quickstart/ )| Not for production use (see [below](#quick-start-deployment-not-for-production-purposes)). Deploys the Console, Database, Gateway and KubeEnforcer components | 6.5.0 |


# Deployment instructions

Aqua Enterprise deployments include the following components:
- Server (Console, Database, and Gateway)
- Enforcer
- KubeEnforcer
- Scanner

Follow the steps in this section for production-grade deployments. You can either clone the aqua-helm git repo or you can add our Helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com)).

### (Optional) Add the Aqua Helm repository

1. Add the Aqua Helm repository to your local Helm repos by executing the following command:
```bash
$ helm repo add aqua-helm https://helm.aquasec.com
```

2. Search for all components of the latest version in our Aqua Helm repository

##### For Helm 2.x
```bash
$ helm search aqua-helm
# Examples
$ helm search aqua-helm --versions
$ helm search aqua-helm --version 6.5.0
```

##### For Helm 3.x
```bash
$ helm search repo aqua-helm
# Examples
$ helm search repo aqua-helm --versions
$ helm search repo aqua-helm --version 6.5.0
```

Example output:
```csv
NAME                            CHART VERSION       APP VERSION         DESCRIPTION
aqua-helm/enforcer                  6.5.0               6.5                 A Helm chart for the Aqua Enforcer
aqua-helm/scanner                   6.5.0               6.5                 A Helm chart for the Aqua Scanner CLI component
aqua-helm/server                    6.5.0               6.5                 A Helm chart for the Aqua Console components
aqua-helm/kube-enforcer             6.5.0               6.5                 A Helm chart for the Aqua KubeEnforcer
aqua-helm/gateway                   6.5.0               6.5                 A Helm chart for the Aqua Gateway
aqua-helm/tenant-manager            6.5.0               6.5                 A Helm chart for the Aqua Tenant Manager
```

### Deploy the Helm charts

1. Create the `aqua` namespace.
    ```bash
    $ kubectl create namespace aqua
    ```
2. Deploy the [**Server**](server/) chart.
3. Deploy the [**Enforcer**](enforcer/) chart.
4. Deploy the [**KubeEnforcer**](kube-enforcer/) chart.
5. (Optional) Deploy the [**Scanner**](scanner/) chart.
6. (For multi-cluster) Deploy the [**Gateway**](gateway/) chart.
7. (Optional) Deploy the [**TenantManager**](tenant-manager/) chart.
8. Access the Aqua UI in browser with {{ .Release.Name }}-console-svc service and port, to check the service details:
      ```bash
      $ kubectl get svc -n aqua
      ```
     * Example:
       * http://< Console IP/DNS >:8080* (default access without SSL) or
       * https://< Console IP/DNS >:443* (If SSL configured to console component in server chart)
### Troubleshooting

**This section not all-inclusive. It describes some common issues that we have encountered during deployments.**

#### Error 1

* Error message: **UPGRADE/INSTALL FAILED, configmaps is forbidden.**
* Example:

```bash
Error: UPGRADE FAILED: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
```

* Solution: Create a service account for Tiller to utilize.
```bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade
```

#### Error 2

* Error message: **No persistent volumes available for this claim and no storage class is set.**
* Solution: Most managed Kubernetes deployments do NOT include all possible storage provider variations at setup time. Refer to the [official Kubernetes guidance on storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) for your platform. 
For more information see the [storage documentation](docs/storage.md).

#### Error 3

* Error message: When executing `kubectl get events -n aqua` you might encounter either **No persistent volumes available for this claim and no storage class is set** or 
**PersistentVolumeClaim is not bound**.
* Solution: If you encounter either of these errors, you need to create a persistent volume prior to chart deployment with a generic or existing storage class. Specify `db.persistence.storageClass` in the values.yaml file. A sample file using `aqua-storage` is included in the repo.

```bash
$ kubectl apply -f pv-example.yaml
```

# Quick-start deployment (not for production purposes)

Quick-start deployments are fast and easy. 
They are intended for deploying Aqua Enterprise for non-production purposes, such as proofs-of-concept (POCs) and environments intended for instruction, development, and test.

Use the [**aqua-quickstart**](aqua-quickstart) chart to 

  1. Clone the GitHub repository
  ```bash
  $ git clone https://github.com/aquasecurity/aqua-helm.git
  $ cd aqua-helm/
  ```

  2. Create the `aqua` namespace.
  ```bash
  $ kubectl create namespace aqua
  ```

  3. Deploy aqua-quickstart chart
  ```bash
  $ helm upgrade --install --namespace aqua aqua ./aqua-quickstart --set imageCredentials.username=<>,imageCredentials.password=<>
  ```

# Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
