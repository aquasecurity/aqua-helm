<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security KubeEnforcer Helm Charts

This page provides instructions for using HELM charts for configuring and deploying the Aqua Enterprise KubeEnforcer.

## Contents

- [Aqua Security KubeEnforcer Helm Charts](#aqua-security-kubeenforcer-helm-charts)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container registry credentials](#container-registry-credentials)
    - [Clone the GitHub repository with the charts](#clone-the-github-repository-with-the-charts)
    - [Configure TLS authentication between the KubeEnforcer and the API Server](#configure-tls-authentication-between-the-kubeenforcer-and-the-api-server)
  - [Deploying the HELM chart](#deploying-the-helm-chart)
    - [Installing Aqua Kube-Enforcer from Github Repo](#installing-aqua-kube-enforcer-from-github-repo)
    - [Installing Aqua Kube-Enforcer from Helm Private Repository](#installing-aqua-kube-enforcer-from-helm-private-repository)
  - [Configuration for discovery](#configuration-for-discovery)
  - [Configuration for performing kube-bench scans](#configuration-for-performing-kube-bench-scans)
  - [Configurable parameters](#configurable-parameters)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container registry credentials

[Link](../docs/imagepullsecret.md)

### Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

### Configure TLS authentication between the KubeEnforcer and the API Server

You need to enable TLS authentication from the API Server to the KubeEnforcer. Perform these steps:

Create TLS certificates which are signed by the local CA certificate. We will pass these certificates with a HELM command to enable TLS authentication between the KubeEnforcer and the API Server to receive events from the validatingwebhookconfiguration for Image Sssurance functionality.

You can generate these certificates by executing the script:

```
./kube-enforcer/gen-certs.sh
```

You can also use your own certificates without generating new ones for TLS authentication. All we need is a root CA certificate, a certificate signed by a CA, and a certificate key.

You can optionally configure the certificates generated from the script above in the ```values.yaml``` file.

You need to encode the certificates into base64 for ```ca.crt```, ```server.crt``` and ```server.key``` using this command:

```
cat <file-name> | base64 | tr -d '\n'
```

Provide the certificates previously obtained in the fields of the ```values.yaml``` file, as indicated here:

```
certsSecret:
  name: aqua-kube-enforcer-certs
  serverCertificate: "<server.crt>"
  serverKey: "<server.key>"

webhooks:
  caBundle: "<ca.crt>"
```
Optionally, you can provide these certificates in base64 encoded format as flags:
  a. certsSecret.serverCertificate="<base64_encoded_server.crt>"
  b. certsSecret.serverKey="<base64_encoded_server.key>"
  c. webhooks.caBundle="<base64_encoded_ca.crt>"

## Deploying the HELM chart

### Installing Aqua Kube-Enforcer from Github Repo

1. Clone the GitHub repository with the charts:

   ```bash
   $ git clone -b 6.2 https://github.com/aquasecurity/kube-enforcer-helm.git
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the HELM command. Then run one of the following commands to deploy the relevant services.

3. Choose **either** 3a **or** 3b:

   3a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:
     
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer
   ```
    
   3b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```bash
   $ kubectl create namespace aqua
   ```
   Next, run the following command:
   
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer --set envs.gatewayAddress="<Aqua_Remote_Gateway_IP/URL>",imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>
   ```

### Installing Aqua Kube-Enforcer from Helm Private Repository

1. Add Aqua Helm Repository

   ```bash
   $ helm repo add aqua-helm https://helm.aquasec.com
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the HELM command. Then run one of the following commands to deploy the relevant services.

3. Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
```bash
$ helm search repo aqua-helm/kube-enforcer --versions
```

4. Choose **either** 4a **or** 4b:

   4a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:
     
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer
   ```
    
   4b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```bash
   $ kubectl create namespace aqua
   ```
   Next, copy the values.yaml content from  [Values.yaml](./values.yaml) and make the respective changes then run the following command:
   
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer --values values.yaml --version <>
   ```

Optional flags:

| Flag | Description |
|-|-|
| --namespace | defaults to `aqua` |
| --aquaSecret.kubeEnforcerToken | defaults to ""; you can find the KubeEnforcer token from Aqua Enterprise under the Enforcers screen in the default/custom KubeEnforcer group, or you can manually approve KubeEnforcer authentication from Aqua Enterprise under the default/custom KubeEnforcer group in the Enforcers screen. |

## Configuration for discovery

To perform discovery on the cluster, the KubeEnforcer needs a dedicated ClusterRole with `get`, `list`, and `watch` permissions on pods, secrets, nodes, namespaces, deployments, ReplicaSets, ReplicationEontrollers, StatefulSets, DaemonSets, jobs, CronJobs, ClusterRoles, ClusterRoleBindings, and ComponentStatuses`. 

## Configuration for performing kube-bench scans

To perform kube-bench scans in the cluster, the KubeEnforcer needs:
- A dedicated role in the `aqua` namespace with `get`, `list`, and `watch` permissions on `pods/log`
- `create` and `delete` permissions on jobs

## Configurable parameters

| Parameter                         | Description                                                                 | Default                   | Mandatory               |
| --------------------------------- | --------------------------------------------------------------------------- | ------------------------- | ----------------------- |
| `imageCredentials.create`         | Set to create new pull image secret                                         | `true`                    | `YES - New cluster`     |
| `imageCredentials.name`           | Your Docker pull image secret name                                          | `aqua-registry-secret`    | `YES - New cluster`     |
| `imageCredentials.username`       | Your Docker registry (DockerHub, etc.) username                             | `N/A`                     | `YES - New cluster`     |
| `imageCredentials.password`       | Your Docker registry (DockerHub, etc.) password                             | `N/A`                     | `YES - New cluster`     |
| `aquaSecret.kubeEnforcerToken`    | Aqua KubeEnforcer token                                                     | `N/A`                     | `YES`                   |
| `certsSecret.create`              | Set to create new secret for KE certs                                       | `true`                    | `YES`                   |
| `certsSecret.name`                | Secret name for KE certs                                                    | `aqua-kube-enforcer-certs`| `YES`                   |
| `certsSecret.serverCertificate`   | Certificate for TLS authentication with the Kubernetes api-server           | `N/A`                     | `YES`                   |
| `certsSecret.serverKey`           | Certificate key for TLS authentication with the Kubernetes api-server       | `N/A`                     | `YES`                   |
| `webhooks.caBundle`               | Root certificate for TLS authentication with the Kubernetes api-server      | `N/A`                     | `YES`                   |
| `envs.gatewayAddress`             | Gateway host address                                                        | `aqua-gateway-svc:8443`   | `YES`                   |
| `kubeEnforcerAdvance.enable`      | Advance Kube Enforcer Deployment                                            | `false`                   | `NO`                    |
| `kubeEnforcerAdvance.clusterName` | Cluster name of the advance KE deployment                                   | `k8s`                     | `NO`                    |
| `kubeEnforcerAdvance.clusterID`   | Cluster name of the advance KE deployment                                   | `N/A`                     | `NO`                    |
| `nodeSelector`                    | Kubernetes node selector                                                    | `{}`                      | `NO`                    |



## Issues and feedback

If you encounter any problems or would like to give us feedback on this deployment, we encourage you to raise issues here on GitHub.
