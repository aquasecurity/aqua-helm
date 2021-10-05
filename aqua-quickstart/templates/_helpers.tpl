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

{{- define "serverCertificate" }}
{{- printf "%s" (required "A valid .Values.ke.certsSecret.serverCertificate entry required!" .Values.ke.certsSecret.serverCertificate) | replace "\n" "" }}
{{- end }}

{{- define "serverKey" }}
{{- printf "%s" (required "A valid .Values.ke.certsSecret.serverKey entry required!" .Values.ke.certsSecret.serverKey) | replace "\n" "" }}
{{- end }}

{{- define "caBundle" }}
{{- printf "%s" (required "A valid .Values.ke.webhooks.caBundle entry required!" .Values.ke.webhooks.caBundle) | replace "\n" "" }}
{{- end }}

{{- define "imageCredentials_name" }}
{{- printf "%s" (required "A valid .Values.imageCredentials.name required" .Values.imageCredentials.name ) }}
{{- end }}

{{- define "platform" }}
{{- printf "%s" (required "A valid .Values.platform entry required" .Values.platform ) | replace "\n" "" }}
{{- end }}
