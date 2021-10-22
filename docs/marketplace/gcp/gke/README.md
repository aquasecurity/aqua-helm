# Aqua Container Security Platform (CSP) for GCP Marketplace

This Github repo retains the helm charts and Kubernetes application manifest for Aqua Security's GCP Kubernetes Application Market offering. This readme includes reference documentation regarding installation and upgrades while operating within Google Kubernetes Engine.

Installation is simple, as Cloud Native apps should be! There is a minimum pre-requisite to attend to beyond having a GCP account: Aqua recommends running the Container Security Platform in a dedicated namespace. At the time of this writing creating a namespace in GKE requires kubectl. Fortunately, it's also very easy using the cloud shell. First, authenticate to the cluster, then create a namespace as follows:

```shell
kubectl create namespace aqua-security
```

Once you have created a namespace to install into, navigate to the [Aqua Security GCP marketplace offer.](https://www.google.com/url?q=https://console.cloud.google.com/marketplace/details/aquasecurity-public/aqua-container-security).

Click configure, selecting the cluster, billing plan and namespace which you just created.
Now be patient as the deployment takes approximately three minutes.

> **A word about plans**
>
>Aqua has established three Pay-As-You-Go billing plans. These plans are based on Kubernetes cluster nodes where the Enforcer will run.
>The billing service on the Aqus server is defining these nodes for PAYG billing by the quantity of vCPU at the host VM level. See the below chart.
>
>| Aqua Term   | vCPU Count |
>|-------------|------------|
>| Small Node  | 0-2 vCPU   |
>| Medium Node | 3-7 vCPU   |
>| Large Node  | 8+ vCPU    |
>
>GCP allows an organization to designate a billing admin. A [billing admin permission](https://cloud.google.com/billing/docs/how-to/billing-access) allows the user to specify the billing plan an entire org may utilize. For example, Aqua CSP has three billing sizes, yet the billing admin chose the small plan. The Kubernetes admin, in this case, would not be allowed >to deploy Aqua CSP on a cluster with nodes of 12 vCPU. K8s admins, be advised this functionality exists.  

## Complete Initial Deployment

The marketplace deployer will automatically deploy the Aqua Command Center and accompanying Aqua Enforcers set to audit mode. This process takes approx. three minutes. The following four basic steps are necessary to complete deployment. They are also depicted in the notes side of the GCP deployer panel.
  
## 1. Backup Auto-Generated Secrets

By default, the Aqua PostgreSQL container utilizes a persistent volume (PVC). When removing the application, this PVC is not deleted along with your application to save your data.
In the case you re-deploy using the same application name and namespace, reloading these secrets will be necessary to access the db files on the reused PVC. It is **very important** to back up the secrets for this purpose.
Please back them up ***now*** and see the [ReDeploying Aqua CSP](#ReDeploying-Aqua-CSP) section.

```shell
kubectl get secrets -l secretType=aquaSecurity \
--namespace {{ .Release.Namespace }} -o json > aquaSecrets.json
```

## 2. Obtain the Aqua Command Center portal information

A user may run the following command or click on the Services tab and look for appname-server-svc.

```shell
SERVICE_IP=$(kubectl get svc appname-server-svc \
--namespace namespace \
--output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${SERVICE_IP}:8080"
```

## 3. Obtain the Aqua Command Center administrator password

The default username is `administrator`. Use `kubectl` to extract the generated password from the secret.

```shell
kubectl get secret appname-admin-pass \
--namespace namespace \
--output=jsonpath='{.data.password}' | base64 --decode
```

## 4. Enter the license to enable the product

Users that have a license token for GKE Marketplace should enter it to enable the PAYG billing of Enforcers. If you do not have a license token, you may request one by filling out the form linked on the Aqua Command Center startup portal.

>*A note about Aqua CSP for GCP Marketplace licenses*
>
>The license issued is specific to the environment. As of this writing, an Enterprise license will not enable a deployment via GCP Marketplace or vice versa.

## View logs of the Aqua Command Center

Sometimes an admin just needs the read some logs. While these are accessible in the Aqua console under Settings > Logs, should you need to access logs of the Aqua server pod via CLI, use the below command.

```shell
SERVERPOD=$(kubectl get pods -l app=appname-server \
--namespace namespace --no-headers -o=custom-columns=NAME:.metadata.name)
kubectl logs -f ${SERVERPOD} --namespace=nameSpace
```

## ReDeploying Aqua CSP

Sometimes a cluster has to be deleted, migrated, redeployed in a different region, etc for various reasons. Because of these scenarios, the Aqua database container uses a Persistent Volume Claim (PVC) to safeguard inadvertent database loss. A [PVC](https://cloud.google.com/kubernetes-engine/docs/concepts/persistent-volumes) is a mechanism within Kubernetes that allows an application to mount a physical disk (PD) as a Kubernetes volume. This grants the PD reusability, among other capabilities.

To redeploy Aqua CSP and reattach the previously utilized PVC, one may choose the same cluster, namespace and app name. Doing so will cause the marketplace launcher to reattach the matching PVC. This does present a challenge however due to the *kubectl apply* that the launcher is running. The *apply* means existing secrets of the same name will be regenerated and overwritten, causing the database connection from the Aqua server and database containers to fail. To alleviate, this particular issue, stage the following commands in the cloud console run them 15-30 seconds after starting a redeploy. Doing so will overwrite the secrets with the proper values, and allow the server and gateway pods to reconnect to the database. You may notice this procedure relies on the Kubernetes pod initialization restart timer, and you would be correct! We're merely taking advantage of the Kubernetes toolkit vs editing the database with Postgres commands.

```shell
kubectl delete -f aquaSecrets.json
kubectl create -f aquaSecrets.json
```

## Uninstalling Aqua CSP

Uninstalling the Aqua CSP and all components may be performed by the following functions in the GCP Console:

1. Delete the Aqua Security app under GKE > Applications
2. Delete the associated PVC under GKE > Storage
3. Delete the associated secrets GKE > Configuration
