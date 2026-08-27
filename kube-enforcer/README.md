<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua KubeEnforcer Helm Charts

This page provides instructions for using Helm charts to configure and deploy the Aqua KubeEnforcer.

## Contents

- [Aqua KubeEnforcer Helm Charts](#aqua-kubeenforcer-helm-charts)
  - [Contents](#contents)
  - [Trivy Operator](#trivy-operator)
  - [Prerequisites](#prerequisites)
    - [Container registry credentials](#container-registry-credentials)
    - [Clone the GitHub repository with the charts](#clone-the-github-repository-with-the-charts)
    - [Conncet to Aqua Saas / Gateway via proxy](#conncet-to-aqua-saas--gateway-via-proxy)
    - [Configure TLS authentication between the KubeEnforcer and the API Server](#configure-tls-authentication-between-the-kubeenforcer-and-the-api-server)
      - [How to use cert-manager to configure TLS authentication between the KubeEnforcer and the API Server](#how-to-use-cert-manager-to-configure-tls-authentication-between-the-kubeenforcer-and-the-api-server)
  - [Deploy the Helm chart](#deploy-the-helm-chart)
    - [Deploy the KubeEnforcer with Trivy Operator from a Helm private repository](#deploy-the-kubeenforcer-with-trivy-operator-from-a-helm-private-repository)
  - [Configuration for discovery](#configuration-for-discovery)
  - [Configuration for performing kube-bench scans](#configuration-for-performing-kube-bench-scans)
  - [4. Configuring KubeEnforcer mTLS with Gateway/Envoy](#4-configuring-kubeenforcer-mtls-with-gatewayenvoy)
    - [Create Root CA (Done once)](#create-root-ca-done-once)
    - [Create the certificate key and certificate for kube-enforcer](#create-the-certificate-key-and-certificate-for-kube-enforcer)
    - [Create secrets with generated certs and change `values.yaml` as mentioned below](#create-secrets-with-generated-certs-and-change-valuesyaml-as-mentioned-below)
  - [Configuration for KubeEnforcer Advance deployment](#configuration-for-kubeenforcer-advance-deployment)
  - [NetworkPolicy (optional)](#networkpolicy-optional)
  - [Configuration for KubeEnforcer with cert-manager](#configuration-for-kubeenforcer-with-cert-manager)
  - [Integrate Kube-Enforcer with Hashicorp Vault to Load Token](#integrate-kube-enforcer-with-hashicorp-vault-to-load-token)
  - [Configurable Variables](#configurable-variables)
  - [Issues and feedback](#issues-and-feedback)

## Trivy Operator

Trivy Operator is the default security scanner for KubeEnforcer in this chart version. The chart enables Trivy Operator by default and keeps Starboard disabled unless you explicitly switch.

> :exclamation: Only one operator should be enabled per deployment. Use either `trivy.enabled=true` **or** `starboard.enabled=true`.

An important part of Kubernetes security is the evaluation of workload compliance results with respect to Kubernetes Assurance Policies, and preventing the deployment of non-compliant workloads; see Admission control for Kubernetes containers.

When Trivy Operator **is** deployed, it assesses workload compliance throughout the lifecycle of the workloads. This enables the KubeEnforcer to:
* Re-evaluate workload compliance during workload runtime, taking any workload and policy changes into account
* Reflect the results of compliance evaluation in the Aqua UI at all times, not only when workloads are created

When Trivy Operator is **not** deployed, the KubeEnforcer will check workloads for compliance only when the workloads are started.


## Prerequisites

### Container registry credentials

[Link](../docs/imagepullsecret.md)

### Clone the GitHub repository with the charts

```shell
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```
### Conncet to Aqua Saas / Gateway via proxy 

Aqua Enforcers can use http proxies for their communication. The http proxy must support gRPC, TLS/SSL inspection is not recommended. 
To configure a proxy set `http_proxy`, `https_proxy` and `no_proxy` in `extraEnvironmentVars`
```
extraEnvironmentVars:
  http_proxy:  http://proxy01.proxy.svc.cluster.local:8080
  https_proxy: http://proxy01.proxy.svc.cluster.local:8080
  no_proxy: .svc.cluster.local
```
As Kube Enforcer need to communicate with the KubeAPI, make sure `no_proxy` is configured to by pass the proxy. Use a comma separated list of IPs, FQDN or FQDN suffixes.
If you deploy the Aqua Enforcer `enforcer.enabled=true` with this chart, make sure you set the environment variables accordingly in the `enforcer` section. 

**If `networkPolicy.enabled=true`**, egress to the proxy is not covered by `gatewayEgressCidrs` / `gatewayNamespace` (those are pinned to `global.gateway.port`, not the proxy's port) or by the default ports on `additionalEgressCidrs`. Configure `networkPolicy.proxyNamespace` + optional `networkPolicy.proxyPodLabels` for an in-cluster proxy, or `networkPolicy.proxyEgressCidrs` for an external/node-level proxy; both require `networkPolicy.proxyPort` (the proxy's listening port, e.g. `8080` for `http://proxy01.proxy.svc.cluster.local:8080` above). On CNIs such as Calico, reaching an in-cluster proxy via its Service ClusterIP does not work under NetworkPolicy egress (DNAT happens before policy evaluation) — use `proxyNamespace` + `proxyPodLabels`, or the proxy pod/node IP CIDR via `proxyEgressCidrs`, instead. See [NetworkPolicy (optional)](#networkpolicy-optional).

### Configure TLS authentication between the KubeEnforcer and the API Server

You need to enable TLS authentication from the API Server to the KubeEnforcer. Perform these steps:

Create TLS certificates which are signed by the local CA certificate. We will pass these certificates with a Helm command to enable TLS authentication between the KubeEnforcer and the API Server to receive events from the ValidatingWebhookConfiguration for Image Assurance functionality.

You can generate these certificates by executing the script:

```shell
./kube-enforcer/gen-certs.sh
```

You can also use your own certificates without generating new ones for TLS authentication. All you need is a root CA certificate, a certificate signed by a CA, and a certificate key.

You can configure the certificates generated from the above script or own certificates in the ```values.yaml``` file.

You need to encode the certificates into base64 for ```ca.crt```, ```server.crt``` and ```server.key``` using this command:

```shell
cat <ca.crt> | base64 | tr -d '\n'
cat <server.crt> | base64 | tr -d '\n'
cat <server.key> | base64 | tr -d '\n'
```

Provide the certificates previously obtained in the fields of the ```values.yaml``` file, as indicated here:

```shell
certsSecret:
  create: true
  name: aqua-kube-enforcer-certs
  serverCertificate: "<base64_encoded_server.crt>"
  serverKey: "<base64_encoded_server.key>"

webhooks:
  caBundle: "<base64_encoded_ca.crt>"
```
#### How to use cert-manager to configure TLS authentication between the KubeEnforcer and the API Server
If you are planning to create and manage your self-signed certificates using [cert-manger](https://cert-manager.io/docs/),
You need set `webhook.certManager` to be `true` and add [annotations](https://cert-manager.io/docs/concepts/ca-injector/#injecting-ca-data-from-a-certificate-resource)
```shell
webhooks:
  certManager: true
  validatingWebhook:
    annotations:
      cert-manager.io/inject-ca-from: < namespace >/< certsSecret.name >
  mutatingWebhook:
    annotations:
      cert-manager.io/inject-ca-from: < namespace >/< certsSecret.name >
```

## Deploy the Helm chart
### Deploy the KubeEnforcer with Trivy Operator from a Helm private repository

1. Add Aqua Helm Repository

   ```shell
   helm repo add aqua-helm https://helm.aquasec.com
   helm repo update
   ```

2. (Optional) Update the Helm charts `values.yaml` file with your environment's custom values, registry secret, Aqua Server (console) credentials, and TLS certificates. This eliminates the need to pass the parameters to the Helm command. Then run one of the following commands to deploy the relevant services.

3. Check for available chart versions either from [Changelog](./CHANGELOG.md) or by running the below command

   ```shell
   helm search repo aqua-helm/kube-enforcer --versions
   ```

4. Choose **either** 4a **or** 4b:

   4a. To deploy the KubeEnforcer on the same cluster as the Aqua Server (console), run this command on that cluster:

   ```shell
   helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer
   ```

   4b. Multi-cluster: To deploy the KubeEnforcer in a different cluster:

   First, create a namespace on that cluster named `aqua`:
   ```shell
   kubectl create namespace aqua
   ```
   Next, copy the content from [Values.yaml](./values.yaml), make the respective changes, and run the following command:

   ```shell
   helm upgrade --install --namespace aqua kube-enforcer aqua-helm/kube-enforcer --values values.yaml --version <>
   ```

5. Optional flags:

| Flag                           | Description                                                                                                                                                                                                                                                                                                 |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| --namespace                    | defaults to `aqua`                                                                                                                                                                                                                                                                                          |
| --aquaSecret.kubeEnforcerToken | defaults to `"ke-token"`; you can obtain the KubeEnforcer token from Aqua Enterprise under the Enforcers screen in the default/custom KubeEnforcer group, or you can manually approve KubeEnforcer authentication from Aqua Enterprise under the default/custom KubeEnforcer group in the Enforcers screen. |

## Configuration for discovery

To perform discovery on the cluster, the KubeEnforcer needs a dedicated ClusterRole with `get`, `list`, and `watch` permissions on pods, secrets, nodes, namespaces, deployments, ReplicaSets, ReplicationControllers, StatefulSets, DaemonSets, jobs, CronJobs, ClusterRoles, ClusterRoleBindings, and ComponentStatuses`.

## Configuration for performing kube-bench scans

To perform kube-bench scans in the cluster, the KubeEnforcer needs:
- A dedicated role in the `aqua` namespace with `get`, `list`, and `watch` permissions on `pods/log`
- `create` and `delete` permissions on jobs
-  `create` and `delete` permissions on pods(Only for Openshift platform)

## 4. Configuring KubeEnforcer mTLS with Gateway/Envoy
  By default, deploying Aqua Enterprise configures TLS-based encrypted communication, using self-signed certificates, between Aqua components. If you want to use self-signed certificates to establish mTLS between kube-enforcer and gateway/envoy use the below instructions to generate rootCA and component certificates

  > **Note:** **_mTLS communication and setup is only supported for self-hosted Aqua. It is not supported for Aqua ESE and Aqua SAAS_**

  ### Create Root CA (Done once)

  ***Important:*** The rootCA certificate used to generate the certificates for aqua server/gateway/envoy, use the same rootCA to generate kube-enforcer certificates.

  ### Create the certificate key and certificate for kube-enforcer

  **1. Create component key:**

  ```shell
  openssl genrsa -out aqua_kube-enforcer.key 2048
  ```

  **2. Create the signing (csr):**

  The certificate signing request is where you specify the details for the certificate you want to generate.
  This request will be processed by the owner of the Root key (you in this case since you create it earlier) to generate the certificate.

  ***Important:*** Please mind that while creating the signing request is important to specify the `Common Name` providing the IP address or domain name for the service, otherwise the certificate cannot be verified.

  - Generating aqua_kube-enforcer csr:
  ```shell
  openssl req -new -sha256 -key aqua_kube-enforcer.key \
    -subj "/C=US/ST=MA/O=aqua/CN=aqua-kube-enforcer" \
    -out aqua_kube-enforcer.csr
  ```

  **3. Verify the CSR content:**
  - verify the generated csr content(optional)
  ```shell
    openssl req -in aqua_kube-enforcer.csr -noout -text
  ```

  **4. Generate the certificate using the component csr and key along with the CA Root key:**

  ```shell
  openssl x509 -req -in aqua_kube-enforcer.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_kube-enforcer.crt -days 500 -sha256
  ```

  **5. Verify the certificate content:**
  - verify the generated certificate content(optional)
  ```shell
  openssl x509 -in aqua_kube-enforcer.crt -text -noout
  ```

### Create secrets with generated certs and change `values.yaml` as mentioned below
  1. Create Kubernetes secret for kube-enforcer using the generated SSL certificates.
  ```shell
    # Example:
    # Change < certificate filenames > respectively
      kubectl create secret generic ke-mtls-certs --from-file aqua_kube-enforcer.key --from-file aqua_kube-enforcer.crt --from-file rootCA.crt -n aqua
  ```
  2. Enable `TLS.enabled`  to `true` in values.yaml
  3. Add the certificates secret name `TLS.secretName` in values.yaml
  4. Add respective certificate file names to `TLS.publicKey_fileName`, `TLS.privateKey_fileName` and `TLS.rootCA_fileName`(Add rootCA if certs are self-signed) in values.yaml
  5. For enabling mTLS/TLS connection with self-signed or CA certificates between gateway and enforcer please set up mTLS/TLS config for gateway in server chart as well [server chart](../server/README.md#configuring-mtlstls-for-aqua-server-and-aqua-gateway)
## Configuration for KubeEnforcer Advance deployment

   1. Change `kubeEnforcerAdvance.enable` to `true` in `values.yaml`
   2. (optional) By default, envoy generates self-signed certs for secure communications.
      1. Optionally, Generate TLS certificates signed by a public CA or Self-Signed CA

      ```shell
         #####################################################################################
         # Create a certificate
         #####################################################################################

         # Create the certificate key
         openssl genrsa -out myDomain.com.key 2048
         # Create the signing (csr)
         openssl req -new -key myDomain.com.key -out myDomain.com.csr
         # Verify the csr content
         openssl req -in myDomain.com.csr -noout -text

         #####################################################################################
         # Generate the certificate using the myDomain csr and key along with the CA Root key
         #####################################################################################

         openssl x509 -req -in myDomain.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out myDomain.com.crt -days 500 -sha256

         #####################################################################################
         # If you wish to use a Public CA like GoDaddy or LetsEncrypt please
         # submit the myDomain csr to the respective CA to generate myDomain crt
         ```

      2. (optional) Create TLS cert secret
         ```shell
         $ kubectl create secret generic envoy-mtls-certs --from-file=myDomain.com.crt --from-file=myDomain.com.key --from-file=rootCA.crt -n aqua
         ```

      3. (optional) Edit the values.yaml file to include above secret to mount custom certificates to envoy
      ```yaml
          TLS:
            listener:
               create: "true"
               secretName: "envoy-mtls-certs"
               publicKey_fileName: "myDomain.com.crt"
               privateKey_fileName: "myDomain.com.key"
               rootCA_fileName: "rootCA.crt"
      ```

   3. For more customizations please refer to [***Configurable Variables***](#configurable-variables)

## NetworkPolicy (optional)

Requires a CNI that enforces `networking.k8s.io/v1` NetworkPolicy (e.g. Calico). Each CNI implements NetworkPolicies slightly differently and may require a different set of rules. After deployment, follow [Validating NetworkPolicy and webhook reachability](#validating-networkpolicy-and-webhook-reachability) — pod `Ready` alone is not sufficient.

**Warning — Do not enable `networkPolicy.enabled` without setting cluster CIDR values.** Defaults are empty; `helm template` / `helm install` fail when `networkPolicy.enabled=true` and `nodeCidr` or `podCidr` is unset. `serviceCidr` and `controlPlaneCidr` are optional — omit them on managed clouds and use `additionalEgressCidrs` / `additionalIngressCidrs` instead. Gateway egress (`gatewayEgressCidrs` or `gatewayNamespace`) is also required unless `allowInternetHttps=true` and `global.gateway.port` is 443. Use the example values below — the `10.x` CIDRs are placeholders only and must match your cluster.

**Warning — `hostNetwork: true` disables NetworkPolicy for the pod.** Do not enable `networkPolicy.enabled` when `hostNetwork` is true.

This policy applies to kube-enforcer only. Trivy Operator / Starboard are not covered.

### Scope

**What this policy provides:** egress containment for the kube-enforcer pod (DNS, API server, gateway, optional HTTPS) plus ingress scoping for apiserver webhook callbacks and node/control-plane sources.

**What it does not provide:** pod-to-pod isolation. The `podCidr` ingress rule allows any pod in the cluster to reach kube-enforcer on port 8443 and on the configured kubelet probe port (default 8080; see below). Webhook caller source IPs vary by platform, so this breadth is intentional — but do not treat this policy as a boundary between kube-enforcer and other workloads.

Set `networkPolicy.enabled=true` and replace `nodeCidr` and `podCidr` with your cluster values. On dual-stack clusters, set the optional `*CidrV6` companions (`nodeCidrV6`, `podCidrV6`, etc.) so IPv6 traffic is not denied while namespace selectors still work. Set `serviceCidr` and `controlPlaneCidr` for kubeadm-style clusters; omit them on EKS/GKE/AKS and use `additionalEgressCidrs` / `additionalIngressCidrs` instead.

**Ingress vs egress — two different directions:**

All ingress sources below are combined into a single rule, so each source is allowed on **both** 8443 (webhook) and the kubelet health-probe port — the chart does not scope individual sources to a single port. The probe port is read from `readinessProbe.httpGet.port` / `readinessProbe.tcpSocket.port` / `readinessProbe.grpc.port` and the equivalent `livenessProbe.*` fields (defaulting to 8080 when unset); if you override those probe ports, the NetworkPolicy follows automatically. In `kubeEnforcerAdvance` mode the container uses an exec probe instead, so no probe port is opened. See [Scope](#scope) above.

| Direction | Traffic | Ports | Knob |
|-----------|---------|-------|------|
| Ingress | apiserver → KE webhook; kubelet health probes (standard mode) | 8443, probe port(s) (default 8080) | `nodeCidr`, `podCidr`, `controlPlaneCidr`, `additionalIngressCidrs` |
| Ingress | apiserver proxy pods (e.g. GKE konnectivity) | 8443, probe port(s) (default 8080) | `ingressSystemNamespace` (default `kube-system`; independent of `dnsNamespace`) |
| Egress | KE → cluster DNS | 53 | `dnsNamespace`, optional `dnsPodLabels` |
| Egress | KE → apiserver (client) | 443, 6443 | `serviceCidr` (443, kubeadm/kube-proxy), `controlPlaneCidr`, `additionalEgressCidrs` |
| Egress | KE → gateway | `global.gateway.port` | `gatewayEgressCidrs`, `gatewayNamespace` + `gatewayPodLabels` |
| Egress | KE → HTTP proxy (`extraEnvironmentVars.http_proxy`/`https_proxy`) | `proxyPort` | `proxyEgressCidrs`, `proxyNamespace` + `proxyPodLabels` |
| Egress | KE → Vault (vault-agent sidecar) | 8200 / 443 | `vaultNamespace` (in-cluster, `vaultExternal=false`), or `vaultExternal=true` with `vaultEgressCidrs` / `allowInternetHttps` (HCP on 443 only) |

The probe-port ingress rule is only added in standard mode (HTTP/TCP readiness/liveness probes). In `kubeEnforcerAdvance` mode, probes use exec instead, so no probe port is added to the policy.

On kubeadm-style clusters, `controlPlaneCidr` covers apiserver webhook callbacks (ingress on 8443) and direct API access (egress on 6443). `serviceCidr:443` covers in-cluster API access via the `kubernetes` Service. On EKS, GKE, and AKS, traffic to `kubernetes.default` is DNAT'd to the real apiserver endpoint, which is often outside `serviceCidr` and `controlPlaneCidr`. Use `additionalEgressCidrs` for those destination IPs — do **not** put them in `additionalIngressCidrs`.

`additionalIngressCidrs` is for apiserver source IPs calling the KE admission webhook (managed-cloud control planes not covered by `nodeCidr` / `podCidr` / `controlPlaneCidr`).

`additionalIngressCidrs` and `additionalEgressCidrs` are IPv4 CIDR strings only — they do not have `*CidrV6` companions. On dual-stack managed clouds, add IPv6 entries as additional list items if your apiserver or endpoint uses IPv6.

`additionalEgressCidrs` accepts a flat CIDR list (ports 443 and 6443) or objects with `cidr` and optional `ports` (defaults to 443 and 6443 when omitted):

```yaml
additionalEgressCidrs:
  - "10.0.2.0/24"               # flat CIDR → ports 443 and 6443
  - cidr: "10.0.0.5/32"
    ports: [443]                 # custom port list per entry
```

**Private vs public endpoints — when to use which CIDR type**

All examples below use private `10.x` placeholders. Substitute values from *your* cluster — never copy CIDRs from documentation.

| Scenario | Use | Knob |
|----------|-----|------|
| Private apiserver endpoint (VPC, master CIDR, VNet integration) | Provider-published private CIDR | `additionalEgressCidrs` |
| Public apiserver endpoint enabled | Endpoint IPs/CIDRs from your `describe-cluster` / cloud console output | `additionalEgressCidrs` |
| Authorized networks / apiserver source ranges | Ranges configured on the control plane | `additionalIngressCidrs` |
| In-cluster gateway (pod selector or pod IP CIDR) | `gatewayNamespace` + `gatewayPodLabels`, or gateway pod/node CIDR | `gatewayNamespace` / `gatewayEgressCidrs` |
| SaaS or external gateway with `allowInternetHttps=false` | Gateway endpoint CIDRs from your onboarding / provider | `gatewayEgressCidrs` |
| SaaS or external gateway with `allowInternetHttps=true` (default) | Broad HTTPS egress (`0.0.0.0/0:443`) — no per-endpoint CIDRs needed | `allowInternetHttps` |

When a managed cluster uses a **public** API endpoint, `serviceCidr` and `controlPlaneCidr` alone are not enough — add the endpoint destination CIDRs to `additionalEgressCidrs`. Obtain them from your cloud provider (cluster describe output, console, or support docs for your account). Do not guess or use third-party IP ranges.

When `allowInternetHttps=false` and the gateway is outside the cluster, add the gateway's endpoint CIDRs to `gatewayEgressCidrs`. Resolve the hostname in `global.gateway.address` with your own DNS lookup and add the results as `/32` entries — use only addresses returned for *your* deployment.

**Gateway egress** uses `global.gateway.port` (8443 on-prem TLS gateway, 443 for SaaS, 3622 for plain gateway service). Configure one or both:

- `networkPolicy.gatewayNamespace` + `networkPolicy.gatewayPodLabels` — in-cluster gateway pods (recommended for gateways in another namespace). `gatewayPodLabels` must be a non-empty map when `gatewayNamespace` is set (`null` fails at template time; Helm merges chart defaults so `{}` alone does not clear the default `aqua.component: gateway`). On CNIs such as Calico, Service ClusterIP egress does **not** work — traffic is DNAT'd to the pod IP before policy evaluation, so use a namespace/pod selector or the gateway pod IP CIDR instead.
- `networkPolicy.gatewayEgressCidrs` — external gateway, node, or load-balancer CIDRs (not in-cluster Service ClusterIP). Required when the gateway is outside the cluster or `allowInternetHttps=false`.

**Proxy egress** — see [Connect to Aqua Saas / Gateway via proxy](#conncet-to-aqua-saas--gateway-via-proxy). If `extraEnvironmentVars.http_proxy` / `https_proxy` is set, KE's egress destination becomes the proxy instead of the gateway/apiserver/internet directly, and none of the rules above cover it (they target the gateway/apiserver/internet, not the proxy's address and port). Configure `networkPolicy.proxyNamespace` + optional `networkPolicy.proxyPodLabels` (in-cluster proxy) or `networkPolicy.proxyEgressCidrs` (external/node-level proxy); both require `networkPolicy.proxyPort` set to the proxy's listening port. Same Calico-style Service ClusterIP DNAT caveat as gateway egress applies. Template rendering fails when `extraEnvironmentVars` sets `http_proxy`/`https_proxy` (case-insensitive) but neither `proxyNamespace` nor `proxyEgressCidrs` is set.

**DNS egress** targets the cluster DNS namespace via `networkPolicy.dnsNamespace`. Default is `kube-system` (CoreDNS on most clusters). On OpenShift, DNS runs in `openshift-dns`; set `global.platform=openshift` to auto-select it, or set `networkPolicy.dnsNamespace=openshift-dns` explicitly. This is independent of **ingress** from `kube-system` pods (konnectivity / apiserver proxy on GKE), which uses `networkPolicy.ingressSystemNamespace` (default `kube-system`).

By default, DNS egress is allowed to any pod in `dnsNamespace` on port 53. Set `networkPolicy.dnsPodLabels` (e.g. `k8s-app: kube-dns`) to narrow this to your actual DNS pods — the right labels vary by distribution/CNI, so this is opt-in rather than a chart default.

**Vault egress** — when `vaultSecret.enabled=true`, the injected vault-agent shares the pod network namespace. In-cluster Vault (port 8200) requires `networkPolicy.vaultNamespace` (and optional `vaultPodLabels`) with `vaultExternal=false` (default). External/HCP Vault on 443 requires `networkPolicy.vaultExternal=true` plus `allowInternetHttps=true` (default) or explicit `networkPolicy.vaultEgressCidrs` when `allowInternetHttps=false`. `allowInternetHttps` alone does not cover in-cluster Vault on 8200.

**Internet HTTPS egress** is controlled by `networkPolicy.allowInternetHttps` (default `true`). When `true`, the policy adds `0.0.0.0/0:443` and `::/0:443` egress — a broad catch-all suited to SaaS deployments where the gateway endpoint is outside the cluster. When `false`, that rule is omitted for least-privilege egress; gateway traffic must then be allowed explicitly via `gatewayEgressCidrs` and/or `gatewayNamespace`. This applies to on-prem and SaaS alike:

- **On-prem** — set `allowInternetHttps=false` and use `gatewayNamespace` + `gatewayPodLabels`, or list gateway node/LB CIDRs in `gatewayEgressCidrs` at the correct port (3622, 8443, or 443).
- **SaaS** — either keep `allowInternetHttps=true` (default), or set `allowInternetHttps=false` and add your gateway endpoint CIDRs (from onboarding or DNS lookup of `global.gateway.address`) to `gatewayEgressCidrs` with `global.gateway.port: 443`.

### Discover cluster network values

```shell
kubectl get configmap kubeadm-config -n kube-system -o yaml
kubectl get nodes -l node-role.kubernetes.io/control-plane -o wide
kubectl get svc kubernetes -n default -o jsonpath='{.spec.clusterIP}{"\n"}'
```

### Discover managed-cloud apiserver CIDRs

Use these to populate `additionalIngressCidrs` (webhook callers) and `additionalEgressCidrs` (KE client destinations). Use private CIDRs when the control plane has a private endpoint; use endpoint CIDRs from your own cluster output when a public endpoint is enabled.

**EKS**

```shell
# Check endpoint access mode
aws eks describe-cluster --name <cluster> \
  --query 'cluster.resourcesVpcConfig.{endpointPublicAccess:endpointPublicAccess,endpointPrivateAccess:endpointPrivateAccess,vpcId:vpcId}'

# Private endpoint: egress destinations are usually within your VPC CIDR blocks
aws ec2 describe-vpcs --vpc-ids <vpc-id> --query 'Vpcs[].CidrBlock'

# Public endpoint: use the endpoint hostname from describe-cluster output;
# resolve it with your own DNS tool and add the results to additionalEgressCidrs
aws eks describe-cluster --name <cluster> --query 'cluster.endpoint' -o text

# Ingress: apiserver sources are typically within VPC CIDRs or the cluster security group
aws eks describe-cluster --name <cluster> \
  --query 'cluster.resourcesVpcConfig.{subnetIds:subnetIds,securityGroupIds:securityGroupIds}'
```

For private endpoints, add VPC or subnet CIDR blocks to `additionalEgressCidrs`. For public endpoints, add the resolved endpoint addresses from your cluster's describe output.

**GKE**

```shell
# Private endpoint: master CIDR is the egress destination
gcloud container clusters describe <cluster> --location <location> \
  --format='value(privateClusterConfig.masterIpv4CidrBlock)'

# Public endpoint: use the endpoint hostname from describe output;
# resolve it with your own DNS tool and add the results to additionalEgressCidrs
gcloud container clusters describe <cluster> --location <location> --format='value(endpoint)'

# Ingress: authorized networks (apiserver source ranges calling webhooks)
gcloud container clusters describe <cluster> --location <location> \
  --format='value(masterAuthorizedNetworksConfig.cidrBlocks[].cidrBlock)'
```

Add `masterIpv4CidrBlock` to `additionalEgressCidrs` for private clusters. For public endpoints, add resolved endpoint addresses from your cluster output.

**AKS**

```shell
# API server access profile (private endpoint, authorized IP ranges)
az aks show -g <resource-group> -n <cluster> --query apiServerAccessProfile

# API server VNet integration: subnet CIDR is the egress destination
az network vnet subnet show -g <resource-group> --vnet-name <vnet> -n <subnet> \
  --query addressPrefix -o tsv
```

For AKS with API server VNet integration, add the integrated subnet CIDR to `additionalEgressCidrs`. For authorized IP ranges, add those ranges to `additionalIngressCidrs`. When only a public API server is available, use endpoint CIDRs from your cluster's access profile output.

### Example values (on-prem)

```yaml
global:
  gateway:
    address: aqua-gateway-svc.aqua
    port: 8443

networkPolicy:
  enabled: true
  nodeCidr: "10.0.0.0/16"
  podCidr: "10.244.0.0/16"
  serviceCidr: "10.96.0.0/12"
  controlPlaneCidr: "10.0.0.5/32"
  additionalIngressCidrs:
    - "10.0.1.0/24"       # apiserver → KE webhook (example managed-cloud source)
  additionalEgressCidrs:
    - "10.0.2.0/24"       # KE → apiserver (example private endpoint range)
  allowInternetHttps: false
  gatewayNamespace: aqua
  gatewayPodLabels:
    aqua.component: gateway
  # gatewayEgressCidrs only for external/node/LB endpoints — not Service ClusterIP (use gatewayNamespace above)
```

### Example values (on-prem, via in-cluster HTTP proxy)

Use when `extraEnvironmentVars.http_proxy` / `https_proxy` points at an in-cluster proxy (see [Connect to Aqua Saas / Gateway via proxy](#conncet-to-aqua-saas--gateway-via-proxy)). `proxyPort` must match the proxy's listening port.

```yaml
extraEnvironmentVars:
  http_proxy: http://proxy01.proxy.svc.cluster.local:8080
  https_proxy: http://proxy01.proxy.svc.cluster.local:8080
  no_proxy: .svc.cluster.local

networkPolicy:
  enabled: true
  nodeCidr: "10.0.0.0/16"
  podCidr: "10.244.0.0/16"
  serviceCidr: "10.96.0.0/12"
  controlPlaneCidr: "10.0.0.5/32"
  allowInternetHttps: false
  proxyNamespace: proxy
  proxyPort: 8080
  # proxyPodLabels optional — narrows the proxy namespace peer to specific pods
  # proxyEgressCidrs only for external/node-level proxies — not Service ClusterIP (use proxyNamespace above)
```

### Example values (SaaS with explicit gateway CIDRs)

Use when `allowInternetHttps=false` for least-privilege egress instead of the default `0.0.0.0/0:443` rule. Set `global.gateway.address` to the hostname from your onboarding email and `global.gateway.port: 443`. Resolve the hostname with your own DNS lookup and add the returned addresses to `gatewayEgressCidrs` — the placeholder below is private RFC1918 only; substitute your gateway's actual endpoint CIDRs.

```yaml
global:
  gateway:
    address: <gateway_url>
    port: 443

networkPolicy:
  enabled: true
  nodeCidr: "10.0.0.0/16"
  podCidr: "10.244.0.0/16"
  serviceCidr: "10.96.0.0/12"
  controlPlaneCidr: "10.0.0.5/32"
  allowInternetHttps: false
  gatewayEgressCidrs:
    - "10.200.0.10/32"    # placeholder — replace with your gateway endpoint CIDR(s)
```

### Validating NetworkPolicy and webhook reachability

Pod `Ready`, gateway registration logs, and a successful test workload do **not** prove the apiserver can reach the KE admission webhook on port 8443 through the NetworkPolicy. With `webhooks.failurePolicy: Ignore` (the default), webhook failures are silent — workloads are admitted without enforcement.

**Recommended rollout validation**

1. **Temporarily set `webhooks.failurePolicy: Fail`** during NetworkPolicy rollout. A misconfigured ingress rule should cause admission failures on test workloads, making connectivity problems visible immediately.

   ⚠️ **Before doing this**, note that `webhooks.validatingWebhook.namespaceSelector` is empty (`{}`) by default, i.e. cluster-wide, including `kube-system`. If the NetworkPolicy ingress rule is even slightly wrong while `failurePolicy: Fail` is active, the webhook becomes unreachable and **every** resource create/update cluster-wide is rejected — including the changes needed to fix the NetworkPolicy itself. Validate on a non-production cluster first, or scope `webhooks.validatingWebhook.namespaceSelector` to exclude `kube-system` and `kube-node-lease` (see the commented example in `values.yaml`) before switching to `Fail`.
2. **Watch apiserver webhook metrics and events** during rollout:
   - With `webhooks.failurePolicy: Fail` — `apiserver_admission_webhook_rejection_count` (metric name may vary by Kubernetes version; verify on your apiserver `/metrics`) spikes when admission calls are rejected
   - With `webhooks.failurePolicy: Ignore` (default) — blocked webhooks time out and fail open; watch `apiserver_admission_webhook_fail_open_count` instead of the rejection counter
   - Kubernetes events mentioning webhook timeouts or connection failures
3. **Confirm apiserver → KE connectivity on 8443** — not only pod `Ready`:
   - From a node or debug pod with network paths similar to the apiserver, test TCP connectivity to the KE Service ClusterIP or pod IP on port 8443
   - With `failurePolicy: Fail`, create a test workload; admission errors in `kubectl` output confirm webhook reachability (or expose a blocked path)
4. After validation succeeds, revert `webhooks.failurePolicy` to `Ignore` if you prefer availability over fail-closed admission (see tradeoff below).

**`failurePolicy` tradeoff (especially with NetworkPolicy enabled)**

| Policy | On webhook failure | Typical use |
|--------|-------------------|-------------|
| `Ignore` | Workload admitted; enforcement skipped (silent security regression) | Production availability; default in this chart |
| `Fail` | Workload creation/update rejected | Rollout validation; strict enforcement |

When `networkPolicy.enabled=true`, a too-restrictive ingress rule blocks apiserver → KE webhook traffic. With `Ignore`, the deployment can look healthy (pod Ready, gateway registered) while new workloads bypass KubeEnforcer. Use `Fail` temporarily to validate policy rules, then switch back if desired.

## Configuration for KubeEnforcer with cert-manager

   1. Create self-signed `ClusterIssuer` and `Certificate` needed by Aqua:

   ```shell
   kubectl create namespace aqua

   kubectl apply -f - << EOF
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: selfsigned-cluster-issuer
   spec:
     selfSigned: {}
   EOF

   kubectl apply -f - << EOF
   apiVersion: cert-manager.io/v1
   kind: Certificate
   metadata:
     name: aqua-kube-enforcer-certs
     namespace: aqua
   spec:
     commonName: admission_ca
     secretName: aqua-kube-enforcer-certs
     issuerRef:
       name: selfsigned-cluster-issuer
       kind: ClusterIssuer
       group: cert-manager.io
     commonName: aqua-kube-enforcer.aqua.svc
     dnsNames:
     - aqua-kube-enforcer.aqua.svc
     - aqua-kube-enforcer.aqua.svc.cluster.local
     duration: 26280h
     renewBefore: 720h
   EOF
   ```

   2. Install kube-enforcer:

   ```shell
   helm upgrade --install --version "2022.4" --namespace aqua --values - kube-enforcer aqua-helm/kube-enforcer << EOF
   ...
   certsSecret:
     create: true
     name: aqua-kube-enforcer-certs
     serverCertificate: tls.crt
     serverKey: tls.key
   ...
   webhooks:
     certManager: true
   EOF
   ```

## Integrate Kube-Enforcer with Hashicorp Vault to Load Token
* Hashicorp Vault is a secrets management tools.
* Kube-enforcer charts supports to load token values from vault by vault-agent using annotations. To enable the Vault integration enable `vaultSecret.enabled=true`, add vault secret filepath `vaultSecret.vaultFilepath= ""` and uncomment the `vaultAnnotations`.
* When `networkPolicy.enabled=true`, configure Vault egress: `networkPolicy.vaultNamespace` for in-cluster Vault (port 8200, `vaultExternal=false`), or `networkPolicy.vaultExternal=true` with `vaultEgressCidrs` / `allowInternetHttps=true` for HCP/SaaS Vault on 443.
* `vaultAnnotations` - Change the vault annotations according as per your vault setup, Annotations support both self-hosted and SaaS Vault setups.

## Configurable Variables

| Parameter                                                    | Description                                                                                                                                                                                                                                          | Default                                  | Mandatory                                                                                        |
|--------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|--------------------------------------------------------------------------------------------------|
| `global.imageCredentials.create`                             | Set to create new pull image secret                                                                                                                                                                                                                  | `false`                                  | `Yes - New cluster`                                                                              |
| `global.imageCredentials.name`                               | Your Docker pull image secret name                                                                                                                                                                                                                   | `aqua-registry-secret`                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.repositoryUriPrefix`                | Repository uri prefix for dockerhub set `docker.io`                                                                                                                                                                                                  | `registry.aquasec.com`                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.registry`                           | Set the registry url for dockerhub set `index.docker.io/v1/`                                                                                                                                                                                         | `registry.aquasec.com`                   | `Yes - New cluster`                                                                              |
| `global.imageCredentials.username`                           | Your Docker registry (Docker Hub, etc.) username                                                                                                                                                                                                     | `N/A`                                    | `Yes - New cluster`                                                                              |
| `global.imageCredentials.password`                           | Your Docker registry (Docker Hub, etc.) password                                                                                                                                                                                                     | `N/A`                                    | `Yes - New cluster`                                                                              |
| `serviceAccount.create`                                      | Enable to create serviceAccount                                                                                                                                                                                                                      | `true`                                   | `Yes - New cluster`                                                                              |
| `serviceAccount.attachImagePullSecret`                       | Attach image pull secret to created service account                                                                                                                                                                                                  | `true`                                   | `NO`                                                                                             |
| `serviceAccount.name`                                        | Service account name                                                                                                                                                                                                                                 | `aqua-kube-enforcer-sa`                  | `No`                                                                                             |
| `global.platform`                                            | Specify the Kubernetes (k8s) platform acronym, allowed values are: aks, eks, gke, gke-autopilot, openshift, tkg, tkgi, k8s, rancher, gs, k3s, mke.                                                                                                   | `unset`                                  | `YES`                                                                                            |
| `global.enforcer.enabled`                                    | Change to true to enable express mode and deploy aqua enforcer along with kube-enforcer                                                                                                                                                              | `false`                                  | `NO`                                                                                             |
| `global.gateway.address`                                     | Gateway host address. For Saas use the hostname containing `-gw` from your onboarding email.                                                                                                                                                         | `aqua-gateway-svc.aqua`                  | `Yes`                                                                                            |
| `global.gateway.port`                                        | Gateway host port. Far Saas use port 443                                                                                                                                                                                                             | `8443`                                   | `Yes`                                                                                            |
| `aqua_enable_cache`                                          | Set this to yes to enable caching for the KubeEnforcer; this can improve performance in clusters with high traffic                                                                                                                                   | `yes`                                    | `Yes`                                                                                            |
| `aqua_cache_expiration_period`                               | If caching is enabled, you can adjust the cache refresh time. This defaults to 60 seconds                                                                                                                                                            | `60`                                     | `Yes` </br> `if aqua_enable_cache enabled`                                                       |
| `ke_ReplicaCount`                                            | Kube-enforcer replica count                                                                                                                                                                                                                          | `1`                                      | `No`                                                                                             |
| `image.repository`                                           | Kube-enforcer docker image name to use                                                                                                                                                                                                               | `kube-enforcer`                          | `Yes`                                                                                            |
| `image.tag`                                                  | Kube-enforcer image tag to use.                                                                                                                                                                                                                      | `2022.4`                                 | `Yes`                                                                                            |
| `image.pullPolicy`                                           | The kubernetes image pull policy.                                                                                                                                                                                                                    | `Always`                                 | `Yes`                                                                                            |
| `hostNetwork`                                                | Set pod hostNetwork                                                                                                                                                                                                                                  | `false`                                  | `NO`                                                                                             |
| `dnsPolicy`                                                  | Set pod dnsPolicy                                                                                                                                                                                                                                    | `ClusterFirst`                           | `NO`                                                                                             |
| `networkPolicy.enabled`                                      | Enable optional NetworkPolicy for kube-enforcer                                                                                                                                                                                                      | `false`                                  | `No`                                                                                             |
| `networkPolicy.nodeCidr`                                     | Worker node CIDR (IPv4)                                                                                                                                                                                                                              | `""`                                     | `Yes` </br> `if networkPolicy.enabled`                                                           |
| `networkPolicy.nodeCidrV6`                                   | Optional IPv6 worker node CIDR for dual-stack clusters                                                                                                                                                                                               | `""`                                     | `No`                                                                                             |
| `networkPolicy.podCidr`                                      | Pod CIDR (IPv4)                                                                                                                                                                                                                                      | `""`                                     | `Yes` </br> `if networkPolicy.enabled`                                                           |
| `networkPolicy.podCidrV6`                                    | Optional IPv6 pod CIDR for dual-stack clusters                                                                                                                                                                                                       | `""`                                     | `No`                                                                                             |
| `networkPolicy.serviceCidr`                                  | Service CIDR (egress to in-cluster `kubernetes` Service on port 443; kubeadm/kube-proxy path). Omit on managed clouds — use `additionalEgressCidrs` instead                                                                                        | `""`                                     | `No`                                                                                             |
| `networkPolicy.serviceCidrV6`                                | Optional IPv6 service CIDR for dual-stack clusters                                                                                                                                                                                                   | `""`                                     | `No`                                                                                             |
| `networkPolicy.controlPlaneCidr`                             | Control-plane node IP or CIDR (apiserver webhook ingress on 8443; in-cluster API egress on port 6443). Omit on managed clouds when using `additional*Cidrs`                                                                                          | `""`                                     | `No`                                                                                             |
| `networkPolicy.controlPlaneCidrV6`                           | Optional IPv6 control-plane CIDR for dual-stack clusters                                                                                                                                                                                             | `""`                                     | `No`                                                                                             |
| `networkPolicy.additionalIngressCidrs`                       | Extra ingress CIDRs for apiserver → KE webhook (8443) and kubelet probes (readinessProbe/livenessProbe port, default 8080); managed-cloud sources not covered by node/pod/control-plane CIDRs                                                       | `[]`                                     | `No`                                                                                             |
| `networkPolicy.additionalEgressCidrs`                        | Extra egress CIDRs for KE → apiserver (managed-cloud endpoint IPs after DNAT). Flat CIDR strings use ports 443 and 6443; objects support `{cidr, ports}` (ports default to 443 and 6443 when omitted) | `[]`                                     | `No`                                                                                             |
| `networkPolicy.allowInternetHttps`                           | Add `0.0.0.0/0:443` and `::/0:443` egress (default SaaS catch-all). Set `false` for least-privilege egress; use `gatewayEgressCidrs` / `gatewayNamespace` for gateway traffic                                                                        | `true`                                   | `No`                                                                                             |
| `networkPolicy.gatewayEgressCidrs`                           | External gateway, node, or LB CIDRs (not in-cluster Service ClusterIP); uses `global.gateway.port`                                                                                                                                                   | `[]`                                     | `Yes` </br> `if networkPolicy.enabled` and `global.gateway.port` ≠ 443 and neither `gatewayNamespace` nor `allowInternetHttps` covers gateway |
| `networkPolicy.gatewayNamespace`                             | In-cluster gateway namespace (preferred over Service ClusterIP on Calico-style CNIs)                                                                                                                                                                 | `""`                                     | `Yes` </br> `if networkPolicy.enabled` and `global.gateway.port` ≠ 443 and `gatewayEgressCidrs` empty and `allowInternetHttps` does not cover gateway |
| `networkPolicy.gatewayPodLabels`                             | Pod labels matched with `gatewayNamespace` (required when `gatewayNamespace` is set)                                                                                                                                                                 | `aqua.component: gateway`                | `Yes` </br> `if gatewayNamespace` is set                                                         |
| `networkPolicy.proxyNamespace`                               | In-cluster HTTP proxy namespace (see `extraEnvironmentVars.http_proxy`/`https_proxy`); requires `proxyPort`                                                                                                                                          | `""`                                     | `Yes` </br> `if extraEnvironmentVars` sets `http_proxy`/`https_proxy` and `proxyEgressCidrs` empty |
| `networkPolicy.proxyPodLabels`                                | Optional pod labels matched with `proxyNamespace`                                                                                                                                                                                                    | `{}`                                     | `No`                                                                                             |
| `networkPolicy.proxyEgressCidrs`                              | External/node-level HTTP proxy CIDRs; requires `proxyPort`                                                                                                                                                                                           | `[]`                                     | `Yes` </br> `if extraEnvironmentVars` sets `http_proxy`/`https_proxy` and `proxyNamespace` empty |
| `networkPolicy.proxyPort`                                     | HTTP proxy listening port                                                                                                                                                                                                                             | `""`                                     | `Yes` </br> `if proxyNamespace` or `proxyEgressCidrs` is set                                      |
| `networkPolicy.vaultNamespace`                               | In-cluster Vault namespace for vault-agent egress on `vaultPort` (8200)                                                                                                                                                                              | `""`                                     | `Yes` </br> `if vaultSecret.enabled`, `networkPolicy.enabled`, and `vaultExternal=false` (default) |
| `networkPolicy.vaultExternal`                                | `true`: external/HCP Vault on 443 — use `allowInternetHttps` or `vaultEgressCidrs`. `false`: in-cluster Vault — requires `vaultNamespace`                                                                                                            | `false`                                  | `No`                                                                                             |
| `networkPolicy.vaultPodLabels`                             | Optional pod labels matched with `vaultNamespace`                                                                                                                                                                                                    | `{}`                                     | `No`                                                                                             |
| `networkPolicy.vaultPort`                                    | In-cluster Vault API port                                                                                                                                                                                                                            | `8200`                                   | `No`                                                                                             |
| `networkPolicy.vaultEgressCidrs`                             | External/HCP Vault endpoint CIDRs; uses `vaultEgressPort`                                                                                                                                                                                            | `[]`                                     | `Yes` </br> `if vaultSecret.enabled`, `networkPolicy.enabled`, `vaultExternal=true`, and `allowInternetHttps=false` |
| `networkPolicy.vaultEgressPort`                              | External/HCP Vault API port                                                                                                                                                                                                                          | `443`                                    | `No`                                                                                             |
| `networkPolicy.dnsNamespace`                                 | Namespace for DNS egress (UDP/TCP 53). Default `kube-system`; auto `openshift-dns` when `global.platform=openshift`                                                                                                                                  | `kube-system`                            | `No`                                                                                             |
| `networkPolicy.dnsPodLabels`                                 | Optional pod labels to narrow DNS egress within `dnsNamespace` (e.g. `k8s-app: kube-dns`); unset allows the whole namespace on port 53                                                                                                              | `{}`                                     | `No`                                                                                             |
| `networkPolicy.ingressSystemNamespace`                       | Namespace for ingress from apiserver proxy pods (e.g. GKE konnectivity). Default `kube-system`; independent of `dnsNamespace`                                                                                                                        | `kube-system`                            | `No`                                                                                             |
| `microEnforcerImage.repository`                              | MicroEnforcer docker image name                                                                                                                                                                                                                      | `microenforcer`                          | `YES`                                                                                            |
| `microEnforcerImage.tag`                                     | MicroEnforcer docker image tag                                                                                                                                                                                                                       | `2022.4`                                 | `YES`                                                                                            |
| `kubebenchImage.repository`                                  | KubeBench docker image name                                                                                                                                                                                                                          | `aquasec/kube-bench`                     | `YES`                                                                                            |
| `kubebenchImage.tag`                                         | KubeBench docker image tag                                                                                                                                                                                                                           | `v0.6.8`                                 | `YES`                                                                                            |
| `clusterName`                                                | Cluster name registered with Aqua in Infrastructure tab                                                                                                                                                                                              | `aqua-secure`                            | `No`                                                                                             |
| `enforcer_ds_name`                                           | AquaEnforcer DaemonSet name for KubEnforcer config map                                                                                                                                                                                               | ``                                       | `No`                                                                                             |
| `logicalName`                                                | This variable is used in conjunction with the KubeEnforcer group logical name to determine how the KubeEnforcer name will be displayed in the Aqua UI                                                                                                | `""`                                     | `No`                                                                                             |
| `logLevel`                                                   | Setting this might be helpful for problem determination. Acceptable values are DEBUG, INFO, WARN, and ERROR                                                                                                                                          | `""`                                     | `No`                                                                                             |
| `certsSecret.create`                                         | Set to create a new secret for TLS authentication with the Kubernetes api-server, Change to false if you're using existing server certificate secret                                                                                                 | `true`                                   | `Yes`                                                                                            |
| `certsSecret.annotations`                                    | Add annotations to secret created for KE                                                                                                                                                                                                             | ``                                       | `No`                                                                                             |
| `certsSecret.autoGenerate`                                   | Set to automatically generate self-signed secret for TLS authentication with the Kubernetes api-server, Change to false if you're using existing server certificate secret                                                                           | `false`                                  | `No`                                                                                             |
| `certsSecret.name`                                           | Secret name for TLS authentication with the Kubernetes api-server, Change secret name if already exists with server/web public certificate                                                                                                           | `aqua-kube-enforcer-certs`               | `Yes`                                                                                            |
| `certsSecret.serverCertificate`                              | Public certificate for TLS authentication with the Kubernetes api-server, If certsSecret.create is enable to true, Add base64 value of the Public Certificate(server certificate) or add filename of certificate if it is loading from custom secret | `N/A`                                    | `Yes`                                                                                            |
| `certsSecret.serverKey`                                      | Certificate key for TLS authentication with the Kubernetes api-server, If certsSecret.create is enable to true, Add base64 value of the Private Key(server key) or add filename of key if it is loading from custom secret                           | `N/A`                                    | `Yes`                                                                                            |
| `dnsNdots`                                                   | Modifies ndots DNS configuration for the deployment                                                                                                                                                                                                  | `unset`                                  | `NO`                                                                                             |
| `vaultSecret.enabled`                                         | Enable to true once you have secrets in vault and annotations are enabled to load enforcer token from hashicorp vault                                                                                                                                | `false`                                  | `No`                                                                                             |
| `vaultSecret.vaultFilepath`                                  | Change the path to "/vault/secrets/<filename>" as per the setup                                                                                                                                                                                      | `""`                                     | `No`                                                                                             |
| `aquaSecret.create`                                          | Aqua KubeEnforcer (KE) token secret creation                                                                                                                                                                                                         | `true`                                   | `Yes`                                                                                            |
| `aquaSecret.name`                                            | Aqua KubeEnforcer (KE) token secret name                                                                                                                                                                                                             | `aqua-kube-enforcer-token`               | `Yes`                                                                                            |
| `aquaSecret.kubeEnforcerToken`                               | Aqua KubeEnforcer (KE) token                                                                                                                                                                                                                         | `ke-token`                               | `Yes`                                                                                            |
| `clusterRole.name`                                           | KE cluster role name                                                                                                                                                                                                                                 | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `clusterRole.usingPodEnforcer`                               | Controls if the create, delete, and update verbs will be used.                                                                                                                                                                                       | `true`                                   | `Yes`                                                                                            |
| `clusterRoleBinding.name`                                    | KE cluster roleBinding name                                                                                                                                                                                                                          | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `role.name`                                                  | KE role name                                                                                                                                                                                                                                         | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `roleBinding.name`                                           | KE roleBinding name                                                                                                                                                                                                                                  | `aqua-kube-enforcer`                     | `Yes`                                                                                            |
| `webhooks.certManager`                                       | Enable to true if using KE webhook certificates generated from kubernetes cert-manager                                                                                                                                                               | `false`                                  | `No`                                                                                             |
| `webhooks.caBundle`                                          | Root certificate for TLS authentication with the Kubernetes api-server, Add base64 value of the CA cert/Ca Bundle/RootCA Cert if certificates are not generated from cert-manager to webhooks.caBundle                                               | `N/A`                                    | `Yes` </br> `if webhooks.certManager is false`                                                   |
| `webhooks.failurePolicy`                                     | Webhook failure policy (`Ignore` or `Fail`). Default `Ignore` admits workloads when the webhook is unreachable — see [Validating NetworkPolicy and webhook reachability](#validating-networkpolicy-and-webhook-reachability) for rollout validation with `Fail` | `Ignore`                                 | `Yes`                                                                                            |
| `webhooks.validatingWebhook.name`                            | KE validating webhook name                                                                                                                                                                                                                           | `kube-enforcer-admission-hook-config`    | `Yes`                                                                                            |
| `webhooks.validatingWebhook.timeout`                         | KE validating webhook timeout                                                                                                                                                                                                                        | `2`                                      | `Yes`                                                                                            |
| `webhooks.validatingWebhook.annotations`                     | KE validating webhook annotations                                                                                                                                                                                                                    | `{}`                                     | `No`                                                                                             |
| `webhooks.mutatingWebhook.name`                              | KE mutating webhook name                                                                                                                                                                                                                             | `kube-enforcer-me-injection-hook-config` | `Yes`                                                                                            |
| `webhooks.mutatingWebhook.timeout`                           | KE mutating webhook timeout                                                                                                                                                                                                                          | `2`                                      | `Yes`                                                                                            |
| `webhooks.mutatingWebhook.annotations`                       | KE mutating webhook annotations                                                                                                                                                                                                                      | `{}`                                     | `No`                                                                                             |
| `container_securityContext`                                  | KE container security context                                                                                                                                                                                                                        | `{}`                                     | `No`                                                                                             |
| `resources`                                                  | KE Resource requests and limits                                                                                                                                                                                                                      | `{}`                                     | `No`                                                                                             |
| `nodeSelector`                                               | Kubernetes node selector	                                                                                                                                                                                                                            | `{}`                                     | `No`                                                                                             |
| `tolerations`                                                | Kubernetes node tolerations	                                                                                                                                                                                                                         | `[]`                                     | `No`                                                                                             |
| `podAnnotations`                                             | Kubernetes pod annotations                                                                                                                                                                                                                           | `{}`                                     | `No`                                                                                             |
| `deploymentAnnotations`                                             | Kubernetes deployment annotations                                                                                                                                                                                                                           | `{}`                                     | `No`                                                                                             |
| `pdbApiVersion`                                              | Override the API Version of PodDisruptionBudget                                                                                                                                                                                                      | `{}`                                     | `No`                                                                                             |
| `affinity`                                                   | Kubernetes node affinity                                                                                                                                                                                                                             | `{}`                                     | `No`                                                                                             |
| `priorityClass.create`                                       | If true priority class will be created                                                                                                                                                                                                               | `False`                                  | `NO`                                                                                             |
| `priorityClass.name`                                         | Define the name of priority class or default value will be used                                                                                                                                                                                      | ``                                       | `NO`                                                                                             |
| `priorityClass.preemptionPolicy`                             | Preemption policy for priority class                                                                                                                                                                                                                 | `PreemptLowerPriority`                   | `NO`                                                                                             |
| `priorityClass.value`                                        | `The integer value of the priority`                                                                                                                                                                                                                  | `1000000`                                | `NO`                                                                                             |
| `TLS.enabled`                                                | If require secure channel communication                                                                                                                                                                                                              | `false`                                  | `No`                                                                                             |
| `TLS.secretName`                                             | Certificates secret name                                                                                                                                                                                                                             | `nil`                                    | `No`                                                                                             |
| `TLS.publicKey_fileName`                                     | Filename of the public key eg: aqua_ke.crt                                                                                                                                                                                                           | `nil`                                    | `Yes` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.privateKey_fileName`                                    | Filename of the private key eg: aqua_ke.key                                                                                                                                                                                                          | `nil`                                    | `Yes` <br /> `if gate.TLS.enabled is set to true`                                                |
| `TLS.rootCA_fileName`                                        | Filename of the rootCA, if using self-signed certificates eg: rootCA.crt                                                                                                                                                                             | `nil`                                    | `No` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `trivy.enabled`                                              | Trivy Operator deployment. Default scanner for KubeEnforcer                                                                                                                                                                                           | `true`                                   | `No`                                                                                             |
| `trivy.appName`                                              | Trivy Operator application name                                                                                                                                                                                                                        | `trivy-operator`                         | `Yes`                                                                                            |
| `trivy.image.registry`                                       | Trivy Operator image registry                                                                                                                                                                                                                          | `docker.io/aquasec`                      | `Yes`                                                                                            |
| `trivy.image.repository`                                     | Trivy Operator image repository                                                                                                                                                                                                                        | `trivy-operator`                         | `Yes`                                                                                            |
| `trivy.image.tag`                                            | Trivy Operator image tag                                                                                                                                                                                                                               | `0.31.1`                                 | `Yes`                                                                                            |
| `trivy.image.pullPolicy`                                     | Trivy Operator image pull policy                                                                                                                                                                                                                       | `IfNotPresent`                           | `Yes`                                                                                            |
| `trivy.image.secretName`                                     | Secret name used to pull Trivy Operator image from a private registry                                                                                                                                                                                 | `""`                                     | `No`                                                                                             |
| `trivy.replicaCount`                                         | Trivy Operator replica count                                                                                                                                                                                                                           | `1`                                      | `Yes`                                                                                            |
| `trivy.ports.metricContainerPort`                            | Trivy Operator metrics port                                                                                                                                                                                                                            | `8080`                                   | `Yes`                                                                                            |
| `trivy.ports.probeContainerPort`                             | Trivy Operator health probe port                                                                                                                                                                                                                       | `9090`                                   | `Yes`                                                                                            |
| `trivy.serviceAccount.create`                                | Create Trivy Operator service account                                                                                                                                                                                                                  | `true`                                   | `No`                                                                                             |
| `trivy.serviceAccount.name`                                  | Trivy Operator service account name                                                                                                                                                                                                                    | `trivy-operator`                         | `Yes`                                                                                            |
| `trivy.resources`                                            | Trivy Operator resources                                                                                                                                                                                                                               | `{}`                                     | `No`                                                                                             |
| `trivy.nodeSelector`                                         | Trivy Operator node selectors                                                                                                                                                                                                                          | `{}`                                     | `No`                                                                                             |
| `trivy.securityContext`                                      | Trivy Operator pod security context                                                                                                                                                                                                                    | `{}`                                     | `No`                                                                                             |
| `starboard.enabled`                                          | Starboard deployment                                                                                                                                                                                                                                 | `false`                                  | `No`                                                                                             |
| `starboard.crds.enabled`                                     | Starboard CRDs installation                                                                                                                                                                                                                          | `true`                                   | `No`                                                                                             |
| `starboard.replicaCount`                                     | Starboard replica count                                                                                                                                                                                                                              | `1`                                      | `Yes`                                                                                            |
| `starboard.appName`                                          | Starboard application name                                                                                                                                                                                                                           | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.serviceAccount.name`                              | Starboard service account                                                                                                                                                                                                                            | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.serviceAccount.attachImagePullSecret`             | Attach image pull secret to created service account                                                                                                                                                                                                  | `true`                                   | `No`                                                                                             |
| `starboard.clusterRoleBinding.name`                          | Starboard cluster binding name                                                                                                                                                                                                                       | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.clusterRole.name`                                 | Starboard cluster role name                                                                                                                                                                                                                          | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.image.repositoryUriPrefix`                        | Starboard image repository URI                                                                                                                                                                                                                       | `docker.io/aquasec`                      | `Yes`                                                                                            |
| `starboard.image.repository`                                 | Starboard image name                                                                                                                                                                                                                                 | `starboard-operator`                     | `Yes`                                                                                            |
| `starboard.tag`                                              | Starboard image tag                                                                                                                                                                                                                                  | `0.13.0`                                 | `Yes`                                                                                            |
| `starboard.pullPolicy`                                       | Starboard image pullPolicy                                                                                                                                                                                                                           | `Always`                                 | `Yes`                                                                                            |
| `starboard.OPERATOR_TARGET_NAMESPACES`                       | This determines the installation mode, which in turn determines the multi-tenancy support of the operator                                                                                                                                            | `(blank)`                                | `Yes` <br> `(blank string)=> ALLNAMESPACES, foo,bar.baz => specific NAMESPACES`                  |
| `starboard.OPERATOR_EXCLUDE_NAMESPACES`                      | This will ensure that Starboard exclude the namespaces during evaluations                                                                                                                                                                            | `kube-system`                            | `Yes` <br> `(blank string)=> NO NAMESPACES, foo,bar.baz => specific NAMESPACES`                  |
| `starboard.OPERATOR_LOG_DEV_MODE`                            | The flag to use (or not use) development mode (more human-readable output, extra stack traces and logging information, etc.)                                                                                                                         | `false`                                  | `Yes`                                                                                            |
| `starboard.OPERATOR_CONCURRENT_SCAN_JOBS_LIMIT`              | The maximum number of scan jobs create by the operator                                                                                                                                                                                               | `10`                                     | `Yes`                                                                                            |
| `starboard.OPERATOR_SCAN_JOB_RETRY_AFTER`                    | The time to wait before retrying a failed scan job                                                                                                                                                                                                   | `30s`                                    | `Yes`                                                                                            |
| `starboard.OPERATOR_METRICS_BIND_ADDRESS`                    | The TCP address to bind to for serving Prometheus metrics. It can be set to 0 to disable the metrics serving.                                                                                                                                        | `:8080`                                  | `Yes`                                                                                            |
| `starboard.OPERATOR_HEALTH_PROBE_BIND_ADDRESS`               | The TCP address to bind to for serving health probes, i.e., the /healthz/ and /readyz/ endpoints                                                                                                                                                     | `:9090`                                  | `true`                                                                                           |
| `starboard.OPERATOR_CIS_KUBERNETES_BENCHMARK_ENABLED`        | The flag to enable CIS Kubernetes Benchmark scanning                                                                                                                                                                                                 | `false`                                  | `Yes, but should always remain false`                                                            |
| `starboard.OPERATOR_VULNERABILITY_SCANNER_ENABLED`           | The flag to enable vulnerability scanner                                                                                                                                                                                                             | `false`                                  | `Yes, but should always remain false`                                                            |
| `starboard.OPERATOR_BATCH_DELETE_LIMIT`                      | The maximum number of config audit reports deleted by the operator when the plugin's config has changed                                                                                                                                              | `10`                                     | `Yes`                                                                                            |
| `starboard.OPERATOR_BATCH_DELETE_DELAY`                      | The time to wait before deleting another batch of config audit reports                                                                                                                                                                               | `10s`                                    | `Yes`                                                                                            |
| `starboard.nodeSelector`                                     | NodeSelectors to be added to the Starboard Operator Deployment                                                                                                                                                                                       | `false`                                  | `No`                                                                                             |
| `kubeEnforcerAdvance.enable`                                 | Advanced KubeEnforcer deployment                                                                                                                                                                                                                     | `false`                                  | `No`                                                                                             |
| `kubeEnforcerAdvance.nodeID`                                 | Envoy Node ID of the advance KE deployment                                                                                                                                                                                                           | `envoy`                                  | `Yes - if kubeEnforcerAdvance.enable`                                                            |
| `kubeEnforcerAdvance.envoy.image.repository`                 | Envoy image repository for KE advance deployment                                                                                                                                                                                                     | `envoy`                                  | `Yes`                                                                                            |
| `kubeEnforcerAdvance.envoy.image.tag`                        | Envoy image tag for KE advance deployment                                                                                                                                                                                                            | `2022.4`                                 | `Yes`                                                                                            |
| `kubeEnforcerAdvance.envoy.image.pullPolicy`                 | Envoy image pull policy for KE advance deployment                                                                                                                                                                                                    | `Always`                                 | `Yes - if kubeEnforcerAdvance.enable`                                                            |
| `kubeEnforcerAdvance.envoy.TLS.listener.enabled`             | If require secure channel communication                                                                                                                                                                                                              | `false`                                  | `No`                                                                                             |
| `kubeEnforcerAdvance.envoy.TLS.listener.secretName`          | Certificates secret name                                                                                                                                                                                                                             | `nil`                                    | `No`                                                                                             |
| `kubeEnforcerAdvance.envoy.TLS.listener.publicKey_fileName`  | Filename of the public key eg: aqua_envoy.crt                                                                                                                                                                                                        | `nil`                                    | `Yes`  <br /> `if gate.TLS.enabled is set to true`                                               |
| `kubeEnforcerAdvance.envoy.TLS.listener.privateKey_fileName` | Filename of the private key eg: aqua_envoy.key                                                                                                                                                                                                       | `nil`                                    | `Yes` <br /> `if gate.TLS.enabled is set to true`                                                |
| `kubeEnforcerAdvance.envoy.TLS.listener.rootCA_fileName`     | Filename of the rootCA, if using self-signed certificates eg:                                                                                                                                                                                        | rootCA.crt                               | `No` <br /> `if gate.TLS.enabled is set to true and using self-signed certificates for TLS/mTLS` |
| `kubeEnforcerAdvance.envoy.resources`                        | Envoy resources                                                                                                                                                                                                                                      | `{}`                                     | `Yes - if kubeEnforcerAdvance.enable`                                                            |
## Issues and feedback

If you encounter any problems or would like to give us feedback on this deployment, we encourage you to raise issues here on GitHub.
