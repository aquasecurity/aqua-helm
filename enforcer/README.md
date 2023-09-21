<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Enforcer Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Enforcer

## Contents

- [Aqua Security Enforcer Helm Chart](#aqua-security-enforcer-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Enforcer from Helm Private Repository](#installing-aqua-enforcer-from-helm-private-repository)
  - [Configuring Enforcer mTLS with Gateway/Envoy](#configuring-enforcer-mtls-with-gatewayenvoy)
    - [Create Root CA (Done once)](#create-root-ca-done-once)
    - [Create the certificate and key for enforcer from existing rootca cert](#create-the-certificate-and-key-for-enforcer-from-existing-rootca-cert)
    - [Create secrets with generated certs and change `values.yaml` as mentioned below](#create-secrets-with-generated-certs-and-change-valuesyaml-as-mentioned-below)
  - [Guide how to create enforcer group in Kubernetes](#guide-how-to-create-enforcer-group-in-kubernetes)
  - [Integrate Aqua Enforcer with Hashicorp Vault to Load Token](#integrate-aqua-enforcer-with-hashicorp-vault-to-load-token)
  - [Configurable Variables](#configurable-variables)
    - [Enforcer](#enforcer)
  - [Special cases](#special-cases)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Enforcer from Helm Private Repository

* Add Aqua Helm Repository
```shell
helm repo add aqua-helm https://helm.aquasec.com
helm repo update
```

* Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command

```shell
helm search repo aqua-helm/enforcer --versions
```

* Install Aqua Enforcer
  * Install enforcer on linux nodes:

    ```shell
    helm upgrade --install --namespace aqua aqua-enforcer aqua-helm/enforcer --set global.imageCredentials.create=<>,global.imageCredentials.username=<>,global.imageCredentials.password=<>,global.platform=<>,enforcerToken=<aquasec-token>
    ```

      (or)

  * Install enforcer on combination of linux and windows nodes:
    ```shell
      helm upgrade --install --namespace aqua aqua-enforcer aqua-helm/enforcer --set global.imageCredentials.create=<>,global.imageCredentials.username=<>,global.imageCredentials.password=<>,global.platform=<>,enforcerToken=<aquasec-token>,windowsEnforcer.WinLinuxNodes.enable=true,windowsEnforcer.enforcerToken=<windows-enforcer-token>,windowsEnforcer.nodeSelector.key1=value1
    ```

      (or)

  * Install enforcer on windows nodes only:
    ```shell
      helm upgrade --install --namespace aqua aqua-enforcer aqua-helm/enforcer --set global.imageCredentials.create=<>,global.imageCredentials.username=<>,global.imageCredentials.password=<>,global.platform=<>,enforcerToken=<aquasec-token>,windowsEnforcer.allWinNodes.enable=true,windowsEnforcer.enforcerToken=<windows-enforcer-token>,windowsEnforcer.nodeSelector.key1=value1
    ```

## Configuring Enforcer mTLS with Gateway/Envoy
  By default, deploying Aqua Enterprise configures TLS-based encrypted communication, using self-signed certificates, between Aqua components. If you want to use self-signed certificates to establish mTLS between enforcer and gateway/envoy use the below instrictions to generate rootCA and component certificates

  > **Note:** **_mTLS communication and setup is only supported for self-hosted Aqua. It is not supported for Aqua ESE and Aqua SAAS_**

  ### Create Root CA (Done once)

  ***Important:*** The rootCA certificate used to generate the certificates for aqua server, gateway or envoy, use the same rootCA to generate enforcer certificates.
  ### Create the certificate and key for enforcer from existing rootca cert

  **1. Create component key:**

  ```shell
  openssl genrsa -out aqua_enforcer.key 2048
  ```

  **2. Create the signing (csr):**

  The certificate signing request is where you specify the details for the certificate you want to generate.
  This request will be processed by the owner of the Root key (you in this case since you create it earlier) to generate the certificate.

  ***Important:*** Please mind that while creating the signign request is important to specify the `Common Name` providing the IP address or domain name for the service, otherwise the certificate cannot be verified.

  - Generating aqua_enforcer csr:
  ```shell
  openssl req -new -sha256 -key aqua_enforcer.key \
    -subj "/C=US/ST=MA/O=aqua/CN=aqua-agent" \
    -out aqua_enforcer.csr
  ```

  **3. Verify the CSR content:**
  - verify the generated csr content(optional)
  ```shell
  openssl req -in aqua_enforcer.csr -noout -text
  ```

  **4. Generate the certificate using the component csr and key along with the CA Root key:**

  ```shell
  openssl x509 -req -in aqua_enforcer.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_enforcer.crt -days 500 -sha256
  ```

  **5. Verify the certificate content:**
  - verify the generated certificate content(optional)
  ```shell
  openssl x509 -in aqua_enforcer.crt -text -noout
  ```

  ### Create secrets with generated certs and change `values.yaml` as mentioned below
  1. Create Kubernetes secret for enforcer using the generated SSL certificates.
  ```shell
  # Example:
  # Change < certificate filenames > respectively
  kubectl create secret generic aqua-enforcer-certs --from-file aqua_enforcer.key --from-file aqua_enforcer.crt --from-file rootCA.crt -n aqua
  ```
  2. Enable `TLS.enabled`  to `true` in values.yaml
  3. Add the certificates secret name `TLS.secretName` in values.yaml
  4. Add respective certificate file names to `TLS.publicKey_fileName`, `TLS.privateKey_fileName` and `TLS.rootCA_fileName`(Add rootCA if certsare self-signed) in values.yaml
  5. For enabling mTLS/TLS connection with self-signed or CA certificates between gateway and enforcer please setup mTLS/TLS config for gateway inserver chart as well [server chart](../server/README.md#configuring-mtlstls-for-aqua-server-and-aqua-gateway)


## Guide how to create enforcer group in Kubernetes

Please login into Aqua Web UI then go to Enforcers section under Administrator tab to create a new enforcer group. Following are the required parameters to create a new group

| Parameter         | Description |
| ----------------- | ----------- |
| Enforcer Type     | Select **Aqua Enforcer** |
| Group Name        | Enter the name for the Enforcer Group; this name will appear in the list of Enforcer groups |
| OS Type           | Select the OS type for the host |
| Orchestrator      | Select the orchestrator for which you are creating the Enforcer Group |
| Container Runtime | Select the container runtime environment from the drop-down list |
| Aqua Gateway      | Select the Aqua Gateway(s) that the Enforcer will use to communicate with the Aqua Server. If there is only one Gateway, you need not select anything. |

For more details please visit [Link](https://docs.aquasec.com/docs/kubernetes#section-step-4-deploy-aqua-enforcers)

## Integrate Aqua Enforcer with Hashicorp Vault to Load Token
* Hashicorp Vault is a secrets management tools.
* Aqua Enforcer charts supports to load token values from vault by vault-agent using annotations. To enable the Vault integration enable `vaultSecret.enable=true`, add vault secret filepath `vaultSecret.vaultFilepath= ""` and uncomment the `vaultAnnotations`.
* `vaultAnnotations` - Change the vault annotations according as per your vault setup, Annotations support both self-hosted and SaaS Vault setups.

## Configurable Variables

### Enforcer

Parameter | Description      | Default| Mandatory
--------- |------------------|--------| ---------
`imageCredentials.create` | Set if to create new pull image secret| `false`| `YES - New cluster`
`imageCredentials.name` | Your Docker pull image secret name    | `aqua-registry-secret`| `YES - New cluster`
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io`| `registry.aquasec.com`| `YES - New cluster`
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/`| `registry.aquasec.com`| `YES - New cluster`
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username| `aqua-registry-secret`| `YES - New cluster`
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password| `unset`| `YES - New cluster`
`serviceAccount.create` | enable to create serviceaccount       | `false`| `YES - New cluster`
`serviceAccount.name` | service acccount name  | `aqua-sa`| `NO`
`clusterRole.roleRef` | cluster role reference name for cluster rolebinding| `unset`| `NO`
`platform` | Orchestration platform name (Allowed values are aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s)   | `unset`| `YES`
`vaultSecret.enable` | Enable to true once you have secrets in vault and annotations are enabled to load enforcer token from hashicorp vault | `false`| `No` |
`vaultSecret.vaultFilepath` | Change the path to "/vault/secrets/<filename>" as per the setup     | `""`   | `No` |
`enforcerToken` | enforcer token value   | `enforcer-token`      | `YES` if `enforcerTokenSecretName` is set to null
`expressMode` | Install enforcer in EXPRESS MODE or not| `false`| `YES`
`enforcerTokenSecretName` | enforcer token secret name if exists  | `null` | `NO`
`enforcerTokenSecretKey` | enforcer token secret key if exists   | `null` | `NO`
`logicalName` | Specify the Logical Name the Aqua Enforcer will register under. if not specify the name will be `spec.nodeName`     | `unset`| `NO`
`nodelName` | Specify the Node Name the Aqua Enforcer will register under. if not specify the name will be `spec.nodeName`  | `unset`| `NO`
`securityContext.privileged` | determines if any container in a pod can enable privileged mode.    | `false`| `NO`
`securityContext.capabilities` | Linux capabilities provide a finer grained breakdown of the privileges traditionally associated with the superuser. | `add {}` | `NO`
`podSecurityPolicy.create` | Enable Pod Security Policies with the required enforcer capabilities| `false`| `NO`
`podSecurityPolicy.privileged` | Enable privileged permissions to the Enforcer| `true` if podSecurityPolicy.create is `true` | `NO`
`global.gateway.address` | Gateway host address   | `aqua-gateway-svc`    | `YES`
`global.gateway.port` | Gateway host port| `8443` | `YES`
`priorityClass.create` | If true priority class will be created| `False`| `NO`
`priorityClass.name` | Define the name of priority class or default value will be used     | ``     | `NO`
`priorityClass.preemptionPolicy` | Preemption policy for priority class  | `PreemptLowerPriority`| `NO`
`priorityClass.value` | `The integer value of the priority`   | `1000000`| `NO`
`image.repository` | the docker image name to use | `enforcer`| `YES`
`image.tag` | The image tag to use.  | `2022.4` | `YES`
`image.pullPolicy` | The kubernetes image pull policy.     | `Always` | `NO`
`healthMonitor.enabled` | Enabling health monitoring for enforcer liveness and readiness      | `true` | `YES`
`resources` | 	Resource requests and limits| `{}`   | `NO`
`nodeSelector` | 	Kubernetes node selector	| `{}`   | `NO`
`tolerations` | 	Kubernetes node tolerations	| `[]`   | `NO`
`podAnnotations` | Kubernetes pod annotations| `{}`   | `NO`
`affinity` | 	Kubernetes node affinity| `{}`   | `NO`
`dnsNdots` | Modifies ndots DNS configuration for the deployment| `unset`    | `NO`
`TLS.enabled` | If require secure channel communication| `false`| `NO`
`TLS.secretName` | certificates secret name | `nil`  | `YES` <br /> `if TLS.enabled is set to true`
`TLS.publicKey_fileName` | filename of the public key eg: aqua_enforcer.crt| `nil`  |  `YES` <br /> `if TLS.enabled is set to true`
`TLS.privateKey_fileName`   | filename of the private key eg: aqua_enforcer.key  | `nil`  |  `YES` <br /> `if TLS.enabled is set to true`
`TLS.rootCA_fileName` | filename of the rootCA, if using self-signed certificates eg: rootCA.crt  | `nil`  |  `NO` <br /> `if TLS.enabled is set to true and using self-signed certificates for TLS/mTLS`
`TLS.aqua_verify_enforcer` | change it to "1" or "0" for enabling/disabling mTLS between enforcer and ay/envoy        | `0`    |  `YES` <br /> `if TLS.enabled is set to true`
`extraEnvironmentVars` | is a list of extra environment variables to set in the enforcer daemonset.| `{}`   | `NO`
`extraSecretEnvironmentVars` | is a list of extra environment variables to set in the scanner daemonset, these variables take value from existing Secret objects. | `[]`   | `NO`
`windowsEnforcer.allWinNodes.enable` | Enable to true, If All the nodes are windows os and it deploys only windows agents on all windows nodes | `false` | `NO`
`windowsEnforcer.WinLinuxNodes.enable` | Enable to true, If All the nodes are combination of windows os and linux, it deploys linux agents on linux nodes and  windows agents on windows nodes if nodeselector/tolerations provided according to the cluster| `false` | `NO`
`windowsEnforcer.enforcerToken` | windows enforcer token value   | `enforcer-token`      | `YES` if `enforcerTokenSecretName` is set to null
`windowsEnforcer.enforcerTokenSecretName` | windows enforcer token secret name if exists  | `null` | `NO`
`windowsEnforcer.enforcerTokenSecretKey` | windows enforcer token secret key if exists   | `null` | `NO`
`windowsEnforcer.nodeName` | Specify the windows Node Name the Aqua Enforcer will register under. if not specify the name will be `spec.nodeName`  | `unset`| `NO`
`windowsEnforcer.securityContext` | determines if any container in a pod can enable privileged mode.    | `false`| `NO`
`windowsEnforcer.priorityClass.create` | If true priority class will be created| `False`| `NO`
`windowsEnforcer.priorityClass.name` | Define the name of priority class or default value will be used     | ``     | `NO`
`windowsEnforcer.priorityClass.preemptionPolicy` | Preemption policy for priority class  | `PreemptLowerPriority`| `NO`
`windowsEnforcer.priorityClass.value` | `The integer value of the priority`   | `1000000`| `NO`
`windowsEnforcer.image.repository` | The windows agent docker image name to use | `enforcer`| `YES`
`windowsEnforcer.image.tag` | The windows agent image tag to use.  | `2022.4` | `YES`
`windowsEnforcer.image.pullPolicy` | The windows agent image pull policy.     | `Always` | `NO`
`windowsEnforcer.healthMonitor.enabled` | Enabling health monitoring for windows enforcer liveness and readiness      | `true` | `YES`
`windowsEnforcer.resources` | 	Resource requests and limits| `{}`   | `NO`
`windowsEnforcer.nodeSelector` | 	windows agent node selector	| `{}`   | `NO`
`windowsEnforcer.tolerations` | 	windows agent node tolerations of windows agent	| `[]`   | `NO`
`windowsEnforcer.podAnnotations` | windows agent pod annotations of windows agent | `{}`   | `NO`
`windowsEnforcer.affinity` | 	windows agent node affinity of windows agent | `{}`   | `NO`
`windowsEnforcer.dnsNdots` | Modifies ndots DNS configuration for the windows agent deployment| `unset`    | `NO`
`windowsEnforcer.TLS.enabled` | If require secure channel communication| `false`| `NO`
`windowsEnforcer.TLS.secretName` | certificates secret name | `nil`  | `YES` <br /> `if TLS.enabled is set to true`
`windowsEnforcer.TLS.publicKey_fileName` | filename of the public key eg: aqua_enforcer.crt| `nil`  |  `YES` <br /> `if TLS.enabled is set to true`
`windowsEnforcer.TLS.privateKey_fileName`   | filename of the private key eg: aqua_enforcer.key  | `nil`  |  `YES` <br /> `if TLS.enabled is set to true`
`windowsEnforcer.TLS.rootCA_fileName` | filename of the rootCA, if using self-signed certificates eg: rootCA.crt  | `nil`  |  `NO` <br /> `if TLS.enabled is set to true and using self-signed certificates for TLS/mTLS`
`windowsEnforcer.TLS.aqua_verify_enforcer` | change it to "1" or "0" for enabling/disabling mTLS between enforcer and ay/envoy        | `0`    |  `YES` <br /> `if TLS.enabled is set to true`
`windowsEnforcer.extraEnvironmentVars` | is a list of extra environment variables to set in the enforcer daemonset.| `{}`   | `NO`
`windowsEnforcer.extraSecretEnvironmentVars` | is a list of extra environment variables to set in the scanner daemonset, these variables take value from existing Secret objects. | `[]`   | `NO`

> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true, set the username and password for the registry and `serviceAccount.create` is false and if you're environment is new or not having aqua-sa serviceaccount please update it to true.

## Special cases
* For EKS cluster with the Bottlerocket OS add below section under `securityContext`
```yaml
seLinuxOptions:
  user: system_u
  role: system_r
  type: super_t
  level: s0
```
## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
