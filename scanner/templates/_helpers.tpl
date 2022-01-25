{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "scanner.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "scanner.fullname" -}}
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
{{- define "scanner.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "scanner.extraEnvironmentVars" -}}
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
{{- define "scanner.extraSecretEnvironmentVars" -}}
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

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.imageCredentials.registry entry required" .Values.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.imageCredentials.username entry required" .Values.imageCredentials.username) (required "A valid .Values.imageCredentials.password entry required" .Values.imageCredentials.password) | b64enc) | b64enc }}
{{- end }}

{{/*
{{- define "imageCredentials_name" }}
{{- printf "%s" (required "A valid .Values.imageCredentials.name required" .Values.imageCredentials.name ) }}
{{- end }}

{{- define "serviceAccount" }}
{{- printf "%s" (required "A valid .Values.serviceAccount.name required" .Values.serviceAccount.name ) }}
{{- end }}
*/}}
{{- define "scannerSecret" }}
{{- printf "%s" (required "A valid .Values.scannerUserSecret.secretName required" .Values.scannerUserSecret.secretName ) }}
{{- printf "%s" (required "A valid .Values.scannerUserSecret.userKey required" .Values.scannerUserSecret.userKey ) }}
{{- printf "%s" (required "A valid .Values.scannerUserSecret.passwordKey required" .Values.scannerUserSecret.passwordKey ) }}
{{- end }}

{{- define "serverCertificate" }}
{{- printf "%s" (required "A valid .Values.serverSSL.serverSSLCert entry required" .Values.serverSSL.serverSSLCert ) | replace "\n" "" }}
{{- end }}
