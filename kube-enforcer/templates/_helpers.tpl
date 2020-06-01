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
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-enforcer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.imageCredentials.registry entry required!" .Values.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.imageCredentials.username entry required!" .Values.imageCredentials.username) (required "A valid .Values.imageCredentials.password entry required!" .Values.imageCredentials.password) | b64enc) | b64enc }}
{{- end }}

{{- define "serverCertificate" }}
{{- printf "%s" (required "A valid .Values.certsSecret.serverCertificate entry required!" .Values.certsSecret.serverCertificate) | b64enc | replace "\n" "" }}
{{- end }}

{{- define "serverKey" }}
{{- printf "%s" (required "A valid .Values.certsSecret.serverKey entry required!" .Values.certsSecret.serverKey) | b64enc | replace "\n" "" }}
{{- end }}

{{- define "caBundle" }}
{{- printf "%s" (required "A valid .Values.validatingWebhook.caBundle entry required!" .Values.validatingWebhook.caBundle) | b64enc | replace "\n" "" }}
{{- end }}

{{- define "token" }}
{{- printf "%s" (required "A valid .Values.aquaSecret.kubeEnforcerToken entry required!" .Values.aquaSecret.kubeEnforcerToken) | b64enc }}
{{- end }}

{{- define "username" }}
{{- printf "%s" (required "A valid .Values.aquaSecret.aquaUsername entry required!" .Values.aquaSecret.aquaUsername) | b64enc }}
{{- end }}

{{- define "password" }}
{{- printf "%s" (required "A valid .Values.aquaSecret.aquaPassword entry required!" .Values.aquaSecret.aquaPassword) | b64enc }}
{{- end }}