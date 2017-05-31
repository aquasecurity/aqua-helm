# Helm chart for installing Aqua Security server components

## Downloading the charts

Because the Aqua server components are private, this chart is not available in the Helm package repository, but you can simply clone this repository and install from the chart files herein. 

## Prerequisites

### Helm 

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component on your Kubernetes cluster). 

### Secrets

The Aqua server components are private, and you will need to set up an imagePullSecret as follows. 

```bash
kubectl create secret docker-registry dockerhub --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

The default name for this secret is `dockerhub`. If you use a different name you can override this when you install the helm chart by specifying `--set global.imagePullSecretName=<secret name>`. 

You also need to set up a secret for the Aqua Database password. 

```bash
kubectl create secret generic aqua-db --from-literal=password=<make up a password>
```

## Installing the Helm chart

```bash
$ helm install ./aqua
```

## Installing the Aqua Agent

The Helm chart installs the server components (the database, gateway and web UI). 

You will also need to install the Aqua Agent daemonset on your cluster. We recommend using the "Batch install" process found in the UI under the "Hosts" tab.

