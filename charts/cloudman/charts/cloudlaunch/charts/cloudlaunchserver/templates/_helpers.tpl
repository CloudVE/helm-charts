{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cloudlaunchserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudlaunchserver.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "cloudlaunchserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "rabbitmq.fullname" -}}
{{- printf "%s-%s" .Release.Name "rabbitmq" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return django secret key
*/}}
{{- define "cloudlaunchserver.secret_key" -}}
{{- if .Values.secret_key }}
    {{- .Values.secret_key -}}
{{- else -}}
    {{- randAlphaNum 10 -}}
{{- end -}}
{{- end -}}

{{/*
Return django fernet keys
*/}}
{{- define "cloudlaunchserver.fernet_keys" -}}
{{- if .Values.fernet_keys }}
    {{- join "," .Values.fernet_keys -}}
{{- else -}}
    {{- randAlphaNum 10 -}}
{{- end -}}
{{- end -}}

{{- define "cloudlaunchserver.envvars" }}
            - name: CELERY_BROKER_URL
              value: amqp://{{ .Values.rabbitmq.rabbitmqUsername }}:{{ .Values.rabbitmq.rabbitmqPassword }}@{{ template "rabbitmq.fullname" . }}:5672/
            - name: DJANGO_SETTINGS_MODULE
              value: {{ .Values.django_settings_module | default "cloudlaunchserver.settings_prod" | quote }}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_DB_ENGINE
              value: postgresql_psycopg2
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_DB_NAME
              value: {{ .Values.postgresql.postgresqlDatabase | default "cloudlaunch" | quote }}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_DB_USER
              value: {{ .Values.postgresql.postgresqlUsername | default "cloudlaunch" | quote }}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_DB_HOST
              value: {{ template "postgresql.fullname" . }}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_DB_PORT
              value: {{ .Values.postgresql.service.port | default 5432 | quote }}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: "{{ .Release.Name }}-postgresql"
                  key: postgresql-password
{{/*            {{- if not (eq .Values.ingress.path "/") }}*/}}
{{/*            - name: CLOUDLAUNCH_PATH_PREFIX*/}}
{{/*              value: {{ .Values.ingress.path | quote }}*/}}
{{/*            {{- end }}*/}}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_SENTRY_DSN
              value: {{ .Values.sentry_dsn | default "CHANGEONINSTALL" | quote }}
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: {{ template "cloudlaunchserver.fullname" . }}
                  key: cloudlaunch-secret-key
            - name: {{ .Values.env_prefix | default "CLOUDLAUNCH" | upper }}_FERNET_KEYS
              valueFrom:
                secretKeyRef:
                  name: {{ template "cloudlaunchserver.fullname" . }}
                  key: cloudlaunch-fernet-keys
{{- /*
  Trick to globally disable certificate verification as OIDC will fail due to unverified certificate
  https://stackoverflow.com/questions/48391750/disable-python-requests-ssl-validation-for-an-imported-module?rq=1
*/}}
            - name: CURL_CA_BUNDLE
              value: ""
            # Fix for import issue: https://github.com/travis-ci/travis-ci/issues/7940
            - name: BOTO_CONFIG
              value: "/dev/null"
{{- end }}

{{/*
Create a template for expanding a section into env vars
*/}}
{{- define "cloudlaunchserver.extra_envvars" -}}
{{- range $key, $val := . }}
{{- if $val }}
            - name: {{ $key | upper }}
              value: {{ quote $val }}
{{- end }}
{{- end }}
{{- end -}}
