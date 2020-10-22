<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Helm Charts

This topic contains Helm charts and instructions for the deployment and maintenance of Aqua Cloud Native Security (CSP).

CSP deployments include the following components:
- Server (Console, Database, and Gateway)
- Enforcer
- KubeEnforcer
- Scanner

## Contents

- [Helm charts](#helm-charts)
- [Quick Start](#quick-start)
- [Deployment instructions](#deployment-instructions)
  - [Add Aqua Helm repository](#add-aqua-helm-repository)
  - [Deploy the Helm charts](#deploy-the-helm-charts)
- [Troubleshooting](#troubleshooting)
- [Issues and feedback](#issues-and-feedback)

## Helm charts

This repository includes following charts that may be deployed separately:

* [**Server**](server/) - deploys the Console, Database, Gateway components; and (optionally) the Scanner, Envoy component
* [**Enforcer**](enforcer/) - deploys the Enforcer daemonset
* [**Scanner**](scanner/) - deploys the Scanner deployment
* [**KubeEnforcer**](kube-enforcer/) - deploys the KubeEnforcer deployment
* [**QuickStart**](aqua-quickstart) - deploys Console, Database, Gateway and KubeEnforcer components (Not for Production use)

## Quisk Start

Use [**aqua-quickstart**](aqua-quickstart) chart to quickly install Aqua CSP for testing/POC purpose. This chart doesn't support production grade deployments.

  1. Clone the GitHub repository
  ```bash
  $ git clone https://github.com/aquasecurity/aqua-helm.git
  $ cd aqua-helm/
  ```

  2. Create `aqua` namespace.
  ```bash
  $ kubectl create namespace aqua
  ```

  3. Deploy aqua-quickstart chart
  ```bash
  $ helm upgrade --install --namespace aqua aqua ./aqua-quickstart --set imageCredentials.username=<>,imageCredentials.password=<>
  ```

# Deployment instructions

Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Add Aqua Helm Repository (Optional)

* Please add the Aqua Helm repository to your local Helm repos by executing the following command:
```bash
$ helm repo add aqua-helm https://helm.aquasec.com
```

* Search for all components of the latest version in our Aqua Helm repository
for helm 2.x
```bash
$ helm search aqua-helm
# Examples
$ helm search aqua-helm --versions
$ helm search aqua-helm --version 5.3.0
```

for helm 3.x
```bash
$ helm search repo aqua-helm
# Examples
$ helm search repo aqua-helm --versions
$ helm search repo aqua-helm --version 5.3.0
```

Example output:
```csv
NAME                      CHART VERSION       APP VERSION         DESCRIPTION
aqua-helm/enforcer        5.3.0               5.3                 A Helm chart for the Aqua Enforcer
aqua-helm/scanner         5.3.0               5.3                 A Helm chart for the Aqua Scanner CLI component
aqua-helm/server          5.3.0               5.3                 A Helm chart for the Aqua Console components
aqua-helm/kube-enforcer   5.3.0               5.3                 A Helm chart for the Aqua KubeEnforcer
```

* Search for all components of a specific version in our Aqua Helm repository
Example: for Version 5.3
for helm 2.x
```bash
$ helm search aqua-helm -v 5.3
```

for helm 3.x
```bash
$ helm search repo aqua-helm --version 5.3
```

## Deploy the Helm charts

1. Create `aqua` namespace.
```bash
$ kubectl create namespace aqua
```

2. Install [**Server**](server/) chart

3. Install [**Enforcer**](enforcer/) chart

4. Install [**KubeEnforcer**](kube-enforcer/) chart

5. Install [**Scanner**](scanner/) chart (Optional)

# Troubleshooting

***This section not all-inclusive. It describes common issues that Aqua Security has encountered during deployments.***

**(1) Error:** *UPGRADE/INSTALL FAILED*, configmaps is forbidden.

```bash
Error: UPGRADE FAILED: configmaps is forbidden: User "system:serviceaccount:kube-system:default" cannot list configmaps in the namespace "kube-system"
```

**Solution:** Create a service account for Tiller to utilize.
```bash
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
helm init --service-account tiller --upgrade
```

**(2) Error:** No persistent volumes available for this claim and no storage class is set.

**Solution:** Most managed Kubernetes deployments do NOT include all possible storage provider variations at setup time. Refer to the [official Kubernetes guidance on storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) for your platform. Three examples are shown below.

for more information go to storage docs, [Link](docs/storage.md)

**(3) Error:** When executing `kubectl get events -n aqua` you might encounter one of the following errors:
  *no persistent volumes available for this claim and no storage class is set* **or** *PersistentVolumeClaim is not bound*.

**Solution:** If you encounter this error, you need to create a persistent volume prior to chart installation with a generic or existing storage class, specifying `db.persistence.storageClass` in the values.yaml file. A sample file using `aqua-storage` is included in the repo.

```bash
$ kubectl apply -f pv-example.yaml
```

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
