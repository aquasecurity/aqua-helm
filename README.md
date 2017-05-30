# Helm chart for installing Aqua Security server components

## Prerequisites

The Aqua server components are private, and you will need to set up an imagePullSecret as follows. 

```bash
kubectl create secret docker-registry dockerhub --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

The default name for this secret is `dockerhub`. If you use a different name you can override this 
when you install the helm chart by specifying `--set global.imagePullSecretName=<secret name>`. 

## Installing the Helm chart

To install the chart with the release name `my-aqua`:

```bash
$ helm install --set db.password=<specify a password> --name my-aqua aqua
```

## Installing the Aqua Agent

The Helm chart installs the server components (the database, gateway and web UI). 

You will also need to install the Aqua Agent daemonset on your cluster. We recommend using the "Batch install" process found in the UI under the "Hosts" tab.

