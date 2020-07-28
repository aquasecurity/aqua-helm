# Container registry credentials

Aqua Security components docker images are available in our private repository, which requires authentication. By default, the charts create a secret based on the values.yaml file.

1. Create a new namespace named `aqua`:

```bash
kubectl create namespace aqua
```

2. Create the image pull secret:

```bash
kubectl create secret docker-registry aqua-registry-secret --docker-server="registry.aquasec.com" --namespace aqua --docker-username="user@example.com" --docker-password="<Password>" --docker-email="user@example.com"
```

> Note: in case you using the csp chart the chart can create the image pull secret automaticly.

after creating the secret you should set in the values to not create pull image secret by setting up in values.yaml file
set create as `false` and the name as the name of the secret you create:

```yaml
imageCredentials:
  create: false
  name: aqua-registry-secret
  repositoryUriPrefix: "registry.aquasec.com" 
  registry: "registry.aquasec.com"
  username: ""
  password: ""
```