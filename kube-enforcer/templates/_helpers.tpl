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
Will be created serviceAccount with name "aqua-sa" - the default serviceAccount
for server chart.
Else if .Values.serviceAccount.create set to true, so will becreate serviceAccount based on
.Values.serviceAccount.name or will be generated name based on Chart Release name
*/}}
{{- define "serviceAccount" -}}
{{- if .Values.serviceAccount.create -}}
    {{ .Values.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- else if not .Values.serviceAccount.create -}}
    {{ .Values.serviceAccount.name | default (printf "aqua-sa") }}
{{- end -}}
{{- end -}}

{{- define "registrySecret" -}}
{{- if .Values.imageCredentials.create -}}
    {{ .Values.imageCredentials.name | default (printf "%s-registry-secret" .Release.Name) }}
{{- else if not .Values.imageCredentials.create -}}
    {{ .Values.imageCredentials.name | default (printf "aqua-registry-secret") }}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-enforcer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.imageCredentials.registry entry required" .Values.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.imageCredentials.username entry required" .Values.imageCredentials.username) (required "A valid .Values.imageCredentials.password entry required" .Values.imageCredentials.password) | b64enc) | b64enc }}
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
{{- printf "%s" (required "A valid .Values.imageCredentials.name required" .Values.imageCredentials.name ) }}
{{- end }}

{{- define "platform" }}
{{- printf "%s" (required "A valid .Values.global.platform entry required" .Values.global.platform ) | replace "\n" "" }}
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