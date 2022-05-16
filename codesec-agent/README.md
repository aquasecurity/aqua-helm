# Argon Broker Deployment

## Prerequisite
- obtain Argon Token
- url and credentials for Bitbucket server 

## Installation / Upgrade
```
helm repo add argon https://helm.aquasec.com
helm repo update
HELM_RELEASE=argon-broker
helm upgrade -i $HELM_RELEASE argon/argon-broker --namespace argon --create-namespace \
   [ --set key1=val1,key2=val2 ] [ -f my-values.yaml ] [ <helm parameters> ] 
```

## Basic helm values
- Setting <server-type>.url deploys Argon Broker for that server. Example: `--set bitbucket.url=https://bitbucket.example.com --set gitlab.url=https://gitlab.example.com` will deploy two Argon Brokers for Bitbucket and Gitlab
- You must specify at least one <server-type>.url, otherwise nothing will be deployed

| Value Key | Description | Mandatory |
| --- | --- | --- |
| **global** |
| global.argonServer | Address of Argong Broker Server, default https://app-broker.argon.io | yes |
| global.token | Argon Token | yes |
| global.envs  | global envs for all pods like http_proxy | no |
| global.registry | registry to pull images from (default docker.io) | no |
| **bitbucket** |
| bitbucket.url | Bitbucket URL, ex. https://bitbucket.example.com:7990 | yes, if Bitbucket Broker enabled |
| bitbucket.username | Bitbucket username | yes, if Bitbucket Broker enabled |
| bitbucket.password | Bitbucket password | yes, if Bitbucket Broker enabled |
| **gitlab** |
| gitlab.url | Gitlab URL, ex. https://gitlab.example.com | yes, if Gitlab Broker enabled |
| gitlab.token | Gitlab token| yes, if Gitlab Broker enabled |
| **jfrog** |
| jfrog.url | Jfrog Artifactory URL, ex. https://jfrog.example.com | yes, if Jfrog Broker enabled |
| jfrog.token | Jfrog Artifactory token | yes, if Jfrog Broker enabled |
| **azure devops** |
| azure.url | Azure Devops URL, ex. https://azure.example.com | yes, if Azure Devops Broker enabled |
| azure.token | Azure Devops token | yes, if Azure Devops enabled |
| **jenkins** |
| jenkins.url | Jenkins URL, ex. https://jenkins.example.com | yes, if Jenkins Broker enabled |
| jenkins.token | Jenkins token | yes, if Jenkins Broker enabled |
| **nexus** |
| nexus.url | Nexus URL, ex. https://nexus.example.com | yes, if Nexus Broker enabled |
| nexus.token | Nexus token | yes, if Nexus Broker enabled |
| **jira** |
| jira.url | Jira URL, ex. https://jira.example.com | yes, if Jira Broker enabled 
| jira.token | Jira token | yes, if Jira enabled |
## Additional helm values
In addition to the values above it is possible to specify:
- custom ca and client ssl certificates for servers
- kubernetes scheduler values - resources, nodeSelector, affinity, tolleration  

refer to [values.yaml](values.yaml) and [templates](templates) 

## Example
- add helm repository
```
helm repo add argon https://helm.aquasec.com
```
### Simple Connect to Bitbucket server
```
helm upgrade -i argon-broker argon/argon-broker --namespace argon --create-namespace \
  --set global.token=***** \
  --set bitbucket.url="https://bitbucket.example.com" \
  --set bitbucket.username=bitbucket \
  --set bitbucket.password=******
```

### Install multiple releases per repo provider
Install different helm releases for each repo provider
#### bitbucket
helm upgrade -i argon-broker-bitbucket argon/argon-broker --namespace argon --create-namespace \
  --set global.token=***** \
  --set bitbucket.url="https://bitbucket.example.com" \
  --set bitbucket.username=bitbucket \
  --set bitbucket.password=******

#### jfrog
helm upgrade -i argon-broker-jfrog argon/argon-broker --namespace argon --create-namespace \
  --set global.token=***** \
  --set jfrog.url="https://jfrog.example.com" \
  --set jfrog.token=*****



### Advanced run with HTTP_PROXY and ssl certificates
- create values file `my-env-values.yaml`:
```yaml
global:
  argonServer: https://app-broker.argon.io
  token: ***** 
  envs:
    http_proxy: proxy.example.com:3128
    https_proxy: proxy.example.com:3128
    no_proxy: .example.com

gitlab:
  url: https://gitlab.example.com
  token: *****
  ssl:
    ca: -|
      -----BEGIN CERTIFICATE-----
      ***** ca-cert-content
      -----END CERTIFICATE
    cert: -|
      -----BEGIN CERTIFICATE-----
      ***** client-cert
      -----END CERTIFICATE-----
    key: -|
      -----BEGIN RSA PRIVATE KEY-----
      ***** private-key-content
      -----END RSA PRIVATE KEY-----
```
- run helm
```
helm upgrade -i argon-broker argon/argon-broker --namespace argon --create-namespace -f my-env-values.yaml
```

