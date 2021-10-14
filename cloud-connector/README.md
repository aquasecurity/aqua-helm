<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Cloud Connector

### Overview

The Aqua Cloud Connector is used in conjunction with Aqua Platform SaaS Edition (Enterprise Plan) deployments. When deployed on local clusters, i.e., clusters on which Aqua Platform is not deployed, the Aqua Cloud Connector establishes a secure connection to the Aqua Platform console, giving Aqua Platform remote access to resources on the local clusters.

# Aqua Cloud Connector deployment through Helm


  1. Clone the GitHub repository
  ```bash
  $ git clone https://github.com/aquasecurity/aqua-helm.git
  $ cd aqua-helm
  ```

  2. Create the `aqua` namespace.
  ```bash
  $ kubectl create namespace aqua
  ```

  3. Deploy Cloud Connector helm chart
  ```bash
  $ helm upgrade --install aqua ./cloud-connector -n aqua --set imageCredentials.username=<>,imageCredentials.password=<>
  ```

# Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.