{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kube-enforcer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kube-enforcer.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
If .Values.serviceAccount.create set to false and .Values.serviceAccount.name not defined
Will be use serviceAccount with name "aqua-kube-enforcer-sa" - the default serviceAccount
for kube-enforcer chart.
Else if .Values.serviceAccount.create set to true, so will becreate serviceAccount based on
.Values.serviceAccount.name or will be generated name based on Chart Release name
*/}}
{{- define "serviceAccount" -}}
{{- if .Values.serviceAccount.create -}}
    {{ .Values.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- else if not .Values.serviceAccount.create -}}
    {{ .Values.serviceAccount.name | default (printf "aqua-kube-enforcer-sa") }}
{{- end -}}
{{- end -}}

{{- define "serviceAccountStarboard" -}}
{{- if .Values.starboard.serviceAccount.create -}}
    {{ .Values.starboard.serviceAccount.name | default (printf "%s-starboard-sa" .Release.Name) }}
{{- else if not .Values.starboard.serviceAccount.create -}}
    {{ .Values.starboard.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- end -}}
{{- end -}}

{{- define "registrySecret" -}}
{{- if .Values.global.imageCredentials.create -}}
    {{ .Values.global.imageCredentials.name | default (printf "%s-registry-secret" .Release.Name) }}
{{- else if not .Values.global.imageCredentials.create -}}
    {{ .Values.global.imageCredentials.name | default (printf "aqua-registry-secret") }}
{{- end -}}
{{- end -}}

{{- define "priorityClass" -}}
{{- if .Values.priorityClass.create -}}
    {{ .Values.priorityClass.name | default (printf "%s-kube-enforcer-priority-class" .Release.Name) }}
{{- else if not .Values.priorityClass.create -}}
    {{ .Values.priorityClass.name | default (printf "%s-kube-enforcer-priority-class" .Release.Name) }}
{{- end -}}
{{- end -}}

{{- define "starboardPriorityClass" -}}
{{- if .Values.starboard.priorityClass.create -}}
    {{ .Values.starboard.priorityClass.name | default (printf "%s-starboard-priority-class" .Release.Name) }}
{{- else if not .Values.starboard.priorityClass.create -}}
    {{ .Values.starboard.priorityClass.name | default (printf "%s-starboard-priority-class" .Release.Name) }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-enforcer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.global.imageCredentials.registry entry required" .Values.global.imageCredentials.registry) (printf "%s:%s" (default "A valid .Values.global.imageCredentials.username entry" .Values.global.imageCredentials.username) (default "A valid .Values.global.imageCredentials.password entry" .Values.global.imageCredentials.password) | b64enc) | b64enc }}
{{- end }}

{{- define "serverCertificate" }}
{{- printf "%s" (required "A valid .Values.certsSecret.serverCertificate entry required" .Values.certsSecret.serverCertificate) | replace "\n" "" }}
{{- end }}

{{- define "serverKey" }}
{{- printf "%s" (required "A valid .Values.certsSecret.serverKey entry required" .Values.certsSecret.serverKey) | replace "\n" "" }}
{{- end }}

{{- define "caBundle" }}
{{- printf "%s" (required "A valid .Values.webhooks.caBundle entry required" .Values.webhooks.caBundle) | replace "\n" "" }}
{{- end }}

{{- define "certsSecret_name" }}
{{- printf "%s" (required "A valid .Values.certsSecret.name required" .Values.certsSecret.name ) }}
{{- end }}

{{- define "imageCredentials_name" }}
{{- printf "%s" (required "A valid .Values.global.imageCredentials.name required" .Values.global.imageCredentials.name ) }}
{{- end }}

{{- define "platform" }}
{{- $platform := .Values.global.platform }}
{{- if not $platform }}
{{-   fail "A valid .Values.global.platform entry is required.\nPlease provide one of the following options: aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s, mke" }}
{{- end }}
{{- end }}

{{- define "networkPolicy.dnsNamespace" -}}
{{- if .Values.networkPolicy.dnsNamespace -}}
{{- .Values.networkPolicy.dnsNamespace -}}
{{- else if or (eq .Values.global.platform "openshift") (.Capabilities.APIVersions.Has "route.openshift.io/v1") -}}
openshift-dns
{{- else -}}
kube-system
{{- end -}}
{{- end -}}

{{- define "networkPolicy.ingressSystemNamespace" -}}
{{- if .Values.networkPolicy.ingressSystemNamespace -}}
{{- .Values.networkPolicy.ingressSystemNamespace -}}
{{- else -}}
kube-system
{{- end -}}
{{- end -}}

{{- define "networkPolicy.ipBlock" -}}
{{- if not (or .cidr .cidrV6) }}
{{- fail "networkPolicy ipBlock requires cidr or cidrV6" }}
{{- end }}
{{- if .cidr }}
- ipBlock:
    cidr: {{ .cidr | quote }}
{{- end }}
{{- if .cidrV6 }}
- ipBlock:
    cidr: {{ .cidrV6 | quote }}
{{- end }}
{{- end -}}

{{/*
Fails with a clear message if the given port value isn't a plain non-negative integer,
instead of letting sprig's `int` filter silently coerce a bad value (e.g. a named port,
which NetworkPolicyPort doesn't support here) into 0. Returns the value unchanged so callers
pipe the result into `| int`.
*/}}
{{- define "networkPolicy.validatedPort" -}}
{{- if not (regexMatch "^[0-9]+$" (.value | toString)) }}
{{- fail (printf "%s must be a numeric port (got %v); named ports are not supported" .label .value) }}
{{- end }}
{{- .value -}}
{{- end -}}

{{/*
An egress "to" peer targeting a namespace by name, with an optional pod-label selector to
narrow it, on a single TCP port. Renders nothing if .namespace is unset. Shared by the
gateway/proxy/vault in-cluster egress rules, which are otherwise identical apart from field
names.
*/}}
{{- define "networkPolicy.namespaceEgress" -}}
{{- if .namespace }}
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ .namespace | quote }}
          {{- if .podLabels }}
          {{- if not (kindIs "map" .podLabels) }}
          {{- fail (printf "%s must be a map of pod labels" .podLabelsField) }}
          {{- end }}
          podSelector:
            matchLabels:
              {{- toYaml .podLabels | nindent 14 }}
          {{- end }}
      ports:
        - protocol: TCP
          port: {{ .port }}
    {{- end }}
{{- end -}}

