<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Codesec Agent Helm Chart

_Protect your Software Supply Chain._

> Using this helm chart, you can integrate code security into your organization

## Contents

- [Aqua Security Codesec Agent Helm Chart](#aqua-security-codesec-agent-helm-chart)
  - [Contents](#contents)
  - [Prerequisites and limitations](#prerequisites-and-limitations)
  - [Installing the chart](#installing-the-chart)
    - [Installing Codesec Agents from Helm Private Repository](#installing-codesec-agents-from-helm-private-repository)
  - [Variables](#variables)
    - [Mandatory Variables](#mandatory-variables)
    - [Optional Variables](#optional-variables)

## Prerequisites and limitations

- The deployment requires network access to the desired integration(SCM/Artifactory/CI tools).
- This deployment is not for Air gapped environments.
- Access Token/App Token for the specific integration.
- Available integrations(and how to generate access token):
  - [Gitlab Server](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token)
  - [Azure Devops Server](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows)
  - [BitBucket Server](https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html)
  - [JFrog Server](https://www.jfrog.com/confluence/display/JFROG/Access+Tokens)
  - Nexus

## Installing the chart

Follow the steps in this section for production grade deployments. You can either clone aqua-helm git repo or you can add our helm private repository (https://helm.aquasec.com)

### Installing Codesec Agents from Helm Private Repository

- Add Aqua Helm Repository

```bash
helm repo add aqua-helm https://helm.aquasec.com
helm repo update
```

- Check for available chart versions by running the below command

```bash
helm search repo aqua-helm/codesec-agent --versions
```

- Install the Agents

```bash
helm upgrade --install --namespace aqua-codesec <RELEASE_NAME> aqua-helm/codesec-agent \
--set credentials.aqua_key=<AQUA API KEY> \
--set credentials.aqua_secret=<AQUA API KEY SECRET> \
--set integration.source=<SOURCE> \
--set integration.url=<THE INTEGRATION URL> \
--set integration.username=<THE ACCESS TOKEN NAME OR ACCOUNT USERNAME> \
--set integration.password=<THE ACCESS TOKEN VALUE OR ACCOUNT PASSWORD> \
```

## Variables

In-order to deploy successfully there are mandatory and optional variables for certain occasions:

- Mandatory Aqua account credentials
- Mandatory Integration credentials
- Optional SSL credentials for Environments that are using CA and certificates
- Optional Http/s Proxy specification with no_proxy prefence to exclude specific domains from proxy

---

### Mandatory Variables

| Variable                | Type         | Description                                                                                            | Example                        |
| ----------------------- | ------------ | ------------------------------------------------------------------------------------------------------ | ------------------------------ |
| credentials.aqua_key    | String       | The Aqua account api key                                                                               |
| credentials.aqua_secret | String       | The Aqua account api key secret                                                                        |
| integration.source      | String(Enum) | The type of the integration (gitlab_server, azure_server, bitbucket_server,jenkins,nexus,jfrog_server) | "gitlab_server"                |
| integration.url         | String       | The SCM/Artifactory/CI integration endpoint                                                            | "https://my-gitlab-server.com" |
| integration.username    | String       | The SCM/Artifactory/CI account username or access token name                                           |                                |
| integration.password    | String       | The SCM/Artifactory/CI account password or access token value                                          |                                |

---

### Optional Variables

| Variable                    | Type    | Description                                                                       | Example                                           | Default |
| --------------------------- | ------- | --------------------------------------------------------------------------------- | ------------------------------------------------- | ------- |
| ssl.enabled                 | Boolean | Enable usage of SSL Certificates                                                  |                                                   | false   |
| ssl.ca                      | String  | The CA file content                                                               |                                                   |         |
| ssl.cert                    | String  | The Certificate file content                                                      |                                                   |         |
| ssl.key                     | String  | The Certificate private key                                                       |                                                   |         |
| proxy.http_proxy            | String  | The url of a proxy server to forward http:// protocol requests through            | http://username:password@my-proxy-server.com:8080 |         |
| proxy.https_proxy           | String  | The url of a proxy server to forward https:// protocol requests through           | https://username:password@my-proxy-server.com     |         |
| proxy.no_proxy              | String  | Comma separated list of domains to exclude from proxying (Can be a single domain) | myserver.com,myserver.net,myserver.co             |         |
| connect.port                | Number  | The connector http service port                                                   |                                                   | 9999    |
| connect.service.port        | Number  | The connector service port                                                        |                                                   | 9999    |
| connect.service.annotations | Object  | Any annotations for the Connector service                                         |                                                   |         |
| connect.resources           | Object  | Resource limitation for the connector deployment                                  |                                                   | {}      |
| connect.nodeSelector        | Object  | Node selector configuration for the connector deployment                          |                                                   | {}      |
| connect.affinity            | Object  | Affinity configuration for the connector deployment                               |                                                   | {}      |
| connect.tolerations         | Object  | Tolerations configuration for the connector deployment                            |                                                   | {}      |
| connect.hostAliases         | Object  | Host Aliases configuration for the connector deployment                           |                                                   |         |
| connect.extraEnv            | Object  | Extra environment variables to pass to the connect container.                     |                                                   | {}      |
| scan.replicas               | Number  | Number of pod replicas for the "scanner" service.                                 |                                                   | 1       |
| scan.resources              | Object  | Resource limitation for the scanner deployment                                    |                                                   | {}      |
| scan.nodeSelector           | Object  | Node selector configuration for the scanner deployment                            |                                                   | {}      |
| scan.affinity               | Object  | Affinity configuration for the scanner deployment                                 |                                                   | {}      |
| scan.tolerations            | Object  | Tolerations configuration for the scanner deployment                              |                                                   | {}      |
| scan.hostAliases            | Object  | Host Aliases configuration for the scanner deployment                             |                                                   |         |
| scan.extraEnv               | Object  | Extra environment variables to pass to the scanner container.                     |                                                   | {}      |
