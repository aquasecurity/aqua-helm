node:
  cluster: {{ .Values.clusterName | default "k8s" }}
  id: {{ .Values.kubeEnforcerAdvance.nodeID | default "envoy" }}

dynamic_resources:
  cds_config:
    path: /etc/aquasec/envoy/cds.yaml
    initial_fetch_timeout: 0s
  lds_config:
    path: /etc/envoy/lds.yaml