{{/*
Egress "to" a list of CIDRs on a single TCP port. Renders nothing if .cidrs is empty. Shared
by the gateway/proxy/vault external-egress rules.
*/}}
{{- define "networkPolicy.cidrListEgress" -}}
{{- if .cidrs }}
    - to:
        {{- range .cidrs }}
        - ipBlock:
            cidr: {{ . | quote }}
        {{- end }}
      ports:
        - protocol: TCP
          port: {{ .port }}
    {{- end }}
{{- end -}}

{{/*
Extracts a single probe's configured port from httpGet/tcpSocket/grpc (whichever is set),
as a string, or "" if the probe is nil, has no network port (e.g. an exec probe), or is
pinned to the sentinel "0", which is never a valid NetworkPolicyPort.
*/}}
{{- define "networkPolicy.probePort" -}}
{{- $port := "" -}}
{{- with . }}
{{- with .httpGet }}{{- if .port }}{{- $port = (.port | toString) -}}{{- end -}}{{- end -}}
{{- with .tcpSocket }}{{- if .port }}{{- $port = (.port | toString) -}}{{- end -}}{{- end -}}
{{- with .grpc }}{{- if .port }}{{- $port = (.port | toString) -}}{{- end -}}{{- end -}}
{{- end -}}
{{- if and $port (not (regexMatch "^[0-9]+$" $port)) }}
{{- fail (printf "probe port %q must be numeric; this chart's container ports aren't named, so a named port here can never match" $port) }}
{{- end -}}
{{- if eq $port "0" }}{{- $port = "" -}}{{- end -}}
{{- $port -}}
{{- end -}}

