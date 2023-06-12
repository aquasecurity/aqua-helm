{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
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
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
CommonPodLabels:
example:
metadata:
  labels:
{{ include common.podLabels . | indent 4 }}
*/}}
{{- define "common.podLabels" -}}
{{- if .Values.global.commonPodLabels }}
{{- with .Values.global.commonPodLabels -}}
{{ toYaml . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Image:
example: {{ include common.image .Values.brokerBitbucket }}
*/}}
{{- define "common.image" -}}
{{- $registry := coalesce .image.registry .global.registry "docker.io" -}}
{{- $repository := .image.repository -}}
{{- $tag := .image.tag | default "latest" -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- end -}}

{{/*
ssl secret volume mount :
example:
{{- $ssl := dict "secret" $bitbucket_secret "ssl" .Values.bitbucket.ssl }}
....
          envs:
          ...
          {{- include "ssl.envs" $ssl | indent 10 }}

          volumeMounts:
          {{- include "ssl.volumeMount" $ssl | indent 10 }}
      volumes:
      {{- include "ssl.volumeSecret" $ssl | indent 6 }}
*/}}

{{- define "ssl.envs" -}}
{{- if .ssl }}
{{- $mountPath := ( printf "/etc/%s/ssl" .secret ) }}
{{- if .ssl.ca }}
- name: CA_CERT
  value: {{ $mountPath }}/ca.pem
{{- end }}
{{- if .ssl.cert }}
- name: HTTPS_CERT
  value: {{ $mountPath }}/cert.pem
{{- end }}
{{- if .ssl.key }}
- name: HTTPS_KEY
  value: {{ $mountPath }}/key.pem
{{- end }}
{{- end }}
{{- end -}}

{{- define "ssl.volumeMount" -}}
{{ if .ssl }}
{{- $mountPath := ( printf "/etc/%s/ssl" .secret ) }}
- name: {{ .volumeName | default "ssl" }}
  mountPath: {{ $mountPath }}
{{- end }}
{{- end }} }}


{{- define "ssl.volumeSecret" -}}
{{- if .ssl }}
- name: {{ .volumeName | default "ssl" }}
  secret:
    secretName: {{ .secret }}
    items:
    {{- if .ssl.ca }}
    - key: ca.pem
      path: ca.pem
    {{- end }}
    {{- if .ssl.cert }}
    - key: cert.pem
      path: cert.pem
    {{- end }}
    {{- if .ssl.key }}
    - key: key.pem
      path: key.pem
    {{- end }}
{{- end }}
{{- end -}}

{{/*
Create codesec-agent secret.
*/}}
{{- define "secretName" -}}
{{- if   .Values.credentials.createSecret  -}}
    {{ default (printf "%s-%s" .Release.Name "-codesec-secrets") .Values.credentials.secretName }}
{{- else  }}
     {{- .Values.credentials.secretName  -}}
{{- end -}}
{{- end -}}
