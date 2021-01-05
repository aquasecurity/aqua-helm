<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Kube Enforcer Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Enforcer

## Contents

- [Aqua Security Kube Enforcer Helm Chart](#aqua-security-kube-enforcer-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
    - [Clone the GitHub repository with the charts](#clone-the-github-repository-with-the-charts)
    - [Configure TLS Authentication between KubeEnforcer & API Server](#configure-tls-authentication-between-kubeenforcer--api-server)
  - [Installing the Chart](#installing-the-chart)
  - [ClusterRole](#clusterrole)
  - [Role](#role)
  - [Configurable Variables](#configurable-variables)
    - [KubeEnforcer](#kubeenforcer)
  - [Issues and feedback](#issues-and-feedback)

## Prerequisites

### Container Registry Credentials

[Link](../docs/imagepullsecret.md)

### Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

### Configure TLS Authentication between KubeEnforcer & API Server

You need to enable TLS authentication from the API Server to the Kube-Enforcer. Perform these steps:

Create TLS certificates which is signed by the local CA certificate. We will pass these certificates with helm command to enbale TLS authentication between kube-enforcer & API-Server to receive events from validatingwebhookconfiguration for image assurance functionality.

You can generate these certificates by executing the script:

```
./kube-enforcer/gen-certs.sh
```

You can also use your own certificates without generating new ones for TLS authentication all we need is root CA certificate, certificate signed by CA and certificate key.

Optionally you can configure the certificates generated from the above script in ```values.yaml``` file

You need to encode the certificates into based64 for ```ca.crt```, ```server.crt``` and ```server.key``` using the below cmd

```
cat <file-name> | base64 | tr -d '\n'
```

Provide the above obtained certificates in the below fields of ```values.yaml``` file.

```
certsSecret:
  name: aqua-kube-enforcer-certs
  serverCertificate: "<server.crt>"
  serverKey: "<server.key>"

webhooks:
  caBundle: "<ca.crt>"
```
or you can provide these certificates in base64 encoded format as flags.
  a. certsSecret.serverCertificate="<base64_encoded_server.crt>"
  b. certsSecret.serverKey="<base64_encoded_server.key>"
  c. webhooks.caBundle="<base64_encoded_ca.crt>"

## Installing the Chart

1. Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/kube-enforcer-helm.git
```

***Optional*** Update the Helm charts values.yaml file with your environment's custom values, registry secret, aqua console credentials & TLS certificates. This eliminates the need to pass the parameters to the helm command. Then run one of the commands below to install the relevant services.

2. If you are deploying KubeEnforcer to a new cluster (Multi-Cluster Scenario) then you need to create `aqua` namespace
```bash
$ kubectl create namespace aqua
```
3. Install KubeEnforcer
   
    1. To the same cluster where Aqua Server is deployed
    
         1. ```shell
              helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer
              ```
    
    2. To a new cluster to support multi cluster deployment
    
         1. ```shell
              helm upgrade --install --namespace aqua kube-enforcer ./kube-enforcer --set evs.gatewayAddress="<Aqua_Remote_Gateway_IP/URL>",imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>
              ```
    

Optional flags:

```
--namespace                              default to aqua
--aquaSecret.kubeEnforcerToken           default to "" you can find the KubeEnforcer token from aqua csp under enforcers tab in default/custom KubeEnforcer group or you can manually approve KubeEnforcer authentication from aqua CSP under default/custom KubeEnforcer group in enforcers tab.
```

## ClusterRole

KubeEnforcer needs a dedicated clusterrole with **get, list, watch** permissions on **pods, secrets, nodes, namespaces, deployments, replicasets, replicationcontrollers, statefulsets, daemonsets, jobs, cronjobs, clusterroles, clusterrolebindings, componentstatuses** to perform discovery on the cluster. 

## Role

KubeEnforcer needs a dedicated role in **aqua** namespace with **get, list, watch** permissions on **pods/log** and **create, delete** permissions on **jobs** to perform kube-bench scans in the cluster.



## Configurable Variables

### KubeEnforcer

| Parameter                         | Description                          | Default                                                                      | Mandatory                                                             |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 | `YES - New cluster`                                    |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-registry-secret`                                                                   | `YES - New cluster`                                         |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   | `YES - New cluster`                                           |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A` | `YES - New cluster` |
| `aquaSecret.kubeEnforcerToken`                           | Aqua KubeEnforcer token    | `N/A`| `YES` |
| `priorityClassName`                           | Kubernetes pod priority class.    | `N/A`| `NO` |
| `certsSecret.serverCertificate`                           | Certificate for TLS authentication with Kubernetes api-server    | `N/A`| `YES` |
| `certsSecret.serverKey`                           | Certificate key for TLS authentication with Kubernetes api-server    | `N/A`| `YES` |
| `webhooks.caBundle`                           | Root Certificate for TLS authentication with Kubernetes api-server   | `N/A`  | `YES` |
| `envs.gatewayAddress`                          | Gateway host Address    | `aqua-gateway-svc:8443`                                                     | `YES`                                                |


## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
