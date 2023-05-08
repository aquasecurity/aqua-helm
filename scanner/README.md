<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Scanner Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Scanner CLI.

## Contents

- [Aqua Security Scanner Helm Chart](#aqua-security-scanner-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
    - [Scanner User Credentials](#scanner-user-credentials)
  - [Installing the Chart](#installing-the-chart)
    - [Installing Aqua Scanner from Github Repo](#installing-aqua-scanner-from-github-repo)
    - [Installing Aqua Scanner from Helm Private Repository](#installing-aqua-scanner-from-helm-private-repository)
    - [(Optional) Configure SSL communication with Aqua Server](#optional-configure-ssl-communication-with-aqua-server)
    - [(Optional) Configure mTLS communication with offline Aqua CyberCenter in air-gap environment](#optional-configure-mtls-communication-with-offline-aqua-cybercenter-in-air-gap-environment)
  - [Configurable Variables](#configurable-variables)
    - [Scanner](#scanner)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

### Scanner User Credentials

Before installing scanner chart the recommendation is to create user with scanning permissions, [Link to documentations](https://docs.aquasec.com/docs/add-scanners#section-add-a-scanner-user)

## Installing the Chart
Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository ([https://helm.aquasec.com](https://helm.aquasec.com))

### Installing Aqua Scanner from Helm Private Repository

* Add Aqua Helm Repository
```shell
helm repo add aqua-helm https://helm.aquasec.com
helm repo update
```

* Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command
```shell
helm search repo aqua-helm/scanner --versions
```

* Install Aqua

```shell
helm upgrade --install --namespace aqua scanner aqua-helm/scanner --set imageCredentials.username=<>,imageCredentials.password=<>,user=<>,password=<>,scannerToken=<>
```
### (Optional) Configure SSL communication with Aqua Server
To enable SSL communication from the Scanner to the Aqua Server. Perform these steps:
1. enable `serverSSL.enabled` to true in values.yaml or use `--set 'serverSSL.enabled=true'` for inline argument
2. You need to encode the certificate into base64 for ```server.crt```  using this command:

    ```bash
    cat <file-name> | base64 | tr -d '\n'
    ```
3. Provide the certificates previously obtained in the fields of the `serverSSL.serverSSLCert` in values.yaml or use `--set serverSSL.serverSSLCert=<cert base64 value>`

### (Optional) Configure mTLS communication with offline Aqua CyberCenter in air-gap environment
1. To establish mTLS with offline cybercenter, create secret using the below command
```SHELL
kubectl create secret generic aqua-grpc-scanner --from-file=<rootCA.crt> --from-file=<aqua_scanner.crt> --from-file=<aqua_scanner.key> -n aqua
```

2. Enable `cyberCenter.mtls.enabled` to true in `values.yaml`
3. Add previously created secret name `cyberCenter.mtls.secretName` in `values.yaml`
4. Add respective certificate file names to `cyberCenter.mtls.publicKey_fileName`, `cyberCenter.mtls.privateKey_fileName`, `cyberCenter.mtls.rootCA_fileName`(Add rootCA if certs are self-signed)

`AQUA_PRIVATE_KEY`, `AQUA_PUBLIC_KEY`, `AQUA_ROOT_CA`(if using self-signed certs), `OFFLINE_CC_MTLS_ENABLE` in [003_scanner_configmap.yaml](./003_scanner_configmap.yaml) and uncomment aqua-grpc-scanner certs vloumemount and volumes block from [004_scanner_deploy.yaml](./004_scanner_deploy.yaml) file before applying the kubectl commands.

Before installing scanner chart the recommendation is to create user with scanning permissions, [Link to documentations](https://docs.aquasec.com/docs/add-scanners#section-add-a-scanner-user)

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Scanner

Parameter | Description                                                                                                                                                 | Default                | Mandatory 
--------- |-------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------| ------- 
`imageCredentials.create` | enables to create image credentials                                                                      | `false`               | `NO`
`imageCredentials.name` | if `imageCredentials.create` is enabled sets imageCredentials name                                       |  | `NO`
`imageCredentials.registry` | the registry that the credentials will be created for. mandatory if `imageCredentials.create` is enabled | `registry.aquasec.com` | `NO`
`imageCredentials.username` | the username for the registry mandatory if `imageCredentials.create` is enabled                                                                           |  | `NO`
`imageCredentials.password` | the password for the registry mandatory if `imageCredentials.create` is enabled                                                                           |  | `NO`
`dockerSocket.mount` | boolean parameter if to mount docker socket                                                                                                                 | `unset`                | `NO`
`dockerSocket.path` | docker socket path                                                                                                                                          | `/var/run/docker.sock` | `NO` 
`platform` | Orchestration platform name for OpenShift deployment (use platform=openshift)                                                                               | `unset`                | `NO`
`directCC.enabled` | scanner talk to the cybercenter directly                                                                                                                    | `yes`                  | `NO` 
`serviceAccount.create` | Enable to create serviceaccount if not exist in the k8s                                                                                                     | `false`                | `NO`
`serviceAccount.name` | K8 service-account name either existing one or new name if create is enabled                                                                                | `aqua-sa`              | `YES`
`server.scheme` | scheme for server to connect                                                                                                                                | `http`                 | `NO`
`server.serviceName` | service name for server to connect                                                                                                                          | `aqua-console-svc`     | `YES` 
`server.port` | service port for server to connect                                                                                                                          | `8080`                 | `YES`
`serverSSl.enable` | To establish SSL communication with Aqua Server                                                                                                             | `false`                | `NO`
`serverSSl.createSecret` | Change to false if you're using existing server certificate secret                                                                                          | `true`                 | `YES` <br /> `if serverSSl.enable is set to true `
`serverSSL.secretName` | secret name for the SSL cert                                                                                                                                | `scanner-web-cert`     | `YES` <br /> `if serverSSl.enable is set to true `
`serverSSL.cert_file` | If serverSSL createSecret enable to true, add base64 value of the the server public certificate or add filename of certificate if loading from custom secret | `Nill`                 | `YES` <br /> `if serverSSl.enable is set to true `
`cyberCenter.mtls.enabled` | If require secure channel communication                                                                                                                     | `false`                | `NO`
`cyberCenter.mtls.secretName` | certificates secret name                                                                                                                                    | `nil`                  | `NO`
`cyberCenter.mtls.publicKey_fileName` | filename of the public key eg: aqua_scanner.crt                                                                                                             | `nil`                  |  `YES` <br /> `if cyberCenter.mtls.enabled is set to true`
`cyberCenter.mtls.privateKey_fileName`   | filename of the private key eg: aqua_scanner.key                                                                                                            | `nil`                  |  `YES` <br /> `if cyberCenter.mtls.enabled is set to true`
`cyberCenter.mtls.rootCA_fileName` | filename of the rootCA, if using self-signed certificates eg: rootCA.crt                                                                                    | `nil`                  |  `NO` <br /> `if using self-signed certificates for mTLS`
`image.repository` | the docker image name to use                                                                                                                                | `scanner`              | `YES` 
`image.tag` | The image tag to use.                                                                                                                                       | `2022.4`               | `YES`
`image.pullPolicy` | The kubernetes image pull policy.                                                                                                                           | `IfNotPresent`         | `NO` 
`user` | scanner username                                                                                                                                            | `unset`                | `YES` 
`password` | scanner password                                                                                                                                            | `unset`                | `YES`
`nameOverride` | scanner name                                                                                                                                       | `aqua-scanner`         | `NO`
`scannerUserSecret.enable` | change it to true for loading scanner user, scanner password from secret                                                                                    | `false`                | `YES` <br /> `If password is not declared`
`scannerUserSecret.secretName` | secret name for the scanner user, scanner password secret                                                                                                   | `null`                 | `YES` <br /> `If password is not declared`
`scannerUserSecret.userKey` | secret key of the scanner user                                                                                                                              | `null`                 | `YES` <br /> `If password is not declared`
`scannerUserSecret.passwordKey` | secret key of the scanner password                                                                                                                          | `null`                 | `YES` <br /> `If password is not declared`
`scannerTokenSecret.enable` | change it to true for loading the scanner token from secrets                                                                                                                        | `false`                | `YES` <br /> `If scannerToken and username and password are not declared`
`scannerTokenSecret.secretName` | secret name for the scanner token secret                                                                                                                       | `null`                 | `YES` <br /> `If scannerToken and username and password are not declared`
`scannerTokenSecret.tokenKey` | scanner token key name                                                                                                                         | `null`                 | `YES` <br /> `If scannerToken and username and password are not declared`
`replicaCount` | replica count                                                                                                                                               | `1`                    | `NO` 
`resources` | 	Resource requests and limits                                                                                                                               | `{}`                   | `NO` 
`nodeSelector` | 	Kubernetes node selector	                                                                                                                                  | `{}`                   | `NO`
`tolerations` | 	Kubernetes node tolerations	                                                                                                                               | `[]`                   | `NO`
`affinity` | 	Kubernetes node affinity                                                                                                                                   | `{}`                   | `NO`
`podAnnotations` | Kubernetes pod annotations                                                                                                                                  | `{}`                   | `NO`
`extraEnvironmentVars` | is a list of extra environment variables to set in the scanner deployments.                                                                                 | `{}`                   | `NO`
`extraSecretEnvironmentVars` | is a list of extra environment variables to set in the scanner deployments, these variables take value from existing Secret objects.                        | `[]`                   | `NO`
## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
