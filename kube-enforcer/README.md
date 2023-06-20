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
      - [How to use cert-manager to configure TLS authentication between the KubeEnforcer and the API Server](#how-to-use-cert-manager-to-configure-tls-authentication-between-the-kubeenforcer-and-the-api-server)
  - [Deploy the Helm chart](#deploy-the-helm-chart)
    - [Deploy the KubeEnforcer with Starboard from a Helm private repository](#deploy-the-kubeenforcer-with-starboard-from-a-helm-private-repository)
  - [Configuration for discovery](#configuration-for-discovery)
  - [Configuration for performing kube-bench scans](#configuration-for-performing-kube-bench-scans)
  - [4. Configuring KubeEnforcer mTLS with Gateway/Envoy](#4-configuring-kubeenforcer-mtls-with-gatewayenvoy)
    - [Create Root CA (Done once)](#create-root-ca-done-once)
    - [Create the certificate key and certificate for kube-enforcer](#create-the-certificate-key-and-certificate-for-kube-enforcer)
    - [Create secrets with generated certs and change `values.yaml` as mentioned below](#create-secrets-with-generated-certs-and-change-valuesyaml-as-mentioned-below)
  - [Configuration for KubeEnforcer Advance deployment](#configuration-for-kubeenforcer-advance-deployment)
  - [Configuration for KubeEnforcer with cert-manager](#configuration-for-kubeenforcer-with-cert-manager)
  - [Integrate Kube-Enforcer with Hashicorp Vault to Load Token](#integrate-kube-enforcer-with-hashicorp-vault-to-load-token)
  - [Configurable Variables](#configurable-variables)
  - [Issues and feedback](#issues-and-feedback)

## Starboard

Starboard is an Aqua Security open-source tool that increases the effectiveness of Kubernetes security. For this reason, Starboard is deployed by default when you deploy KubeEnforcers.

> :exclamation: Starboard supported from Kubernetes v1.19.x. Starboard will not be deployed on earlier versions of Kubernetes

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
git clone -b 2022.4 https://github.com/aquasecurity/aqua-helm.git
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
#### How to use cert-manager to configure TLS authentication between the KubeEnforcer and the API Server
If you are planning to create and manage your self-signed certificates using [cert-manger](https://cert-manager.io/docs/),
You need set `webhook.certManager` to be `true` and add [annotations](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-certificate-resource)
```shell
webhooks:
  certManager: true
  annotations:
    cert-manager.io/inject-ca-from: < namespace >/< certsSecret.name >
```

## Deploy the Helm chart
### Deploy the KubeEnforcer with Starboard from a Helm private repository

1. Add Aqua Helm Repository

   ```shell
   helm repo add aqua-helm https://helm.aquasec.com
   helm repo update
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the Helm command. Then run one of the following commands to deploy the relevant services.

3. Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command

   ```shell
   helm search repo aqua-helm/kube-enforcer --versions
   ```

4. Choose **either** 4a **or** 4b:

   4a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:

   ```shell
   helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer
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

## 4. Configuring KubeEnforcer mTLS with Gateway/Envoy
  By default, deploying Aqua Enterprise configures TLS-based encrypted communication, using self-signed certificates, between Aqua components. If you want to use self-signed certificates to establish mTLS between kube-enforcer and gateway/envoy use the below instrictions to generate rootCA and component certificates

  > **Note:** **_mTLS communication and setup is only supported for self-hosted Aqua. It is not supported for Aqua ESE and Aqua SAAS_**

  ### Create Root CA (Done once)

  ***Important:*** The rootCA certificate used to generate the certificates for aqua server/gateway/envoy, use the same rootCA to generate kube-enforcer certificates.

  ### Create the certificate key and certificate for kube-enforcer

  **1. Create component key:**

  ```shell
  openssl genrsa -out aqua_kube-enforcer.key 2048
  ```

  **2. Create the signing (csr):**

  The certificate signing request is where you specify the details for the certificate you want to generate.
  This request will be processed by the owner of the Root key (you in this case since you create it earlier) to generate the certificate.

  ***Important:*** Please mind that while creating the signign request is important to specify the `Common Name` providing the IP address or domain name for the service, otherwise the certificate cannot be verified.

  - Generating aqua_kube-enforcer csr:
  ```shell
  openssl req -new -sha256 -key aqua_kube-enforcer.key \
    -subj "/C=US/ST=MA/O=aqua/CN=aqua-kube-enforcer" \
    -out aqua_kube-enforcer.csr
  ```

  **3. Verify the CSR content:**
  - verify the generated csr content(optional)
  ```shell
    openssl req -in aqua_kube-enforcer.csr -noout -text
  ```

  **4. Generate the certificate using the component csr and key along with the CA Root key:**

  ```shell
  openssl x509 -req -in aqua_kube-enforcer.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_kube-enforcer.crt -days 500 -sha256
  ```

  **5. Verify the certificate content:**
  - verify the generated certificate content(optional)
  ```shell
  openssl x509 -in aqua_kube-enforcer.crt -text -noout
  ```

### Create secrets with generated certs and change `values.yaml` as mentioned below
  1. Create Kubernetes secret for kube-enforcer using the generated SSL certificates.
  ```shell
    # Example:
    # Change < certificate filenames > respectively
      kubectl create secret generic ke-mtls-certs --from-file aqua_kube-enforcer.key --from-file aqua_kube-enforcer.crt --from-file rootCA.crt -n aqua
  ```
  2. Enable `TLS.enabled`  to `true` in values.yaml
  3. Add the certificates secret name `TLS.secretName` in values.yaml
  4. Add respective certificate file names to `TLS.publicKey_fileName`, `TLS.privateKey_fileName` and `TLS.rootCA_fileName`(Add rootCA if certs are self-signed) in values.yaml
  5. For enabling mTLS/TLS connection with self-signed or CA certificates between gateway and enforcer please setup mTLS/TLS config for gateway inserver chart as well [server chart](../server/README.md#configuring-mtlstls-for-aqua-server-and-aqua-gateway)
## Configuration for KubeEnforcer Advance deployment

   1. Change kubeEnforcerAdvance.enable to `true` in `values.yaml`
   2. (optional) By default envoy generates self-signed certs for secure communcations.
      1. Optionally, Generate TLS certificates signed by a public CA or Self-Signed CA

      ```shell
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

## Configuration for KubeEnforcer with cert-manager

   1. Create self signed `ClusterIssuer` and `Certificate` needed by Aqua:

   ```shell
   kubectl create namespace aqua

   kubectl apply -f - << EOF
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: selfsigned-cluster-issuer
   spec:
     selfSigned: {}
   EOF

   kubectl apply -f - << EOF
   apiVersion: cert-manager.io/v1
   kind: Certificate
   metadata:
     name: aqua-kube-enforcer-certs
     namespace: aqua
   spec:
     commonName: admission_ca
     secretName: aqua-kube-enforcer-certs
     issuerRef:
       name: selfsigned-cluster-issuer
       kind: ClusterIssuer
       group: cert-manager.io
     commonName: aqua-kube-enforcer.aqua.svc
     dnsNames:
     - aqua-kube-enforcer.aqua.svc
     - aqua-kube-enforcer.aqua.svc.cluster.local
     duration: 26280h
     renewBefore: 720h
   EOF
   ```

   2. Install kube-enforcer:

   ```shell
   helm upgrade --install --version "2022.4" --namespace aqua --values - kube-enforcer aqua-helm/kube-enforcer << EOF
   ...
   certsSecret:
     create: true
     name: aqua-kube-enforcer-certs
     serverCertificate: tls.crt
     serverKey: tls.key
   ...
   webhooks:
     certManager: true
   EOF
   ```

## Integrate Kube-Enforcer with Hashicorp Vault to Load Token
* Hashicorp Vault is a secrets management tools.
* Kube-enforcer charts supports to load token values from vault by vault-agent using annotations. To enable the Vault integration enable `vaultSecret.enable=true`, add vault secret filepath `vaultSecret.vaultFilepath= ""` and uncomment the `vaultAnnotations`.
* `vaultAnnotations` - Change the vault annotations according as per your vault setup, Annotations support both self-hosted and SaaS Vault setups.

## Configurable Variables

| Parameter                                                    | Description                                                                                                                                                                                                                                          | Default                                  | Mandatory                                                                                        |
|--------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|--------------------------------------------------------------------------------------------------|
| `global.imageCredentials.create`                             | Set to create new pull image secret                                                                                                                                                                                                                  | `true`                                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.name`                               | Your Docker pull image secret name                                                                                                                                                                                                                   | `aqua-registry-secret`                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.repositoryUriPrefix`                | repository uri prefix for dockerhub set `docker.io`                                                                                                                                                                                                  | `registry.aquasec.com`                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.registry`                           | set the registry url for dockerhub set `index.docker.io/v1/`                                                                                                                                                                                         | `registry.aquasec.com`                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.username`                           | Your Docker registry (Docker Hub, etc.) username                                                                                                                                                                                                     | `N/A`                                    | `Yes - New cluster`                                                                              |
| `global.imageCredentials.password`                           | Your Docker registry (Docker Hub, etc.) password                                                                                                                                                                                                     | `N/A`                                    | `Yes - New cluster`                                                                              |
| `serviceAccount.create`                                      | enable to create serviceaccount                                                                                                                                                                                                                      | `true`                                   | `Yes - New cluster`                                                                              |
| `serviceAccount.name`                                        | service acccount name                                                                                                                                                                                                                                | `aqua-kube-enforcer-sa`                  | `No`                                                                                             |
| `global.platform`                                            | Orchestration platform name (Allowed values are aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s)                                                                                                                                          | `unset`                                  | `YES`                                                                                            |
| `global.enforcer.enabled`                                    | Change to true to enable express mode and deploy aqua enforcer along with kube-enforcer                                                                                                                                                              | `false`                                  | `NO`                                                                                             |
| `global.gateway.address`                                     | Gateway host address. For Saas use the hostname containing `-gw` from your onboarding email.                                                                                                                                                         | `aqua-gateway-svc.aqua`                  | `Yes`                                                                                            |
| `global.gateway.port`                                        | Gateway host port. Far Saas use port 443                                                                                                                                                                                                             | `8443`                                   | `Yes`                                                                                            |
| `aqua_enable_cache`                                          | Set this to yes to enable caching for the KubeEnforcer; this can improve performance in clusters with high traffic                                                                                                                                   | `yes`                                    | `Yes`                                                                                            |
| `aqua_cache_expiration_period`                               | If caching is enabled, you can adjust the cache refresh time. This defaults to 60 seconds                                                                                                                                                            | `60`                                     | `Yes` </br> `if aqua_enable_cache enabled`                                                       |
| `ke_ReplicaCount`                                            | kube-enforcer replica count                                                                                                                                                                                                                          | `1`                                      | `No`                                                                                             |
| `image.repository`                                           | kube-enforcer docker image name to use                                                                                                                                                                                                               | `kube-enforcer`                          | `Yes`                                                                                            |
| `image.tag`                                                  | kube-enforcer image tag to use.                                                                                                                                                                                                                      | `2022.4`                                 | `Yes`                                                                                            |
| `image.pullPolicy`                                           | The kubernetes image pull policy.                                                                                                                                                                                                                    | `Always`                                 | `Yes`                                                                                            |
| `microEnforcerImage.repository`                              | Microenforcer docker image name                                                                                                                                                                                                                      | `microenforcer`                          | `YES`                                                                                            |
| `microEnforcerImage.tag`                                     | Microenforcer docker image tag                                                                                                                                                                                                                       | `2022.4`                                 | `YES`                                                                                            |
| `kubebenchImage.repository`                                  | KubeBench docker image name                                                                                                                                                                                                                          | `aquasec/kube-benc`                      | `YES`                                                                                            |
| `kubebenchImage.tag`                                         | KubeBench docker image tag                                                                                                                                                                                                                           | `v0.6.8`                                 | `YES`                                                                                            |
| `clusterName`                                                | Cluster name registered with Aqua in Infrastructure tab                                                                                                                                                                                              | `aqua-secure`                            | `No`                                                                                             |
| `enforcer_ds_name`                                           | AquaEnforcer DaemonSet name for KubEnforcer config map                                                                                                                                                                                               | ``                                       | `No`                                                                                             |
| `logicalName`                                                | This variable is used in conjunction with the KubeEnforcer group logical name to determine how the KubeEnforcer name will be displayed in the Aqua UI                                                                                                | `""`                                     | `No`                                                                                             |
| `logLevel`                                                   | Setting this might be helpful for problem determination. Acceptable values are DEBUG, INFO, WARN, and ERROR                                                                                                                                          | `""`                                     | `No`                                                                                             |
| `certsSecret.create`                                         | Set to create a new secret for TLS authentication with the Kubernetes api-server, Change to false if you're using existing server certificate secret                                                                                                 | `true`                                   | `Yes`                                                                                            |
| `certsSecret.annotations`                                    | Add annotations to secret created for KE                                                                                                                                                                                                             | ``                                       | `No`                                                                                             |
| `certsSecret.autoGenerate`                                   | Set to automaticly generate self-signed secret for TLS authentication with the Kubernetes api-server, Change to false if you're using existing server certificate secret                                                                             | `false`                                  | `No`                                                                                             |
| `certsSecret.name`                                           | Secret name for TLS authentication with the Kubernetes api-server, Change secret name if already exists with server/web public certificate                                                                                                           | `aqua-kube-enforcer-certs`               | `Yes`                                                                                            |
| `certsSecret.serverCertificate`                              | Public certificate for TLS authentication with the Kubernetes api-server, If certsSecret.create is enable to true, Add base64 value of the Public Certificate(server certificate) or add filename of certificate if it is loading from custom secret | `N/A`                                    | `Yes`                                                                                            |
| `certsSecret.serverKey`                                      | Certificate key for TLS authentication with the Kubernetes api-server, If certsSecret.create is enable to true, Add base64 value of the Private Key(server key) or add filename of key if it is loading from custom secret                           | `N/A`                                    | `Yes`                                                                                            |
| `dnsNdots`                                                   | Modifies ndots DNS configuration for the deployment                                                                                                                                                                                                  | `unset`                                  | `NO`                                                                                             |
| `vaultSecret.enable`                                         | Enable to true once you have secrets in vault and annotations are enabled to load enforcer token from hashicorp vault                                                                                                                                | `false`                                  | `No`                                                                                             |
| `vaultSecret.vaultFilepath`                                  | Change the path to "/vault/secrets/<filename>" as per the setup                                                                                                                                                                                      | `""`                                     | `No`                                                                                             |
| `aquaSecret.create`                                          | Aqua KubeEnforcer (KE) token secret creation                                                                                                                                                                                                         | `true`                                   | `Yes`                                                                                            |
| `aquaSecret.name`                                            | Aqua KubeEnforcer (KE) token secret name                                                                                                                                                                                                             | `aqua-kube-enforcer-token`               | `Yes`                                                                                            |
| `aquaSecret.kubeEnforcerToken`                               | Aqua KubeEnforcer (KE) token                                                                                                                                                                                                                         | `ke-token`                               | `Yes`                                                                                            |
| `clusterRole.name`                                           | KE cluster role name                                                                                                                                                                                                                                 | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `clusterRole.usingPodEnforcer`                               | Controls if the create, delete, and update verbs will be used.                                                                                                                                                                                       | `true`                                   | `Yes`                                                                                            |
| `clusterRoleBinding.name`                                    | KE cluster rolebinding name                                                                                                                                                                                                                          | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `role.name`                                                  | KE role name                                                                                                                                                                                                                                         | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `roleBinding.name`                                           | KE rolebinding name                                                                                                                                                                                                                                  | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `webhooks.certManager`                                       | Enable to true if using KE webhook certificates generated from kubernetes cert-manager                                                                                                                                                               | `false`                                  | `No`                                                                                             |
| `webhooks.caBundle`                                          | Root certificate for TLS authentication with the Kubernetes api-server, Add base64 value of the CA cert/Ca Bundle/RootCA Cert if certificates are not generated from cert-manager to webhooks.caBundle                                               | `N/A`                                    | `Yes` </br> `if webhooks.certManager is false`                                                   |
| `webhooks.failurePolicy`                                     | Webhook failure policy                                                                                                                                                                                                                               | `false`                                  | `Yes`                                                                                            |
| `webhooks.validatingWebhook.name`                            | KE validating webhook name                                                                                                                                                                                                                           | `kube-enforcer-admission-hook-config`    | `Yes`                                                                                            |
| `webhooks.validatingWebhook.timeout`                         | KE validating webhook timeout                                                                                                                                                                                                                        | `2`                                      | `Yes`                                                                                            |
| `webhooks.validatingWebhook.annotations`                     | KE validating webhook annotations                                                                                                                                                                                                                    | `{}`                                     | `No`                                                                                             |
| `webhooks.mutatingWebhook.name`                              | KE mutating webhook name                                                                                                                                                                                                                             | `kube-enforcer-me-injection-hook-config` | `Yes`                                                                                            |
| `webhooks.mutatingWebhook.timeout`                           | KE mutating webhook timeout                                                                                                                                                                                                                          | `2`                                      | `Yes`                                                                                            |
| `webhooks.mutatingWebhook.annotations`                       | KE mutating webhook annotations                                                                                                                                                                                                                      | `{}`                                     | `No`                                                                                             |
| `container_securityContext`                                  | KE container security context                                                                                                                                                                                                                        | `{}`                                     | `No`                                                                                             |
| `resources`                                                  | KE Resource requests and limits                                                                                                                                                                                                                      | `{}`                                     | `No`                                                                                             |
| `nodeSelector`                                               | Kubernetes node selector	                                                                                                                                                                                                                            | `{}`                                     | `No`                                                                                             |
| `tolerations`                                                | Kubernetes node tolerations	                                                                                                                                                                                                                         | `[]`                                     | `No`                                                                                             |
| `podAnnotations`                                             | Kubernetes pod annotations                                                                                                                                                                                                                           | `{}`                                     | `No`                                                                                             |
| `affinity`                                                   | Kubernetes node affinity                                                                                                                                                                                                                             | `{}`                                     | `No`                                                                                             |
| `priorityClass.create`                                       | If true priority class will be created                                                                                                                                                                                                               | `False`                                  | `NO`                                                                                             |
| `priorityClass.name`                                         | Define the name of priority class or default value will be used                                                                                                                                                                                      | ``                                       | `NO`                                                                                             |
| `priorityClass.preemptionPolicy`                             | Preemption policy for priority class                                                                                                                                                                                                                 | `PreemptLowerPriority`                   | `NO`                                                                                             |
| `priorityClass.value`                                        | `The integer value of the priority`                                                                                                                                                                                                                  | `1000000`                                | `NO`                                                                                             |
| `TLS.enabled`                                                | If require secure channel communication                                                                                                                                                                                                              | `false`                                  | `No`                                                                                             |
| `TLS.secretName`                                             | certificates secret name                                                                                                                                                                                                                             | `nil`                                    | `No`                                                                                             |
| `TLS.publicKey_fileName`                                     | filename of the public key eg: aqua_ke.crt                                                                                                                                                                                                           | `nil`                                    | `Yes` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.privateKey_fileName`                                    | filename of the private key eg: aqua_ke.key                                                                                                                                                                                                          | `nil`                                    | `Yes` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.rootCA_fileName`                                        | filename of the rootCA, if using self-signed certificates eg: rootCA.crt                                                                                                                                                                             | `nil`                                    | `No` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `starboard.enabled`                                          | Starboard deployment                                                                                                                                                                                                                                 | `true`                                   | `No`                                                                                             |
| `starboard.replicaCount`                                     | Starboard replica count                                                                                                                                                                                                                              | `1`                                      | `Yes`                                                                                            |
| `starboard.appName`                                          | Starboard application name                                                                                                                                                                                                                           | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.serviceAccount.name`                              | Starboard service account                                                                                                                                                                                                                            | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.clusterRoleBinding.name`                          | Starboard cluster binding name                                                                                                                                                                                                                       | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.clusterRole.name`                                 | Starboard cluster role name                                                                                                                                                                                                                          | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.image.repositoryUriPrefix`                        | Starboard image repository URI                                                                                                                                                                                                                       | `docker.io/aquasec`                      | `Yes`                                                                                            |
| `starboard.image.repository`                                 | Starboard image name                                                                                                                                                                                                                                 | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.tag`                                              | Starboard image tag                                                                                                                                                                                                                                  | `0.13.0`                                 | `Yes`                                                                                            |
| `starboard.pullPolicy`                                       | Starboard image pullPolicy                                                                                                                                                                                                                           | `Always`                                 | `Yes`                                                                                            |
| `starboard.OPERATOR_TARGET_NAMESPACES`                       | This determines the installation mode, which in turn determines the multi-tenancy support of the operator                                                                                                                                            | `(blank)`                                | `Yes` <br> `(blank string)=> ALLNAMESPACES, foo,bar.baz => specific NAMESPACES`                  |
| `starboard.OPERATOR_LOG_DEV_MODE`                            | The flag to use (or not use) development mode (more human-readable output, extra stack traces and logging information, etc.)                                                                                                                         | `false`                                  | `Yes`                                                                                            |
| `starboard.OPERATOR_CONCURRENT_SCAN_JOBS_LIMIT`              | The maximum number of scan jobs create by the operator                                                                                                                                                                                               | `10`                                     | `Yes`                                                                                            |
| `starboard.OPERATOR_SCAN_JOB_RETRY_AFTER`                    | The time to wait before retrying a failed scan job                                                                                                                                                                                                   | `30s`                                    | `Yes`                                                                                            |
| `starboard.OPERATOR_METRICS_BIND_ADDRESS`                    | The TCP address to bind to for serving Prometheus metrics. It can be set to 0 to disable the metrics serving.                                                                                                                                        | `:8080`                                  | `Yes`                                                                                            |
| `starboard.OPERATOR_HEALTH_PROBE_BIND_ADDRESS`               | The TCP address to bind to for serving health probes, i.e., the /healthz/ and /readyz/ endpoints                                                                                                                                                     | `:9090`                                  | `true`                                                                                           |
| `starboard.OPERATOR_CIS_KUBERNETES_BENCHMARK_ENABLED`        | The flag to enable CIS Kubernetes Benchmark scanning                                                                                                                                                                                                 | `false`                                  | `Yes, but should always remain false`                                                            |
| `starboard.OPERATOR_VULNERABILITY_SCANNER_ENABLED`           | The flag to enable vulnerability scanner                                                                                                                                                                                                             | `false`                                  | `Yes, but should always remain false`                                                            |
| `starboard.OPERATOR_BATCH_DELETE_LIMIT`                      | The maximum number of config audit reports deleted by the operator when the plugin's config has changed                                                                                                                                              | `10`                                     | `Yes`                                                                                            |
| `starboard.OPERATOR_BATCH_DELETE_DELAY`                      | The time to wait before deleting another batch of config audit reports                                                                                                                                                                               | `10s`                                    | `Yes`                                                                                            |
| `starboard.nodeselector`                                     | NodeSelectors to be added to the Starboard Operator Deployment                                                                                                                                                                                       | `false`                                  | `No`                                                                                             |
| `kubeEnforcerAdvance.enable`                                 | Advanced KubeEnforcer deployment                                                                                                                                                                                                                     | `false`                                  | `No`                                                                                             |
| `kubeEnforcerAdvance.nodeID`                                 | Envoy Node ID of the advance KE deployment                                                                                                                                                                                                           | `envoy`                                  | `Yes - if kubeEnforcerAdvance.enable`                                                            |
| `kubeEnforcerAdvance.envoy.image.repository`                 | envoy image repository for KE advance deployment                                                                                                                                                                                                     | `envoy`                                  | `Yes`                                                                                            |
| `kubeEnforcerAdvance.envoy.image.tag`                        | envoy image tag for KE advance deployment                                                                                                                                                                                                            | `2022.4`                                 | `Yes`                                                                                            |
| `kubeEnforcerAdvance.envoy.image.pullPolicy`                 | envoy image pull policy for KE advance deployment                                                                                                                                                                                                    | `Always`                                 | `Yes - if kubeEnforcerAdvance.enable`                                                            |
| `kubeEnforcerAdvance.envoy.TLS.listener.enabled`             | If require secure channel communication                                                                                                                                                                                                              | `false`                                  | `No`                                                                                             |
| `kubeEnforcerAdvance.envoy.TLS.listener.secretName`          | certificates secret name                                                                                                                                                                                                                             | `nil`                                    | `No`                                                                                             |
| `kubeEnforcerAdvance.envoy.TLS.listener.publicKey_fileName`  | filename of the public key eg: aqua_envoy.crt                                                                                                                                                                                                        | `nil`                                    | `Yes`  <br /> `if gate.TLS.enabled is set to true`                                               |
| `kubeEnforcerAdvance.envoy.TLS.listener.privateKey_fileName` | filename of the private key eg: aqua_envoy.key                                                                                                                                                                                                       | `nil`                                    | `Yes` <br /> `if gate.TLS.enabled is set to true`                                                |
| `kubeEnforcerAdvance.envoy.TLS.listener.rootCA_fileName`     | filename of the rootCA, if using self-signed certificates eg:                                                                                                                                                                                        | rootCA.crt                               | `No` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `kubeEnforcerAdvance.envoy.resources`                        | Envoy resources                                                                                                                                                                                                                                      | `{}`                                     | `Yes - if kubeEnforcerAdvance.enable`                                                            |
## Issues and feedback

If you encounter any problems or would like to give us feedback on this deployment, we encourage you to raise issues here on GitHub.
