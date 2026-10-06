apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: {{ .Values.namespace }}
  labels:
    app: frontend
spec:
  replicas: {{ .Values.app.replicas.frontend }}
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          image: "{{ .Values.images.frontend }}:{{ .Values.images.tag }}"
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: {{ .Values.service.frontend.targetPort }}
          readinessProbe:
            httpGet:
              path: /
              port: {{ .Values.service.frontend.targetPort }}
            initialDelaySeconds: 3
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /
              port: {{ .Values.service.frontend.targetPort }}
            initialDelaySeconds: 10
            periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: {{ .Values.namespace }}
  labels:
    app: frontend
spec:
  selector:
    app: frontend
  ports:
    - name: http
      port: {{ .Values.service.frontend.port }}
      targetPort: {{ .Values.service.frontend.targetPort }}
  type: ClusterIP