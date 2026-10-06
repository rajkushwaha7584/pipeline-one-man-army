apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: {{ .Values.namespace }}
  labels:
    app: backend
spec:
  replicas: {{ .Values.app.replicas.backend }}
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend
          image: "{{ .Values.images.backend }}:{{ .Values.images.tag }}"
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: {{ .Values.service.backend.targetPort }}
          env:
            - name: DB_HOST
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.mysql.existingSecret }}
                  key: db-host
            - name: DB_PORT
              value: "{{ .Values.service.mysql.port }}"
            - name: DB_USER
              value: {{ .Values.mysql.user | quote }}
            - name: DB_NAME
              value: {{ .Values.mysql.database | quote }}
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Values.mysql.existingSecret }}
                  key: app-password
            - name: PORT
              value: "{{ .Values.service.backend.targetPort }}"
          readinessProbe:
            httpGet:
              path: /health
              port: {{ .Values.service.backend.targetPort }}
            initialDelaySeconds: 10
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: {{ .Values.service.backend.targetPort }}
            initialDelaySeconds: 20
            periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: {{ .Values.namespace }}
  labels:
    app: backend
spec:
  selector:
    app: backend
  ports:
    - name: http
      port: {{ .Values.service.backend.port }}
      targetPort: {{ .Values.service.backend.targetPort }}
  type: ClusterIP