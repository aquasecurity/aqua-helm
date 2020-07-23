# Aqua Kube Enforcer Helm Chart

Contents:
- [Aqua Kube Enforcer Helm Chart](#aqua-kube-enforcer-helm-chart)
  - [Configure TLS Authentication to the API Server](#optional-configure-tls-authentication-to-the-api-server)
  - [Deploy The Helm Chart](#deploy-the-helm-chart)
    - [Installing the Chart](#installing-the-chart)
  - [Issues and feedback](#issues-and-feedback)

## Configure TLS Authentication between KubeEnforcer & API Server

You need to enable TLS authentication from the API Server to the Kube-Enforcer. Perform these steps:

1. Run these commands to create TLS certificates which is signed by the local CA certificate. We will pass these certificates with helm command to enbale TLS authentication between kube-enforcer & API-Server to receive events from validatingwebhookconfiguration for image assurance functionality.

```shell
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
    
cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF
    
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=aqua-kube-enforcer.aqua.svc" -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf
```

You also also use your own certificates without generating new ones for TLS authentication all we need is root CA certificate, certificate signed by CA and certificate key.

## Deploy The Helm Chart

**(Optional)** create the secret:

```bash
kubectl create secret docker-registry aqua-image-pull-secret --docker-server="registry.aquasec.com" --namespace aqua --docker-username="jg@example.com" --docker-password="Truckin" --docker-email="jg@example.com"
```

If you are creating the registry secret by following the above step. Change the ```imageCredentials.create``` to ```false``` in ```values.yaml``` file this makes sure helm chart will not attempt to create registry secret again and update the ```imageCredentials.name``` with the name of the secret created.

### Installing the Chart

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/kube-enforcer-helm.git
```

***Optional*** Update the Helm charts values.yaml file with your environment's custom values, registry secret, aqua console credentials & TLS certificates. This eliminates the need to pass the parameters to the helm command. Then run one of the commands below to install the relevant services.

```bash
helm install <release_name> kube-enforcer --set imageCredentials.username=<registry-username>,imageCredentials.password=<registry-password>,certsSecret.serverCertificate="$(cat server.crt)",certsSecret.serverKey="$(cat server.key)",validatingWebhook.caBundle="$(cat ca.crt)"
```

Optional flags:

```
--namespace                              default to aqua
--aquaSecret.kubeEnforcerToken           default to "" you can find the KubeEnforcer token from aqua csp under enforcers tab in default/custom KubeEnforcer group or you can manually approve KubeEnforcer authentication from aqua CSP under default/custom KubeEnforcer group in enforcers tab. 
```

### Customize your configuration

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`
| `aquaSecret.kubeEnforcerToken`                           | Aqua KubeEnforcer token    | `N/A`
| `certsSecret.serverCertificate`                           | Certificate for TLS authentication with Kubernetes api-server    | `N/A`
| `certsSecret.serverKey`                           | Certificate key for TLS authentication with Kubernetes api-server    | `N/A`
| `validatingWebhook.caBundle`                           | Root Certificate for TLS authentication with Kubernetes api-server   | `N/A`                                                 |
| `envs.gatewayAddress`                          | Gateway host Address    | `aqua-gateway:8443`                                                     |


## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
