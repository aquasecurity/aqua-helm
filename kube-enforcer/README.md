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
  - [Configuring KubeEnforcer mTLS with Gateway/Envoy](#configuring-kubeenforcer-mtls-with-gatewayenvoy)
  - [Configuration for KubeEnforcer Advance deployment](#configuration-for-kubeenforcer-advance-deployment)
  - [Configurable Variables](#configurable-variables)
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

```shell
git clone -b 6.5 https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

### Configure TLS authentication between the KubeEnforcer and the API Server

You need to enable TLS authentication from the API Server to the KubeEnforcer. Perform these steps:

Create TLS certificates which are signed by the local CA certificate. We will pass these certificates with a Helm command to enable TLS authentication between the KubeEnforcer and the API Server to receive events from the ValidatingWebhookConfiguration for Image Assurance functionality.

You can generate these certificates by executing the script:

```shell
./kube-enforcer/gen-certs.sh
```

You can also use your own certificates without generating new ones for TLS authentication. All you need is a root CA certificate, a certificate signed by a CA, and a certificate key.

You can configure the certificates generated from the above script or own certificates in the ```values.yaml``` file.

You need to encode the certificates into base64 for ```ca.crt```, ```server.crt``` and ```server.key``` using this command:

```shell
cat <ca.crt> | base64 | tr -d '\n'
cat <server.crt> | base64 | tr -d '\n'
cat <server.key> | base64 | tr -d '\n'
```

Provide the certificates previously obtained in the fields of the ```values.yaml``` file, as indicated here:

```shell
certsSecret:
  create: true
  name: aqua-kube-enforcer-certs
  serverCertificate: "<base64_encoded_server.crt>"
  serverKey: "<base64_encoded_server.key>"

webhooks:
  caBundle: "<base64_encoded_ca.crt>"
```

## Deploy the Helm chart

### Deploy the KubeEnforcer with Starboard from the GitHub repository

1. Clone the Aqua Helm GitHub repository with the charts (skip if you have already cloned the aqua-helm repo):

   ```shell
   git clone -b 6.5 https://github.com/aquasecurity/aqua-helm.git
   cd aqua-helm
   ```

2. Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the Helm command. Then run one of the following commands to deploy the relevant services.

3. Choose **either** 3a **or** 3b:

   3a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:

   ```shell
    helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer
   ```
    
   3b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```shell
   kubectl create namespace aqua
   ```
   Next, run the following command:
   
   ```shell
   helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer --set gateway.address="<Aqua_Remote_Gateway_IP/URL>",imageCredentials.create=true,imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>
   ```

### Deploy the KubeEnforcer with Starboard from a Helm private repository

1. Add Aqua Helm Repository

   ```shell
   helm repo add aqua-helm https://helm.aquasec.com
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the Helm command. Then run one of the following commands to deploy the relevant services.

3. Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command

   ```shell
   helm search repo aqua-helm/kube-enforcer --versions
   ```

4. Choose **either** 4a **or** 4b:

   4a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:

   ```shell
   helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer --version <>
   ```
    
   4b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```shell
   kubectl create namespace aqua
   ```
   Next, copy the content from [Values.yaml](./values.yaml), make the respective changes, and run the following command:
   
   ```shell
   helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer --values values.yaml --version <>
   ```

5. Optional flags:

| Flag | Description |
|-|-|
| --namespace | defaults to `aqua` |
| --aquaSecret.kubeEnforcerToken | defaults to `"ke-token"`; you can obtain the KubeEnforcer token from Aqua Enterprise under the Enforcers screen in the default/custom KubeEnforcer group, or you can manually approve KubeEnforcer authentication from Aqua Enterprise under the default/custom KubeEnforcer group in the Enforcers screen. |

## Configuration for discovery

To perform discovery on the cluster, the KubeEnforcer needs a dedicated ClusterRole with `get`, `list`, and `watch` permissions on pods, secrets, nodes, namespaces, deployments, ReplicaSets, ReplicationControllers, StatefulSets, DaemonSets, jobs, CronJobs, ClusterRoles, ClusterRoleBindings, and ComponentStatuses`. 

## Configuration for performing kube-bench scans

To perform kube-bench scans in the cluster, the KubeEnforcer needs:
- A dedicated role in the `aqua` namespace with `get`, `list`, and `watch` permissions on `pods/log`
- `create` and `delete` permissions on jobs
-  `create` and `delete` permissions on pods(Only for Openshift platform)

## Configuring KubeEnforcer mTLS with Gateway/Envoy

In order to support L7 / gRPC communication between gateway and enforcers Aqua recommends that customers use the Envoy load balancer. Following are the detailed steps to enable and deploy a secure envoy based load balancer.

   1. Generate TLS certificates signed by a public CA or Self-Signed CA

      ```shell
      # Self-Signed Root CA (Optional)
      #####################################################################################

      # Create Root Key
      # If you want a non password protected key just remove the -des3 option
      openssl genrsa -des3 -out rootCA.key 4096
      # Create and self sign the Root Certificate
      openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
      #####################################################################################
      # Create a certificate
      #####################################################################################

      # Create the certificate key
      openssl genrsa -out mydomain.com.key 2048
      # Create the signing (csr)
      openssl req -new -key mydomain.com.key -out mydomain.com.csr
      # Verify the csr content
      openssl req -in mydomain.com.csr -noout -text

      #####################################################################################
      # Generate the certificate using the mydomain csr and key along with the CA Root key
      #####################################################################################

      openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256

      #####################################################################################
      # If you wish to use a Public CA like GoDaddy or LetsEncrypt please
      # submit the mydomain csr to the respective CA to generate mydomain crt
      ```

   2. Create TLS cert secret
   ```shell
   $ kubectl create secret generic ke-mtls-certs --from-file=mydomain.com.crt --from-file=mydomain.com.ke --from-file=rootCA.crt -n aqua
   ```

   3. Edit the values.yaml file to include above secret 
   ```
       TLS:
         listener:
            secretName: "envoy-mtls-certs"
            publicKey_fileName: "mydomain.com.crt"
            privateKey_fileName: "mydomain.com.key"
            rootCA_fileName: "rootCA.crt"
   ```
   4. For more customizations please refer to [***Configurable Variables***](#configure-variables)
## Configuration for KubeEnforcer Advance deployment

   1. Change kubeEnforcerAdvance.enable to `true` in `values.yaml`
   2. (optional) By default envoy generates self-signed certs for secure communcations.
      1. Optionally, Generate TLS certificates signed by a public CA or Self-Signed CA

      ```bash
         #####################################################################################
         # Create a certificate
         #####################################################################################

         # Create the certificate key
         openssl genrsa -out mydomain.com.key 2048
         # Create the signing (csr)
         openssl req -new -key mydomain.com.key -out mydomain.com.csr
         # Verify the csr content
         openssl req -in mydomain.com.csr -noout -text

         #####################################################################################
         # Generate the certificate using the mydomain csr and key along with the CA Root key
         #####################################################################################

         openssl x509 -req -in mydomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out mydomain.com.crt -days 500 -sha256

         #####################################################################################
         # If you wish to use a Public CA like GoDaddy or LetsEncrypt please
         # submit the mydomain csr to the respective CA to generate mydomain crt
         ```

      2. (optional) Create TLS cert secret
         ```shell
         $ kubectl create secret generic envoy-mtls-certs --from-file=mydomain.com.crt --from-file=mydomain.com.key --from-file=rootCA.crt -n aqua
         ```

      3. (optional) Edit the values.yaml file to include above secret to mount custom certificates to envoy
      ```yaml
          TLS:
            listener:
               create: "true"
               secretName: "envoy-mtls-certs"
               publicKey_fileName: "mydomain.com.crt"
               privateKey_fileName: "mydomain.com.key"
               rootCA_fileName: "rootCA.crt"
      ```
   
   3. For more customizations please refer to [***Configurable Variables***](#configure-variables)
## Configurable Variables

| Parameter | Description  | Default  | Mandatory |
| ----------| ------------ | -------- | --------- |
| `imageCredentials.create`| Set to create new pull image secret| `true`   | `Yes - New cluster`|
| `imageCredentials.name`  | Your Docker pull image secret name | `aqua-registry-secret`    | `Yes - New cluster`|
| `imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`| `Yes - New cluster` |
| `imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`| `Yes - New cluster` |
| `imageCredentials.username`| Your Docker registry (Docker Hub, etc.) username   | `N/A`    | `Yes - New cluster`|
| `imageCredentials.password`| Your Docker registry (Docker Hub, etc.) password   | `N/A`    | `Yes - New cluster`|
| `serviceAccount.create` | enable to create serviceaccount | `false` | `Yes - New cluster` |
| `serviceAccount.name` | service acccount name | `aqua-sa` | `No` |
| `platform` | Orchestration platform name (Allowed values are aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s, mke) | `""` | `Yes, for openshift and mirantis platform`
| `aqua_enable_cache` | Set this to yes to enable caching for the KubeEnforcer; this can improve performance in clusters with high traffic | `yes` | `Yes` |
| `aqua_cache_expiration_period` | If caching is enabled, you can adjust the cache refresh time. This defaults to 60 seconds | `60` | `Yes` </br> `if aqua_enable_cache enabled` |
| `image.repository` | the docker image name to use | `kube-enforcer`| `Yes` |
| `image.tag` | The image tag to use. | `6.5`| `Yes` |
| `image.pullPolicy` | The kubernetes image pull policy. | `Always`| `Yes` |
| `ke_ReplicaCount` | kube-enforcer replica count | `1`| `No`
| `clusterName`   | Cluster name registered with Aqua in Infrastructure tab | `aqua-secure` | `No` |
| `logicalName` | This variable is used in conjunction with the KubeEnforcer group logical name to determine how the KubeEnforcer name will be displayed in the Aqua UI | `""` | `No` |
| `logLevel` | Setting this might be helpful for problem determination. Acceptable values are DEBUG, INFO, WARN, and ERROR | `""` | `No`
| `certsSecret.create`| Set to create a new secret for TLS authentication with the Kubernetes api-server, Change to false if you're using existing server certificate secret | `true`   | `Yes`  |
| `certsSecret.name`| Secret name for TLS authentication with the Kubernetes api-server, Change secret name if already exists with server/web public certificate | `aqua-kube-enforcer-certs`| `Yes`  |
| `certsSecret.serverCertificate`   | Public certificate for TLS authentication with the Kubernetes api-server, If certsSecret.create is enable to true, Add base64 value of the Public Certificate(server certificate) or add filename of certificate if it is loading from custom secret  | `N/A`    | `Yes`  |
| `certsSecret.serverKey`  | Certificate key for TLS authentication with the Kubernetes api-server, If certsSecret.create is enable to true, Add base64 value of the Private Key(server key) or add filename of key if it is loading from custom secret| `N/A`    | `Yes`  |
| `aquaSecret.create`    | Aqua KubeEnforcer (KE) token secret creation | `true`    | `Yes`  |
| `aquaSecret.name`    | Aqua KubeEnforcer (KE) token secret name  | `aqua-kube-enforcer-token` | `Yes`  |
| `aquaSecret.kubeEnforcerToken`    | Aqua KubeEnforcer (KE) token  | `ke-token`    | `Yes`  |
| `gateway.address`    | Gateway host address| `aqua-gateway-svc.aqua`   | `Yes`  |
| `gateway.port` | Gateway host port | `8443`   | `Yes`  |
| `clusterRole.name` | KE cluster role name | `aqua-kube-enforcer` | `Yes` |
| `clusterRoleBinding.name` | KE cluster rolebinding name | `aqua-kube-enforcer` | `Yes` |
| `role.name` | KE role name | `aqua-kube-enforcer` | `Yes` |
| `roleBinding.name` | KE rolebinding name | `aqua-kube-enforcer` | `Yes` |
| `webhooks.certManager` | Enable to true if using KE webhook certificates generated from kubernetes cert-manager | `false` | `No`
| `webhooks.caBundle` | Root certificate for TLS authentication with the Kubernetes api-server, Add base64 value of the CA cert/Ca Bundle/RootCA Cert if certificates are not generated from cert-manager to webhooks.caBundle | `N/A`    | `Yes` </br> `if webhooks.certManager is false`  |
| `webhooks.failurePolicy` | Webhook failure policy | `false` | `Yes` |
| `webhooks.validatingWebhook.name` | KE validating webhook name | `kube-enforcer-admission-hook-config` | `Yes` |
| `webhooks.validatingWebhook.annotations` |  KE validating webhook annotations | `{}` | `No` |
| `webhooks.mutatingWebhook.name` | | `kube-enforcer-me-injection-hook-config` | `Yes` |
| `webhooks.mutatingWebhook.annotations` | KE mutating webhook annotations | `{}` | `No` |
| `container_securityContext` | KE container security context | `{}` | `No` |
| `resources` |	KE Resource requests and limits | `{}`| `No` |
| `nodeSelector` |	Kubernetes node selector	| `{}`| `No` |
| `tolerations` |	Kubernetes node tolerations	| `[]`| `No` |
| `podAnnotations` | Kubernetes pod annotations | `{}` | `No` |
| `affinity` |	Kubernetes node affinity | `{}`| `No` |
| `TLS.enabled` | If require secure channel communication | `false` | `No` |
| `TLS.secretName` | certificates secret name | `nil` | `No` |
| `TLS.publicKey_fileName` | filename of the public key eg: aqua_ke.crt | `nil`  |  `Yes` <br /> `if gate.TLS.enabled is set to true` |
| `TLS.privateKey_fileName`   | filename of the private key eg: aqua_ke.key | `nil`  |  `Yes` <br /> `if gate.TLS.enabled is set to true` |
| `TLS.rootCA_fileName` |  filename of the rootCA, if using self-signed certificates eg: rootCA.crt | `nil`  |  `No` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `starboard.replicaCount` | Starboard replica count | `1` | `Yes` |
| `starboard.appName` | Starboard application name | `starboard-operator` | `Yes` |
| `starboard.serviceAccount.name`   | Starboard service account | `starboard-operator` | `Yes` |
| `starboard.clusterRoleBinding.name`   | Starboard cluster binding name | `starboard-operator` | `Yes` |
| `starboard.clusterRole.name`   | Starboard cluster role name | `starboard-operator` | `Yes` |
| `starboard.image.repositoryUriPrefix`   | Starboard image repository URI | `docker.io/aquasec` | `Yes` |
| `starboard.image.repository`   | Starboard image name | `starboard-operator` | `Yes` |
| `starboard.tag`   | Starboard image tag | `0.13.0` | `Yes` |
| `starboard.pullPolicy`   | Starboard image pullPolicy | `Always` | `Yes` |
| `starboard.OPERATOR_TARGET_NAMESPACES`  | This determines the installation mode, which in turn determines the multi-tenancy support of the operator | `(blank)` | `Yes` <br> `(blank string)=> ALLNAMESPACES, foo,bar.baz => specific NAMESPACES` |
| `starboard.OPERATOR_LOG_DEV_MODE`  | The flag to use (or not use) development mode (more human-readable output, extra stack traces and logging information, etc.) | `false` | `Yes` |
| `starboard.OPERATOR_CONCURRENT_SCAN_JOBS_LIMIT`  | The maximum number of scan jobs create by the operator | `10` | `Yes` |
| `starboard.OPERATOR_SCAN_JOB_RETRY_AFTER`  | The time to wait before retrying a failed scan job | `30s` | `Yes` |
| `starboard.OPERATOR_METRICS_BIND_ADDRESS`  | The TCP address to bind to for serving Prometheus metrics. It can be set to 0 to disable the metrics serving. | `:8080` | `Yes` |
| `starboard.OPERATOR_HEALTH_PROBE_BIND_ADDRESS`  | The TCP address to bind to for serving health probes, i.e., the /healthz/ and /readyz/ endpoints | `:9090` | `true` |
| `starboard.OPERATOR_CIS_KUBERNETES_BENCHMARK_ENABLED`  |  The flag to enable CIS Kubernetes Benchmark scanning | `true` | `Yes` |
| `starboard.OPERATOR_VULNERABILITY_SCANNER_ENABLED`  | The flag to enable vulnerability scanner | `true` | `Yes` |
| `starboard.OPERATOR_BATCH_DELETE_LIMIT`  | The maximum number of config audit reports deleted by the operator when the plugin's config has changed | `10` | `Yes` |
| `starboard.OPERATOR_BATCH_DELETE_DELAY`  | The time to wait before deleting another batch of config audit reports | `10s` | `Yes` |
| `starboard.nodeselector`  | NodeSelectors to be added to the Starboard Operator Deployment | `false` | `No` |
| `kubeEnforcerAdvance.enable` | Advanced KubeEnforcer deployment | `false`  | `No`   |
| `kubeEnforcerAdvance.nodeID` | Envoy Node ID of the advance KE deployment    | `envoy` | `Yes - if kubeEnforcerAdvance.enable` |
| `kubeEnforcerAdvance.envoy.image.repository` | envoy image repository for KE advance deployment | `envoy` | `Yes` | 
| `kubeEnforcerAdvance.envoy.image.tag` | envoy image tag for KE advance deployment | `6.5` | `Yes` |
| `kubeEnforcerAdvance.envoy.image.pullPolicy` | envoy image pull policy for KE advance deployment | `Always` | `Yes - if kubeEnforcerAdvance.enable` |
| `kubeEnforcerAdvance.envoy.TLS.listener.enabled` | If require secure channel communication | `false` | `No` |
| `kubeEnforcerAdvance.envoy.TLS.listener.secretName` | certificates secret name | `nil` | `No` |
| `kubeEnforcerAdvance.envoy.TLS.listener.publicKey_fileName` | filename of the public key eg: aqua_envoy.crt | `nil`  |  `Yes` | <br /> `if gate.TLS.enabled is set to true` |
| `kubeEnforcerAdvance.envoy.TLS.listener.privateKey_fileName`   | filename of the private key eg: aqua_envoy.key | `nil`  |  | `Yes` <br /> `if gate.TLS.enabled is set to true` |
| `kubeEnforcerAdvance.envoy.TLS.listener.rootCA_fileName` |  filename of the rootCA, if using self-signed certificates eg: | rootCA.crt | `nil`  |  `No` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `kubeEnforcerAdvance.envoy.resources` | Envoy resources | `{}` | `Yes - if kubeEnforcerAdvance.enable` |
## Issues and feedback

If you encounter any problems or would like to give us feedback on this deployment, we encourage you to raise issues here on GitHub.
