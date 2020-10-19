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
- [Deployment instructions](#deployment-instructions)
  - [Add Aqua Helm repository](#add-aqua-helm-repository)
  - [Container registry credentials](#container-registry-credentials)
  - [PostgreSQL database](#postgresql-database)
  - [Ingress](#ingress)
  - [Deploy the Helm charts](#deploy-the-helm-charts)
- [Troubleshooting](#troubleshooting)
- [Issues and feedback](#issues-and-feedback)

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
$ helm repo add aqua-helm https://helm.aquasec.com
```

* Search for all components of the latest version in our Aqua Helm repository

```bash
$ helm search aqua-helm
# Examples
$ helm search aqua-helm --versions
$ helm search aqua-helm --version 4.6.0
```

for helm 3.x
```bash
$ helm search repo aqua-helm
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

```bash
$ helm search aqua-helm -v 5.3
```

for helm 3.x
```bash
$ helm search repo aqua-helm --version 5.3
```

* Search for all components:

for helm 3.x
```bash
$ helm search repo aqua-helm --versions
```

## Container registry credentials

[Link](docs/imagepullsecret.md)

## Ingress

[Link](docs/ingress.md)

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

## Environment Variables

In each charts and components we create an option to define more environment variables to each componenet with 2 ways:
* `extraEnvironmentVars`: is a list of extra enviroment variables to set with name and value parameters.
* `extraSecretEnvironmentVars`: is a list of extra enviroment variables to set, these variables take value from existing Secret objects.

[Link to documentations](https://docs.aquasec.com/docs/environment-variables)

## Deploy the Helm charts

First, clone the GitHub repository with the charts

```bash
$ git clone https://github.com/aquasecurity/aqua-helm.git -b <BRANCH_NAME>
$ cd aqua-helm/
```

***Optional:*** Update the Helm charts values.yaml files with your environment's custom values. This eliminates the need to pass the parameters to the helm command. Then run one of the commands below to install the relevant services.

before start deploying helm charts, plese verify you create `aqua` namespace.
```bash
$ kubectl create namespace aqua
```

### Server chart

```bash
$ helm upgrade --install --namespace aqua aqua ./server --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

### Enforcer chart

```bash
$ helm upgrade --install --namespace aqua aqua-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>,enforcerToken=<aquasec-token>
```

### KubeEnforcer chart

```bash
$ helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer --set imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>,certsSecret.serverCertificate="$(cat server.crt)",certsSecret.serverKey="$(cat server.key)",validatingWebhook.caBundle="$(cat ca.crt)"
```

### Scanner chart (optional)

```bash
$ helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>,imageCredentials.email=<>
```

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
