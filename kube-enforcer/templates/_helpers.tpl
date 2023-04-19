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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-enforcer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.global.imageCredentials.registry entry required" .Values.global.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.global.imageCredentials.username entry required" .Values.global.imageCredentials.username) (required "A valid .Values.global.imageCredentials.password entry required" .Values.global.imageCredentials.password) | b64enc) | b64enc }}
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

{{/*
{{- define "platform" }}
{{- printf "%s" (required "A valid Values.global.platform entry required" .Values.global.platform ) | replace "\n" "" }}
{{- end }}
*/}}
{{- define "platform" }}
{{- printf "%s" .Values.global.platform | default "k8s" }}
{{- end }}

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