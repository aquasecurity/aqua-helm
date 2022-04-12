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
  - [Configurable Variables](#configurable-variables)
    - [Enforcer](#enforcer)
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

```shell
helm upgrade --install --namespace aqua aqua-enforcer aqua-helm/enforcer --set imageCredentials.create=<>,imageCredentials.username=<>,imageCredentials.password=<>,platform=<>,enforcerToken=<aquasec-token>
```


## Configuring Enforcer mTLS with Gateway/Envoy
  By default, deploying Aqua Enterprise configures TLS-based encrypted communication, using self-signed certificates, between Aqua components. If you want to use self-signed certificates to establish mTLS between enforcer and gateway/envoy use the below instrictions to generate rootCA and component certificates


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

| Parameter         | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| Enforcer Type     | Select **Aqua Enforcer**                                     |
| Group Name        | Enter the name for the Enforcer Group; this name will appear in the list of Enforcer groups |
| OS Type           | Select the OS type for the host                              |
| Orchestrator      | Select the orchestrator for which you are creating the Enforcer Group |
| Container Runtime | Select the container runtime environment from the drop-down list |
| Aqua Gateway      | Select the Aqua Gateway(s) that the Enforcer will use to communicate with the Aqua Server. If there is only one Gateway, you need not select anything. |

For more details please visit [Link](https://docs.aquasec.com/docs/kubernetes#section-step-4-deploy-aqua-enforcers)

## Configurable Variables

### Enforcer
| Parameter                              | Description                                                                                                                       | Default| Mandatory
|----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------| ------- | ------- 
| `imageCredentials.create`              | Set if to create new pull image secret                                                                                            | `false`| `YES - New cluster`
| `imageCredentials.name`                | Your Docker pull image secret name                                                                                                | `aqua-registry-secret`| `YES - New cluster`
| `imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io`                                                                               | `registry.aquasec.com`| `YES - New cluster`
| `imageCredentials.registry`            | set the registry url for dockerhub set `index.docker.io/v1/`                                                                      | `registry.aquasec.com`| `YES - New cluster`
| `imageCredentials.username`            | Your Docker registry (DockerHub, etc.) username                                                                                   | `aqua-registry-secret`| `YES - New cluster`
| `imageCredentials.password`            | Your Docker registry (DockerHub, etc.) password                                                                                   | `unset`| `YES - New cluster`
| `serviceAccount.create`                | enable to create serviceaccount                                                                                                   | `false` | `YES - New cluster`
| `serviceAccount.name`                  | service acccount name                                                                                                             | `aqua-sa` | `NO`
| `clusterRole.roleRef`                  | cluster role reference name for cluster rolebinding                                                                               | `unset` | `NO`
| `platform`                             | Orchestration platform name (Allowed values are aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s)                       | `unset` | `YES`
| `enforcerToken`                        | enforcer token value                                                                                                              | `enforcer-token`| `YES`
| `enforcerTokenSecretName`              | enforcer token secret name if exists                                                                                              | `null`| `NO`
| `enforcerTokenSecretKey`               | enforcer token secret key if exists                                                                                               | `null`| `NO`
| `logicalName`                          | Specify the Logical Name the Aqua Enforcer will register under. if not specify the name will be `spec.nodeName`                   | `unset`| `NO`
| `nodelName`                            | Specify the Node Name the Aqua Enforcer will register under. if not specify the name will be `spec.nodeName`                      | `unset`| `NO`
| `securityContext.privileged`           | determines if any container in a pod can enable privileged mode.                                                                  | `false`| `NO`
| `securityContext.capabilities`         | Linux capabilities provide a finer grained breakdown of the privileges traditionally associated with the superuser.               | `add {}`| `NO`
| `hostRunPath`                          | for changing host run path for example for pks need to change to /var/vcap/sys/run/docker	                                       | `unset`| `NO`
| `gate.host`                            | gateway host                                                                                                                      | `aqua-gateway-svc`| `YES`
| `gate.port`                            | gateway port                                                                                                                      | `8443`| `YES`
| `priorityClass.create`                 | If true priority class will be created                                                                                            | `False` | `NO`
| `priorityClass.name`                   | Define the name of priority class or default value will be used                                                                   | `` | `NO`
| `priorityClass.preemptionPolicy`       | Preemption policy for priority class                                                                                              | `PreemptLowerPriority` | `NO`
| `priorityClass.value`                  | `The integer value of the priority`                                                                                               | `1000000` | `NO`
| `image.repository`                     | the docker image name to use                                                                                                      | `enforcer`| `YES`
| `image.tag`                            | The image tag to use.                                                                                                             | `6.5`| `YES`
| `image.pullPolicy`                     | The kubernetes image pull policy.                                                                                                 | `Always`| `NO`
| `healthMonitor.enabled`                | Enabling health monitoring for enforcer liveness and readiness                                                                    | `true` | `YES`
| `resources`                            | Resource requests and limits                                                                                                     | `{}`| `NO`
| `nodeSelector`                         | Kubernetes node selector	                                                                                                        | `{}`| `NO`
| `tolerations`                          | Kubernetes node tolerations	                                                                                                     | `[]`| `NO`
| `podAnnotations`                       | Kubernetes pod annotations                                                                                                        | `{}` | `NO`
| `affinity`                             | Kubernetes node affinity                                                                                                          | `{}`| `NO`
| `podLabels`                            | Configure pod labels                                                                                                              | `{}`| `NO`
| `TLS.enabled`                          | If require secure channel communication                                                                                           | `false` | `NO`
| `TLS.secretName`                       | certificates secret name                                                                                                          | `nil` | `YES` <br /> `if TLS.enabled is set to true`
| `TLS.publicKey_fileName`               | filename of the public key eg: aqua_enforcer.crt                                                                                  | `nil`  |  `YES` <br /> `if TLS.enabled is set to true`
| `TLS.privateKey_fileName`              | filename of the private key eg: aqua_enforcer.key                                                                                 | `nil`  |  `YES` <br /> `if TLS.enabled is set to true`
| `TLS.rootCA_fileName`                  | filename of the rootCA, if using self-signed certificates eg: rootCA.crt                                                          | `nil`  |  `NO` <br /> `if TLS.enabled is set to true and using self-signed certificates for TLS/mTLS`
| `TLS.aqua_verify_enforcer`             | change it to "1" or "0" for enabling/disabling mTLS between enforcer and ay/envoy                                                 | `0`  |  `YES` <br /> `if TLS.enabled is set to true`
| `extraEnvironmentVars`                 | is a list of extra environment variables to set in the enforcer daemonset.                                                        | `{}`| `NO`
| `extraSecretEnvironmentVars`           | is a list of extra environment variables to set in the scanner daemonset, these variables take value from existing Secret objects. | `[]`| `NO`


> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true, set the username and password for the registry and `serviceAccount.create` is false and if you're environment is new or not having aqua-sa serviceaccount please update it to true.

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
