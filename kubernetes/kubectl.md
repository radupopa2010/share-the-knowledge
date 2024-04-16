

Get only pods names. Useful for doing something with pods
```bash
kubectl -n datadog get pods -o jsonpath={..metadata.name}
```

```bash
datadog-agent-4fk6l datadog-agent-54w27 datadog-agent-bbcvv datadog-agent-f697n datadog-agent-h4v5l datadog-cluster-agent-8df4f97c4-lphkx datadog-operator-c67cf65d4-wbq6r
```

Ranges
```bash
kubectl exec -it redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 $(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')
```

Get all containers inside a pod
```bash
kubectl get pods alertmanager-prometheus-simnet-kube-pro-alertmanager-0 -o jsonpath={.spec.containers[*].name}
```

on which nodes are my pods running, group by nodes
```bash
kubectl -n sdk-prod get pods -o wide --sort-by='{.spec.nodeName}'
```