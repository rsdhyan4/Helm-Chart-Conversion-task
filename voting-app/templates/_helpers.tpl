{{/*
Expand the name of the chart.
*/}}
{{- define "voting-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "voting-app.fullname" -}}
{{- if .Values.nameOverride }}
{{- .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "voting-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "voting-app.labels" -}}
helm.sh/chart: {{ include "voting-app.chart" . }}
{{ include "voting-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "voting-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "voting-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Component labels
*/}}
{{- define "voting-app.componentLabels" -}}
{{ include "voting-app.labels" . }}
app: {{ .component }}
{{- end }}

{{/*
Component selector labels
*/}}
{{- define "voting-app.componentSelectorLabels" -}}
{{ include "voting-app.selectorLabels" . }}
app: {{ .component }}
{{- end }}

{{/*
Get image registry
*/}}
{{- define "voting-app.imageRegistry" -}}
{{- if .Values.global.imageRegistry }}
{{- printf "%s/" .Values.global.imageRegistry }}
{{- end }}
{{- end }}

{{/*
Get image pull policy
*/}}
{{- define "voting-app.imagePullPolicy" -}}
{{- if .componentValues.image.pullPolicy }}
{{- .componentValues.image.pullPolicy }}
{{- else if .Values.global.imagePullPolicy }}
{{- .Values.global.imagePullPolicy }}
{{- else }}
{{- "IfNotPresent" }}
{{- end }}
{{- end }}

{{/*
Get service name for a component
*/}}
{{- define "voting-app.serviceName" -}}
{{- $component := .component }}
{{- $serviceNameOverride := index .Values.serviceNames $component }}
{{- if $serviceNameOverride }}
{{- $serviceNameOverride }}
{{- else }}
{{- printf "%s-%s" (include "voting-app.fullname" .) $component }}
{{- end }}
{{- end }}

