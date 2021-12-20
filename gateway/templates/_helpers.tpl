{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" (required "A valid .Values.global.imageCredentials.registry entry required!" .Values.global.imageCredentials.registry) (printf "%s:%s" (required "A valid .Values.global.imageCredentials.username entry required!" .Values.global.imageCredentials.username) (required "A valid .Values.global.imageCredentials.password entry required!" .Values.global.imageCredentials.password) | b64enc) | b64enc }}
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
{{- printf "%s" (required "A valid .Values.global.imageCredentials.name required" .Values.global.imageCredentials.name ) }}
{{- end }}

{{- define "aquaConsoleSecureAddress" -}}
{{- if and .Values.console.publicIP .Values.console.publicPort -}}
{{- printf "%s:%s" .Values.console.publicIP .Values.console.publicPort -}}
{{- else -}}
{{- printf "%s-console-svc:443" .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "platform" }}
{{- printf "%s" (required "A valid .Values.global.platform entry required" .Values.global.platform ) | replace "\n" "" }}
{{- end }}
