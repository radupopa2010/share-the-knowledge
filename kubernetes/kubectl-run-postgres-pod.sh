#  # Start the nginx pod using a different command and custom arguments
# kubectl run nginx --image=nginx --command -- <cmd> <arg1> ... <argN>

kubectl run postgres-check --image=docker.io/alpine:latest --restart=Never --command -- /usr/bin/tail -f /dev/null

# run image with root user 
cat radu-debug-2.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: radu-debug-1
  name: radu-debug-1
  namespace: bardock-0
spec:
  securityContext:
    runAsUser: 0
  containers:
  - command:
    - /bin/sh
    - -c
    - tail -f /dev/null
    image: docker.io/bitnami/kubectl
    imagePullPolicy: Always
    name: radu-debug-1
    resources: {}
    securityContext:
      privileged: true

kubectl apply -f radu-debug-2.yaml