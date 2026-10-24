{{- define "common.workload" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
  labels: {app: {{ .Chart.Name }}}
spec:
  replicas: {{ .Values.replicas }}
  selector:
    matchLabels: {app: {{ .Chart.Name }}}
  template:
    metadata:
      labels: {app: {{ .Chart.Name }}}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports: [{containerPort: {{ .Values.port }}}]
          readinessProbe: {httpGet: {path: {{ .Values.probePath }}, port: {{ .Values.port }}}}
          livenessProbe: {httpGet: {path: {{ .Values.probePath }}, port: {{ .Values.port }}}, initialDelaySeconds: 10}
          {{- with .Values.resources }}
          resources: {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with .Values.env }}
          env: {{- toYaml . | nindent 12 }}
          {{- end }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}
spec:
  selector: {app: {{ .Chart.Name }}}
  ports: [{port: {{ .Values.port }}, targetPort: {{ .Values.port }}}]
{{- if .Values.ingress.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Chart.Name }}
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
spec:
  ingressClassName: nginx
  tls: [{hosts: [{{ .Values.ingress.host | quote }}], secretName: {{ .Chart.Name }}-tls}]
  rules:
    - host: {{ .Values.ingress.host | quote }}
      http:
        paths: [{path: /, pathType: Prefix, backend: {service: {name: {{ .Chart.Name }}, port: {number: {{ .Values.port }}}}}}]
{{- end }}
{{- end -}}
