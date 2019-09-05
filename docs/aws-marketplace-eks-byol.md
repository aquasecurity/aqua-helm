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

* **Server**:
```bash
cd aqua-helm; helm install --namespace aqua --name csp./server \
    --set imageCredentials.repositoryUriPrefix=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,imageCredentials.registry=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,imageCredentials.create=false,imageCredentials.use=false,db.image.repository=marketplace-database,db.image.tag=4.2.19233-latest,db.persistence.storageClass=gp2,gate.image.repository=marketplace-gateway,gate.image.tag=4.2.19233-latest,web.image.repository=marketplace-console,web.image.tag=4.2.19233-latest,web.service.type=LoadBalancer
```

**Or** with external database

DB_HOST - External database IP or DNS
DB_PORT - External database port
DB_USERNAME - External database username
DB_PASSWORD - External database password

```bash
cd aqua-helm; helm install --namespace aqua --name csp./server \
    --set imageCredentials.repositoryUriPrefix=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,imageCredentials.registry=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,imageCredentials.create=false,imageCredentials.use=false,db.external.enabled=true,db.external.name=scalock,db.external.host=<DB_HOST>,db.external.port=<DB_PORT>,db.external.user=<DB_USER>,db.external.password=<DB_PASSWORD>,db.external.auditName=slk_audit,db.external.auditHost=<DB_HOST>,db.external.auditPort=<DB_PORT>,db.external.auditUser=<DB_USER>,db.external.auditPassword=<DB_PASSWORD>,gate.image.repository=marketplace-gateway,gate.image.tag=4.2.19233-latest,web.image.repository=marketplace-console,web.image.tag=4.2.19233-latest,web.service.type=LoadBalancer
```

* **Enforcer**:

ENFORCER_TOKEN - Enforcer group token

```bash
cd aqua-helm; helm install --namespace aqua --name csp-enforcer ./enforcer \
    --set imageCredentials.repositoryUriPrefix=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,imageCredentials.registry=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,imageCredentials.create=false,imageCredentials.use=false,enforcerToken=<TOKEN>,gate.host=csp-gateway-svc,image.repository=marketplace-enforcer,image.tag=4.2.19233-latest
```

* **Scanner**:

AQUA_USERNAME - Aqua console username
AQUA_PASSWORD - Aqua console password

```bash
cd aqua-helm; helm install --namespace aqua --name csp-scanner ./scanner \
    --set imageCredentials.repositoryUriPrefix=117940112483.dkr.ecr.us-east-1.amazonaws.com/62da55d2-e19f-4d6d-b78f-4957796d2480/cg-4171980317,image.repository=marketplace-scanner,image.tag=4.2.19233-latest,user=<AQUA_USERNAME>,password=<AQUA_PASSWORD>,serviceAccount=csp-sa,server.serviceName=csp-console-svc
```
