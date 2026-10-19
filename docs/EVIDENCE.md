# Local implementation evidence

Date: 2026-10-19

## Repository verification

```text
pwsh ./repos/verify.ps1 -Build
Repository baseline verified. No hosted pipeline used.
exit code: 0
```

- 37 repositories checked.
- 67 JUnit suites, **509 tests, 0 failures/errors**.
- 11 Playwright suites: 10 vertical workbenches plus the shell.

## Running stack

```text
pwsh ./repos/run-local.ps1
```

- 4 platform services
- 20 vertical services (10 experts, 10 domains)
- 10 federated web remotes
- shell
- PostgreSQL 17

All 35 start checks reported `UP`.

| Service | URL |
|---|---|
| Shell | http://localhost:3000 |
| Gateway | http://localhost:8080 |
| Auth | http://localhost:9000 |
| Config | http://localhost:8888 |
| Lineage | http://localhost:8101 |

## Gateway smoke test

```text
pwsh ./repos/smoke-local.ps1
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

## Shell end-to-end

All ten vertical routes loaded from their federated remotes through the shell:

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
```

Screenshot: [platform-shell.png](images/platform-shell.png)

## OIDC

The authorization-code flow with the `eia-shell` client redirects to login and, after authenticating `adjuster`, returns an authorization code to `http://localhost:3000/callback`.

## Contracts

```text
python repos/eia-contracts/scripts/validate_contracts.py
PASS 3897 checks, 0 failures
```

- 10 OpenAPI 3.1 vertical documents
- 10 AsyncAPI 3 event documents, 151 planned event names
- 3 JSON Schema 2020-12 documents

Known implementation gaps are listed in [MISMATCHES.md](../../eia-contracts/MISMATCHES.md).

## Kubernetes and containers

```text
pwsh repos/eia-ops/scripts/validate.ps1
RESULT: PASS - 41 checks, all YAML parsed
VALIDATION PASS
```

- 26-service Compose stack
- 26 Deployments and 26 Services under `eia-local`
- Helm chart linted and rendered

The container and Kubernetes paths are **not yet executed** on this machine. Docker Desktop/WSL2 installation completed but requires a Windows reboot before the Linux engine or minikube can start. See [eia-ops README](../../eia-ops/README.md).

## Scope

This is a working local first vertical slice, not production-complete insurance administration. Each vertical has its primary aggregate, core invariants, create/list/get APIs, PostgreSQL persistence, a federated workbench, and tests. Coverage, endorsements, claims depth, billing, outbox/events, RLS, full RBAC, FS-RI/S4 live adapters, and production gates remain.


## Conformance spot checks

- Direct Claims `reserveAmount` is a JSON string (`"7500.5000"`), not a number.
- Cession with `X-EIA-Book: ASSUMED` returns 404, hiding the DIRECT-book resource.
- Party unknown id returns canonical 404 instead of a Spring 500.
- OIDC authorization request with `scope=openid` redirects to `/login`; after login the browser returns an authorization code to the shell callback.

## Round 2 additions

- Policy is the hardened reference: canonical RFC 9457 errors, page envelopes, ETag/If-Match, and idempotent creates.
- Transactional outbox library plus Party expert integration; events are written in the same transaction as the Party row.
- Cession and Retrocession hand off to the FS-RI simulator and persist the confirmation fields atomically.
- PostgreSQL `max_connections` raised to 300; each expert pool is capped at 3 connections.
- Live checks: policy replay returns 200 + `Idempotent-Replayed: true`; stale version returns 409 `CONCURRENT_MODIFICATION`; Cession moves `OPEN → RULE_APPLIED → HANDED_OFF` with `FSRI-CES-DIRECT-000001` and `POSTED`.

## Final verification — 2026-10-19

```text
pwsh ./repos/verify.ps1 -Build
Repository baseline verified. No hosted pipeline used.
exit code: 0
```

- 37 repositories checked.
- 67 JUnit suites, **509 tests, 0 failures**.
- 12 Playwright suites, including the opt-in live all-vertical suite.
- Kubernetes namespace `eia-local`: **37/37 pods Ready**.
- Gateway smoke: **10/10 vertical APIs**.
- Kubernetes-hosted shell: **10/10 federated verticals**.
- FS-RI in-cluster hand-off: `CES-000000001` → `HANDED_OFF`, `fsriStatus=POSTED`.
- Contract validation: **4,043 checks, 0 failures**.
- Deployment asset validation: **45 checks**.
