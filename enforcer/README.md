<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Enforcer Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Enforcer

## Contents

- [Aqua Security Enforcer Helm Chart](#aqua-security-enforcer-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Chart](#installing-the-chart)
  - [Configurable Variables](#configurable-variables)
    - [Enforcer](#enforcer)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Enforcer from Github Repo

* Clone the GitHub repository with the charts

```bash
git clone -b 6.2 https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

* Install Aqua Enforcer

```bash
helm upgrade --install --namespace aqua aqua-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,enforcerToken=<aquasec-token>
```

### Installing Aqua Enforcer from Helm Private Repository

* Add Aqua Helm Repository
```bash
$ helm repo add aqua-helm https://helm.aquasec.com
```

* Install Aqua Enforcer

```bash
helm upgrade --install --namespace aqua aqua-enforcer aqua-helm/enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,enforcerToken=<aquasec-token> --version <>
```


## Advanced Configuration

In order to support L7 / gRPC communication between enforcer and envoy it is recommended to follow the detailed steps to enable and deploy a enforcer.

   1. The Enforcer should connect to the Envoy service (aqua-lb:443) and verify its certificate. If Envoy’s certificate is signed by a public provider (e.g., Let’s Encrypt), the Enforcer will be able to verify the certificate without being given a root certificate. Otherwise, Envoy’s root certificate should be accessible to the Enforcer from a ConfigMap that is mounted at /etc/ssl/custom-certificates

      ```yaml
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

   2. Create enforcer agent cert secret

      ```bash
      # Please be notified that tls.key and tls.crt in the below command are default filenames
      # and same as mydomain.com.key and mydomain.com.crt in the above openssl commands
      # If tls.crt and tls.key filenames are changed then it should be changed in values.yaml envoy config
      $ kubectl create secret generic aqua-enforcer-agent --from-file agent.crt --from-file agent.key --from-file rootCA.crt -n aqua
      ```

   3. Edit values.yaml file to include above secret name at `certsSecretName` and uncomment the extra variables 

   4. Also set envoyCerts.enabled to `true`


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

Parameter | Description | Default| Mandatory 
--------- | ----------- | ------- | ------- 
multi_cluster` | Set if to create new service account | `false` | `YES - New cluster`
`imageCredentials.create` | Set if to create new pull image secret | `false`| `YES - New cluster` 
`imageCredentials.name` | Your Docker pull image secret name | `aqua-registry-secret`| `YES - New cluster` 
`imageCredentials.repositoryUriPrefix` | repository uri prefix for dockerhub set `docker.io` | `registry.aquasec.com`| `YES - New cluster` 
`imageCredentials.registry` | set the registry url for dockerhub set `index.docker.io/v1/` | `registry.aquasec.com`| `YES - New cluster` 
`imageCredentials.username` | Your Docker registry (DockerHub, etc.) username | `aqua-registry-secret`| `YES - New cluster` 
`imageCredentials.password` | Your Docker registry (DockerHub, etc.) password | `unset`| `YES - New cluster` 
`enforcerToken` | enforcer token value | `""`| `YES` 
`enforcerTokenSecretName` | enforcer token secret name if exists | `null`| `NO` 
`enforcerTokenSecretKey` | enforcer token secret key if exists | `null`| `NO` 
`enforcerLogicalName` | Specify the Logical Name the Aqua Enforcer will register under. if not specify the name will be `<Helm Release>-helm` | `unset`| `NO` 
`securityContext.privileged` | determines if any container in a pod can enable privileged mode. | `true`| `NO` 
`securityContext.capabilities` | Linux capabilities provide a finer grained breakdown of the privileges traditionally associated with the superuser. | `unset`| `NO` 
`hostRunPath` |	for changing host run path for example for pks need to change to /var/vcap/sys/run/docker	| `unset`| `NO` 
`gate.host` | gateway host | `aqua-gateway-svc`| `YES` 
`gate.port` | gateway port | `8443`| `YES` 
`image.repository` | the docker image name to use | `enforcer`| `YES` 
`image.tag` | The image tag to use. | `6.2.preview5`| `YES` 
`image.pullPolicy` | The kubernetes image pull policy. | `IfNotPresent`| `NO` 
`resources` |	Resource requests and limits | `{}`| `NO` 
`nodeSelector` |	Kubernetes node selector	| `{}`| `NO` 
`tolerations` |	Kubernetes node tolerations	| `[]`| `NO` 
`affinity` |	Kubernetes node affinity | `{}`| `NO` 
`extraEnvironmentVars` | is a list of extra environment variables to set in the enforcer daemonset. | `{}`| `NO`
`extraSecretEnvironmentVars` | is a list of extra environment variables to set in the scanner daemonset, these variables take value from existing Secret objects. | `[]`| `NO`
`envoy.enabled` | enabled envoy deployment to support in envoy deployment. | `false`| `NO` 
`envoy.configMap` | config map name with aqua certs for agent. | ``| `NO` 

> Note: that `imageCredentials.create` is false and if you need to create image pull secret please update to true. and set the username and password for the registry.

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
