# Local run

## Prerequisites

- JDK 22 at `C:\Program Files\Eclipse Adoptium\jdk-22.0.2.9-hotspot`
- Node 24 / npm 11
- PostgreSQL 17 running on `localhost:5432`, user `postgres`, password `postgres`
- Gradle 8.14.3 at `.tools\gradle-8.14.3\bin\gradle.bat` (wrappers are committed in each repo)

## Start the stack

```powershell
pwsh ./repos/run-local.ps1
```

The script creates the vertical databases if they do not exist, starts the platform services, all ten experts and domains, all ten federated remotes, and the shell.

| Surface | URL |
|---|---|
| Shell | http://localhost:3000 |
| Gateway | http://localhost:8080 |
| Auth | http://localhost:9000 |
| Config | http://localhost:8888 |
| Lineage | http://localhost:8101 |

Vertical UI routes:

```text
/party
/policy
/contract
/direct-claims
/assumed-claims
/cession
/retrocession
/document
/payment
/notifications
```

## Verify

```powershell
pwsh ./repos/smoke-local.ps1
```

This calls every vertical list endpoint through the gateway with the required tenant and book headers.

## Stop

```powershell
pwsh ./repos/stop-local.ps1
```

## Logs

```text
repos/.run/logs/
```

## Kubernetes

Docker Desktop and WSL2 are installed, but the Linux engine and minikube require a machine reboot before the Kubernetes path can run. See `repos/eia-ops/README.md`.
