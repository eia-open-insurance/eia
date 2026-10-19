# Kubernetes local evidence

Cluster: minikube profile `minikube`, Kubernetes v1.37.0, Docker driver.
Namespace: `eia-local`.

## Images

25 local images built and loaded: 4 platform services, 10 experts, 10 domains, and the shell. PostgreSQL uses `postgres:17-alpine`.

## Workloads

```text
kubectl -n eia-local get pods
26/26 Running and Ready
```

The namespace contains 26 Deployments and 26 Services, one PostgreSQL PVC, an Ingress, ConfigMaps, and a placeholder Secret.

## API smoke test

Through the gateway port-forward:

```text
PASS party
PASS policy
PASS contract
PASS direct-claims
PASS assumed-claims
PASS cession
PASS retrocession
PASS document
PASS payment
PASS notifications
All vertical APIs reachable through the gateway.
```

## Policy conformance in-cluster

```text
POST /api/v1/policies -> 201, ETag "0"
replay same Idempotency-Key -> 200, Idempotent-Replayed: true
GET ?page=0&size=1 -> page envelope with total
```

## Ingress

```text
NAME   CLASS   HOSTS       ADDRESS        PORTS
eia    nginx   eia.local   192.168.49.2   80
```

Local access uses port-forwards for the gateway and shell; `minikube tunnel` provides direct ingress access.

## Remaining work being completed

- Ten federated web remotes are not yet deployed as pods; the shell currently targets host ports.
- FS-RI simulator is not yet deployed in-cluster; Cession/Retrocession still default to localhost:8181.
- A follow-up pass is adding both, then rerunning the live browser suite and FS-RI hand-off against the cluster.
