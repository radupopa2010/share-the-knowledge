

#  # Start the nginx pod using a different command and custom arguments
# kubectl run nginx --image=nginx --command -- <cmd> <arg1> ... <argN>

kubectl run postgres-check --image=docker.io/alpine:latest --restart=Never --command -- /usr/bin/tail -f /dev/null

kubectl -n bardock-0 run radu-debug-1  --image docker.io/bitnami/kubectl --command  -- /bin/sh -c "tail -f /dev/null"