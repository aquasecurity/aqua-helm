{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

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

{{- define "imageCredentials_name" }}
{{- printf "%s" (required "A valid .Values.imageCredentials.name required" .Values.imageCredentials.name ) }}
{{- end }}

{{- define "aquaConsoleSecureAddress" -}}
{{- if and .Values.console.publicIP .Values.console.publicPort -}}
{{- printf "%s:%v" .Values.console.publicIP .Values.console.publicPort -}}
{{- else if eq .Values.global.platform "k3s" -}}
{{- printf "%s-console-svc:444" .Release.Name -}}
{{- else -}}
{{- printf "%s-console-svc:443" .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "platform" }}
{{- printf "%s" (required "A valid .Values.global.platform entry required" .Values.global.platform ) | replace "\n" "" }}
{{- end }}

{{/*
Define a gateway serviceAccount name
If Values.serviceAccount.create defined as false
And will be used serviceAccount created by parrent chart
*/}}
{{- define "gateway.serviceAccount" -}}
{{- if .Values.serviceAccount.name -}}
{{- printf "%s" .Values.serviceAccount.name -}}
{{- else -}}
{{- if not .Values.serviceAccount.create -}}
{{- printf "aqua-sa" -}}
{{- end -}}
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
app.kubernetes.io/name: "{{ template "fullname" . }}"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aqua.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}