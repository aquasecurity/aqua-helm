<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua KubeEnforcer Helm Charts

This page provides instructions for using Helm charts to configure and deploy the Aqua KubeEnforcer.

## Contents

- [Aqua KubeEnforcer Helm Charts](#aqua-kubeenforcer-helm-charts)
  - [Contents](#contents)
  - [Starboard](#starboard)
  - [Prerequisites](#prerequisites)
    - [Container registry credentials](#container-registry-credentials)
    - [Clone the GitHub repository with the charts](#clone-the-github-repository-with-the-charts)
    - [Configure TLS authentication between the KubeEnforcer and the API Server](#configure-tls-authentication-between-the-kubeenforcer-and-the-api-server)
  - [Deploy the Helm chart](#deploy-the-helm-chart)
    - [Deploy the KubeEnforcer with Starboard from the GitHub repository](#deploy-the-kubeenforcer-with-starboard-from-the-github-repository)
    - [Deploy the KubeEnforcer with Starboard from a Helm private repository](#deploy-the-kubeenforcer-with-starboard-from-a-helm-private-repository)
  - [Configuration for discovery](#configuration-for-discovery)
  - [Configuration for performing kube-bench scans](#configuration-for-performing-kube-bench-scans)
  - [Configurable parameters](#configurable-parameters)
  - [Issues and feedback](#issues-and-feedback)

## Starboard

Starboard is an Aqua Security open-source tool that increases the effectiveness of Kubernetes security. For this reason, Starboard is deployed by default when you deploy KubeEnforcers.

An important part of Kubernetes security is the evaluation of workload compliance results with respect to Kubernetes Assurance Policies, and preventing the deployment of non-compliant workloads; see Admission control for Kubernetes containers.

When Starboard **is** deployed, it assesses workload compliance throughout the lifecycle of the workloads. This enables the KubeEnforcer to:
* Re-evaluate workload compliance during workload runtime, taking any workload and policy changes into account
* Reflect the results of compliance evaluation in the Aqua UI at all times, not only when workloads are created

When Starboard is **not** deployed, the KubeEnforcer will check workloads for compliance only when the workloads are started.


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

Create TLS certificates which are signed by the local CA certificate. We will pass these certificates with a Helm command to enable TLS authentication between the KubeEnforcer and the API Server to receive events from the ValidatingWebhookConfiguration for Image Assurance functionality.

You can generate these certificates by executing the script:

```
./kube-enforcer-starboard/gen-certs.sh
```

You can also use your own certificates without generating new ones for TLS authentication. All you need is a root CA certificate, a certificate signed by a CA, and a certificate key.

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
Optionally, you can provide these certificates in base64-encoded format as flags:
  a. certsSecret.serverCertificate="<base64_encoded_server.crt>"
  b. certsSecret.serverKey="<base64_encoded_server.key>"
  c. webhooks.caBundle="<base64_encoded_ca.crt>"

## Deploy the Helm chart

### Deploy the KubeEnforcer with Starboard from the GitHub repository

1. Clone the GitHub repository with the charts:

   ```bash
   $ git clone -b 6.2 https://github.com/aquasecurity/kube-enforcer-starboard-helm.git
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the Helm command. Then run one of the following commands to deploy the relevant services.

3. Choose **either** 3a **or** 3b:

   3a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:
     
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer-starboard ./kube-enforcer-starboard
   ```
    
   3b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```bash
   $ kubectl create namespace aqua
   ```
   Next, run the following command:
   
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer-starboard ./kube-enforcer-starboard --set envs.gatewayAddress="<Aqua_Remote_Gateway_IP/URL>",imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>
   ```

### Deploy the KubeEnforcer with Starboard from a Helm private repository

1. Add Aqua Helm Repository

   ```bash
   $ helm repo add aqua-helm https://helm.aquasec.com
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the Helm command. Then run one of the following commands to deploy the relevant services.

3. Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
```bash
$ helm search repo aqua-helm/kube-enforcer-starboard --versions
```

4. Choose **either** 4a **or** 4b:

   4a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:
     
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer-starboard aqua-helm/kube-enforcer-starboard
   ```
    
   4b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```bash
   $ kubectl create namespace aqua
   ```
   Next, copy the content from [Values.yaml](./values.yaml), make the respective changes, and run the following command:
   
   ```shell
   $ helm upgrade --install --namespace aqua kube-enforcer-starboard aqua-helm/kube-enforcer-starboard --values values.yaml --version <>
   ```

Optional flags:

| Flag | Description |
|-|-|
| --namespace | defaults to `aqua` |
| --aquaSecret.kubeEnforcerToken | defaults to ""; you can obtain the KubeEnforcer token from Aqua Enterprise under the Enforcers screen in the default/custom KubeEnforcer group, or you can manually approve KubeEnforcer authentication from Aqua Enterprise under the default/custom KubeEnforcer group in the Enforcers screen. |

## Configuration for discovery

To perform discovery on the cluster, the KubeEnforcer needs a dedicated ClusterRole with `get`, `list`, and `watch` permissions on pods, secrets, nodes, namespaces, deployments, ReplicaSets, ReplicationControllers, StatefulSets, DaemonSets, jobs, CronJobs, ClusterRoles, ClusterRoleBindings, and ComponentStatuses`. 

## Configuration for performing kube-bench scans

To perform kube-bench scans in the cluster, the KubeEnforcer needs:
- A dedicated role in the `aqua` namespace with `get`, `list`, and `watch` permissions on `pods/log`
- `create` and `delete` permissions on jobs

## Configurable parameters

| Parameter | Description  | Default  | Mandatory |
| ----------| ------------ | -------- | --------- |
| `imageCredentials.create`         | Set to create new pull image secret       | `true`   | `YES - New cluster`     |
| `imageCredentials.name`           | Your Docker pull image secret name        | `aqua-registry-secret`    | `YES - New cluster`     |
| `imageCredentials.username`       | Your Docker registry (Docker Hub, etc.) username            | `N/A`    | `YES - New cluster`     |
| `imageCredentials.password`       | Your Docker registry (Docker Hub, etc.) password            | `N/A`    | `YES - New cluster`     |
| `aquaSecret.kubeEnforcerToken`    | Aqua KubeEnforcer (KE) token  | `N/A`    | `YES`  |
| `certsSecret.create`              | Set to create a new secret for KE certs     | `true`   | `YES`  |
| `certsSecret.name`                | Secret name for KE certs | `aqua-kube-enforcer-certs`| `YES`  |
| `certsSecret.serverCertificate`   | Certificate for TLS authentication with the Kubernetes api-server           | `N/A`    | `YES`  |
| `certsSecret.serverKey`           | Certificate key for TLS authentication with the Kubernetes api-server       | `N/A`    | `YES`  |
| `webhooks.caBundle`               | Root certificate for TLS authentication with the Kubernetes api-server      | `N/A`    | `YES`  |
| `envs.gatewayAddress`             | Gateway host address     | `aqua-gateway-svc:8443`   | `YES`  |
| `starboard.serviceAccount.name`   | Starboard service account | `starboard-operator` | `YES` |
| `starboard.clusterRoleBinding.name`   | Starboard cluster binding name | `starboard-operator` | `YES` |
| `starboard.clusterRole.name`   | Starboard cluster role name | `starboard-operator` | `YES` |
| `starboard.image.repositoryUriPrefix`   | Starboard image repository URI | `docker.io/aquasec` | `YES` |
| `starboard.image.repository`   | Starboard image name | `starboard-operator` | `YES` |
| `starboard.tag`   | Starboard image tag | `0.10.1` | `YES` |
| `starboard.OPERATOR_TARGET_NAMESPACES`  | This determines the installation mode, which in turn determines the multi-tenancy support of the operator | `(blank)` | `YES` <br> `(blank string)=> ALLNAMESPACES, foo,bar.baz => specific NAMESPACES` |
| `starboard.OPERATOR_LOG_DEV_MODE`  | The flag to use (or not use) development mode (more human-readable output, extra stack traces and logging information, etc.) | `false` | `YES` |
| `starboard.OPERATOR_CONCURRENT_SCAN_JOBS_LIMIT`  | The maximum number of scan jobs create by the operator | `10` | `YES` |
| `starboard.OPERATOR_SCAN_JOB_RETRY_AFTER`  | The time to wait before retrying a failed scan job | `30s` | `YES` |
| `starboard.OPERATOR_METRICS_BIND_ADDRESS`  | The TCP address to bind to for serving Prometheus metrics. It can be set to 0 to disable the metrics serving. | `:8080` | `YES` |
| `starboard.OPERATOR_HEALTH_PROBE_BIND_ADDRESS`  | The TCP address to bind to for serving health probes, i.e., the /healthz/ and /readyz/ endpoints | `:9090` | `true` |
| `starboard.OPERATOR_CIS_KUBERNETES_BENCHMARK_ENABLED`  |  The flag to enable CIS Kubernetes Benchmark scanning | `true` | `YES` |
| `starboard.OPERATOR_VULNERABILITY_SCANNER_ENABLED`  | The flag to enable vulnerability scanner | `true` | `YES` |
| `starboard.OPERATOR_BATCH_DELETE_LIMIT`  | The maximum number of config audit reports deleted by the operator when the plugin's config has changed | `10` | `YES` |
| `starboard.OPERATOR_BATCH_DELETE_DELAY`  | The time to wait before deleting another batch of config audit reports | `10s` | `YES` |
| `starboard.ports.metricContainerPort`  |
| `starboard.ports.probeCntainerPort`  |
| `starboard.readinessProbe`  |
| `starboard.livenessProbe`  |
| `kubeEnforcerAdvance.enable`      | Advanced KubeEnforcer deployment          | `false`  | `NO`   |
| `kubeEnforcerAdvance.clusterName` | Cluster name of the advance KE deployment | `k8s` | `YES - if kubeEnforcerAdvance.enable` |
| `kubeEnforcerAdvance.nodeID`      | Envoy Node ID of the advance KE deployment    | `envoy` | `YES - if kubeEnforcerAdvance.enable` |

## Issues and feedback

If you encounter any problems or would like to give us feedback on this deployment, we encourage you to raise issues here on GitHub.
