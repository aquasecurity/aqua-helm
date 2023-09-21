{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
If .Values.serviceAccount.create set to false and .Values.serviceAccount.name not defined
Will be created serviceAccount with name "aqua-sa" - the default serviceAccount
for server chart.
Else if .Values.serviceAccount.create set to true, so will becreate serviceAccount based on
.Values.serviceAccount.name or will be generated name based on Chart Release name
*/}}
{{- define "agentServiceAccount" -}}
{{- if and ( .Values.serviceAccount.create ) ( .Values.global.enforcer.enabled ) -}}
    {{ .Values.serviceAccount.name | default (printf "%s-agent-sa" .Release.Name) }}
{{- else if .Values.serviceAccount.create -}}
    {{ .Values.serviceAccount.name | default (printf "%s-sa" .Release.Name) }}
{{- else if not .Values.serviceAccount.create -}}
    {{ .Values.serviceAccount.name | default (printf "aqua-sa") }}
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
    {{ .Values.priorityClass.name | default (printf "%s-enforcer-priority-class" .Release.Name) }}
{{- else if not .Values.priorityClass.create -}}
    {{ .Values.priorityClass.name | default (printf "%s-enforcer-priority-class" .Release.Name) }}
{{- end -}}
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
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.global.imageCredentials.registry entry required!" .Values.global.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.global.imageCredentials.username entry required!" .Values.global.imageCredentials.username) (required "A valid .Values.global.imageCredentials.password entry required!" .Values.global.imageCredentials.password) | b64enc) | b64enc }}
{{- end }}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
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

{{/*
Windows Enforcer, Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "windowsExtraEnvironmentVars" -}}
{{ if .windowsEnforcer.extraEnvironmentVars -}}
{{ range $key, $value := .windowsEnforcer.extraEnvironmentVars }}
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
Windows EnforcerInject extra environment populated by secrets, if populated
*/}}
{{- define "windowsExtraSecretEnvironmentVars" -}}
{{- if .windowsEnforcer.extraSecretEnvironmentVars -}}
{{- range .windowsEnforcer.extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
    secretKeyRef:
      name: {{ .secretName }}
      key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}

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
app.kubernetes.io/name: "{{ template "name" . }}"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aqua.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}