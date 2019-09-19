# AWS Marketplace EKS BYOL

Aqua Container Security Platform (CSP) for Amazon EKS deployment with **aquactl** or with **helm**

## Installation

**In Eks Marketplace we created 2 options to install aqua:**
* Helm
* Aquactl (In additional to the regular aquactl installation)

## Prerequisites

* A current installation of [Helm](https://helm.sh/)
* EKS role binding appropriate for Helm's use
* Database options
* Extend EKS with a StorageClass that supports EBS
* AWS MP Subscription to the [Aqua CSP EKS offer.](https://aws.amazon.com/marketplace/pp/B07KCNBW7B)

### Aquactl

download aquactl for **Linux**

```bash
wget https://get.aquasec.com/aquactl/stable/aquactl
chmod +x aquactl
```

download aquactl for **Mac**

```bash
wget https://get.aquasec.com/aquactl/mac/stable/aquactl
chmod +x aquactl
```

and then run aquactl deploy command with interactive interface or one line command:

* **Server**:
```bash
./aquactl deploy csp -p eks --marketplace
```

**Or** with external database

DB_HOST - External database IP or DNS
DB_PORT - External database port
DB_USERNAME - External database username
DB_PASSWORD - External database password

```bash
./aquactl deploy csp -p eks --marketplace --external-db --external-db-host <DB_HOST> --external-db-port <DB_PORT> --external-db-username <DB_USERNAME> --external-db-password <DB_PASSWORD>
```

* **Enforcer**:

ENFORCER_TOKEN - Enforcer group token

```bash
./aquactl deploy enforcer -p eks --marketplace --token <ENFORCER_TOKEN>
```

* **Scanner**:

AQUA_USERNAME - Aqua console username
AQUA_PASSWORD - Aqua console password

```bash
./aquactl deploy scanner -p eks --marketplace --aqua-username <AQUA_USERNAME> --aqua-password <AQUA_PASSWORD>
```

### Helm

## Installing the Charts

Clone the GitHub repository with the charts

```bash
git clone -b 4.2 https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

* **Server**:
```bash
helm install --namespace aqua --name csp ./server \
    --set imageCredentials.repositoryUriPrefix=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,imageCredentials.registry=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,imageCredentials.create=false,imageCredentials.use=false,db.image.repository=marketplace-database,db.image.tag=4.2-latest,db.persistence.storageClass=gp2,gate.image.repository=marketplace-gateway,gate.image.tag=4.2-latest,web.image.repository=marketplace-console,web.image.tag=4.2-latest,web.service.type=LoadBalancer
```


**Or** with external database

DB_HOST - External database IP or DNS
DB_PORT - External database port
DB_USERNAME - External database username
DB_PASSWORD - External database password

```bash
helm install --namespace aqua --name csp ./server \
    --set imageCredentials.repositoryUriPrefix=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,imageCredentials.registry=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,imageCredentials.create=false,imageCredentials.use=false,db.external.enabled=true,db.external.name=scalock,db.external.host=<DB_HOST>,db.external.port=<DB_PORT>,db.external.user=<DB_USER>,db.external.password=<DB_PASSWORD>,db.external.auditName=slk_audit,db.external.auditHost=<DB_HOST>,db.external.auditPort=<DB_PORT>,db.external.auditUser=<DB_USER>,db.external.auditPassword=<DB_PASSWORD>,gate.image.repository=marketplace-gateway,gate.image.tag=4.2-latest,web.image.repository=marketplace-console,web.image.tag=4.2-latest,web.service.type=LoadBalancer
```


Get aqua console address
```
kubectl get svc csp-console-svc -n aqua
```

* **Enforcer**:

ENFORCER_TOKEN - Enforcer group token

```bash
helm install --namespace aqua --name csp-enforcer ./enforcer \
    --set imageCredentials.repositoryUriPrefix=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,imageCredentials.registry=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,imageCredentials.create=false,imageCredentials.use=false,enforcerToken=<TOKEN>,gate.host=csp-gateway-svc,image.repository=marketplace-enforcer,image.tag=4.2-latest
```

* **Scanner**:

AQUA_USERNAME - Aqua console username
AQUA_PASSWORD - Aqua console password

```bash
helm install --namespace aqua --name csp-scanner ./scanner \
    --set repositoryUriPrefix=709373726912.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-3563552377,image.repository=marketplace-scanner,image.tag=4.2-latest,user=<AQUA_USERNAME>,password=<AQUA_PASSWORD>,serviceAccount=csp-sa,server.serviceName=csp-console-svc
```

### Helm Customizations / Troubleshooting

***This section not all-inclusive. It includes information regarding common issues Aqua has encountered during deployments***

**Error:** 

  ```sh
  Error: secrets "csp-database-password" is forbidden: User "system:serviceaccount:kube-system:default" cannot delete resource "secrets" in API group "" in the namespace "aqua"
  ```

**Solution:** Create a service account for Tiller to utilize.
  ```sh
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
  helm init --service-account tiller --upgrade
