{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.imageCredentials.registry entry required!" .Values.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.imageCredentials.username entry required!" .Values.imageCredentials.username) (required "A valid .Values.imageCredentials.password entry required!" .Values.imageCredentials.password) | b64enc) | b64enc }}
{{- end }}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "server.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "server.extraSecretEnvironmentVars" -}}
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

{{- define "kube-enforcer.name" -}}
{{- default .Chart.Name .Values.ke.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kube-enforcer.fullname" -}}
{{- if .Values.ke.fullnameOverride -}}
{{- .Values.ke.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.ke.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-enforcer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
KubeEnforcer webhook TLS material when ke.certsSecret.autoGenerate is set: a CA and a server certificate generated
as the kube-enforcer chart does, reusing the existing Secret on upgrade. Generated once per render and kept in
.Values, so the Secret, both webhooks and the deployment checksum all see the same CA.
*/}}
{{- define "keGeneratedCerts" -}}
{{- if not .Values.ke.certsSecret.generated }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace .Values.ke.certsSecret.name }}
{{- if and $secret (index ($secret.data | default dict) "ca.crt") }}
{{- $_ := set .Values.ke.certsSecret "generated" (dict "ca" (index $secret.data "ca.crt") "cert" (index $secret.data "server.crt") "key" (index $secret.data "server.key")) }}
{{- else }}
{{- $name := include "kube-enforcer.fullname" . }}
{{- $altNames := list (printf "%s.%s" $name .Release.Namespace) (printf "%s.%s.svc" $name .Release.Namespace) }}
{{- $ca := genCA "kube-enforcer-ca" 365 }}
{{- $cert := genSignedCert $name nil $altNames 365 $ca }}
{{- $_ := set .Values.ke.certsSecret "generated" (dict "ca" ($ca.Cert | b64enc) "cert" ($cert.Cert | b64enc) "key" ($cert.Key | b64enc)) }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "serverCertificate" }}
{{- if .Values.ke.certsSecret.autoGenerate }}
{{- include "keGeneratedCerts" . }}{{ .Values.ke.certsSecret.generated.cert }}
{{- else }}
{{- printf "%s" (required "A valid .Values.ke.certsSecret.serverCertificate entry required!" .Values.ke.certsSecret.serverCertificate) | replace "\n" "" }}
{{- end }}
{{- end }}

{{- define "serverKey" }}
{{- if .Values.ke.certsSecret.autoGenerate }}
{{- include "keGeneratedCerts" . }}{{ .Values.ke.certsSecret.generated.key }}
{{- else }}
{{- printf "%s" (required "A valid .Values.ke.certsSecret.serverKey entry required!" .Values.ke.certsSecret.serverKey) | replace "\n" "" }}
{{- end }}
{{- end }}

{{- define "caBundle" }}
{{- if .Values.ke.certsSecret.autoGenerate }}
{{- include "keGeneratedCerts" . }}{{ .Values.ke.certsSecret.generated.ca }}
{{- else }}
{{- printf "%s" (required "A valid .Values.ke.webhooks.caBundle entry required!" .Values.ke.webhooks.caBundle) | replace "\n" "" }}
{{- end }}
{{- end }}

{{- define "imageCredentials_name" }}
{{- printf "%s" (required "A valid .Values.imageCredentials.name required" .Values.imageCredentials.name ) }}
{{- end }}

{{- define "platform" }}
{{- $platform := .Values.platform }}
{{- if not $platform }}
{{-   fail "A valid .Values.platform entry is required.\nPlease provide one of the following options: aks, eks, gke, openshift, tkg, tkgi, k8s, rancher, gs, k3s, mke" }}
{{- end }}
{{- end }}
{{- define "serviceAccountTrivy" -}}
{{- if .Values.trivy.serviceAccount.create -}}
    {{ .Values.trivy.serviceAccount.name | default (printf "%s-trivy-sa" .Release.Name) }}
{{- else if not .Values.trivy.serviceAccount.create -}}
    {{ .Values.trivy.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- end -}}
{{- end -}}