{{/*
The readinessProbe/livenessProbe pair actually driving kube-enforcer's health checks — the
envoy sidecar's probes in kubeEnforcerAdvance mode, the container's own otherwise. Both
networkPolicy.probePorts and kube-enforcer.healthMonitorPort call this so they can't drift
apart on which probe pair they read. `include` only returns rendered text, so the pair is
passed through as YAML and parsed back into a dict.
*/}}
{{- define "networkPolicy.effectiveProbes" -}}
{{- if .Values.kubeEnforcerAdvance.enable -}}
{{- dict "readinessProbe" .Values.kubeEnforcerAdvance.envoy.readinessProbe "livenessProbe" .Values.kubeEnforcerAdvance.envoy.livenessProbe | toYaml -}}
{{- else -}}
{{- dict "readinessProbe" .Values.readinessProbe "livenessProbe" .Values.livenessProbe | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Kubelet health-probe ports actually configured on the kube-enforcer container (or, in
kubeEnforcerAdvance mode, on the envoy sidecar), so NetworkPolicy ingress tracks
readinessProbe/livenessProbe instead of assuming 8080. If neither probe exposes a network
port (e.g. the envoy sidecar's default exec probe, or probes deleted entirely), no ports
are added — there is nothing to open ingress for.
*/}}
{{- define "networkPolicy.probePorts" -}}
{{- $probes := include "networkPolicy.effectiveProbes" . | fromYaml -}}
{{- $ports := dict -}}
{{- range list $probes.readinessProbe $probes.livenessProbe }}
{{- $port := include "networkPolicy.probePort" . }}
{{- if $port }}
{{- $_ := set $ports $port true -}}
{{- end -}}
{{- end -}}
{{- $portList := list -}}
{{- range $port, $_ := $ports }}{{- $portList = append $portList $port -}}{{- end -}}
{{- if $portList }}
{{- range $port := $portList }}
- protocol: TCP
  port: {{ $port }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
The port the kube-enforcer container's health-monitor server binds/reports on. Unlike
networkPolicy.probePorts, this always reads .Values.readinessProbe directly rather than
networkPolicy.effectiveProbes — the health-monitor server runs in the kube-enforcer
container itself even in kubeEnforcerAdvance mode, so it must not switch to the envoy
sidecar's probe.
*/}}
{{- define "kube-enforcer.healthMonitorPort" -}}
{{- include "networkPolicy.probePort" .Values.readinessProbe | default "8080" -}}
{{- end -}}

{{/*
The dedicated Prometheus listener port (.Values.prometheusPort, default 8996). The ConfigMap
(AQUA_PROMETHEUS_PORT), the container's named "prometheus" port and the NetworkPolicy ingress
port all read it from here so they can't drift apart. Validation is left to kube-enforcer,
which skips only the Prometheus listener on an invalid or colliding port.
*/}}
{{- define "kube-enforcer.prometheusPort" -}}
{{- .Values.prometheusPort | default 8996 -}}
{{- end -}}

{{/*
AQUA_ENABLE_METRICS from .Values.metricsEnabled, rendered as "true" or "false". A missing key
(e.g. --reuse-values from a chart before this value existed) keeps the default "true"; `default`
can't be used because it would also turn an explicit false into true. Accepts a bool or the
strings "true"/"false" (--set-string), and fails on anything else rather than guessing.
*/}}
{{- define "kube-enforcer.metricsEnabled" -}}
{{- $value := .Values.metricsEnabled -}}
{{- if kindIs "invalid" $value -}}
true
{{- else if has (toString $value | lower) (list "true" "false") -}}
{{- toString $value | lower -}}
{{- else -}}
{{- fail (printf "metricsEnabled must be true or false, got %q" (toString $value)) -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "aqua.labels" -}}
helm.sh/chart: '{{ include "aqua.chart" . }}'
{{ include "aqua.template-labels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Common template labels
*/}}
{{- define "aqua.template-labels" -}}
app.kubernetes.io/name: "{{ template "kube-enforcer.name" . }}"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aqua.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "extraEnvironmentVars" -}}
{{ if .extraEnvironmentVars -}}
{{ range $key, $value := .extraEnvironmentVars }}
{{ if or (eq ( $key | lower ) "http_proxy") (eq ( $key | lower ) "https_proxy") (eq ( $key | lower ) "no_proxy") }}
- name: {{ printf "%s" $key | replace "." "_" | lower | quote }}
{{ else }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
{{ end }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
    secretKeyRef:
      name: {{ .secretName }}
      key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "serviceAccountTrivy" -}}
{{- if .Values.trivy.serviceAccount.create -}}
    {{ .Values.trivy.serviceAccount.name | default (printf "%s-trivy-sa" .Release.Name) }}
{{- else if not .Values.trivy.serviceAccount.create -}}
    {{ .Values.trivy.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- end -}}
{{- end -}}