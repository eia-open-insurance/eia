# Local implementation evidence

Date: 2026-10-19

## Repository verification

```text
pwsh ./repos/verify.ps1 -Build
Repository baseline verified. No hosted pipeline used.
exit code: 0
```

- 37 repositories checked.
- 168 JUnit suites, **1,333 tests, 0 failures/errors**.
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
- 168 JUnit suites, **1,333 tests, 0 failures**.
- 12 Playwright suites, including the opt-in live all-vertical suite.
- Kubernetes namespace `eia-local`: **37/37 pods Ready**.
- Gateway smoke: **10/10 vertical APIs**.
- Kubernetes-hosted shell: **10/10 federated verticals**.
- FS-RI in-cluster hand-off: `CES-000000001` → `HANDED_OFF`, `fsriStatus=POSTED`.
- Contract validation: **4,043 checks, 0 failures**.
- Deployment asset validation: **45 checks**.

## Round 6: operational UI

- Shared design system in the shell: navy operations header, context strip, consistent typography, tables, forms, buttons, and status pills.
- Operations dashboard aggregating direct/assumed claims, policies, contracts, cession/retrocession hand-offs, documents, payments, and notifications.
- All ten verticals still load through the Kubernetes-hosted shell after the redesign.
- Demo operational data seeded through the gateway: 3 parties, 2 policies, 2 direct claims, 1 assumed claim, 1 contract, 1 cession, 1 document, 1 payment, 1 notification.
- Screenshots: `images/operations-dashboard.png`, `images/policy-workspace.png`, `images/direct-claims-workspace.png`.

## Round 7: transactional event pipeline

- New `eia-platform/event-ingest` service on port 8102 with PostgreSQL `eia_platform`.
- Signed `POST /internal/events`; 202 first delivery, 200 replay, 409 conflicting payload, 401 bad HMAC, 400 validation, 413 oversized.
- Idempotent `inbox_event` keyed by event ID with payload hash.
- Gateway exposes read-only `/api/v1/events/recent` and `/api/v1/events/stats`; `/internal/**` is not routable through gateway or shell.
- All ten experts now produce transactional outbox events; Kubernetes and Compose wire `EIA_OUTBOX_ENABLED`, endpoint, and shared signing secret.
- Live evidence: 14 events, 14 processed, 0 failed; policy, contract, direct-claim, assumed-claim, party, payment, document, notification events observed.
- Dashboard Event Stream card shows processed/total counts, recent types, latest deliveries, and LIVE status.
- Contracts updated to 168 published events and 8,607 checks, 0 failures.

## Round 8: global search, record discovery, and cross-links

- Common search endpoint on all ten verticals: `GET /api/v1/{resource}/search?q=&limit=`.
- Shared response: `{query, limit, items[{id,type,label,secondary,status,href}]}`.
- Tenant-scoped; book-scoped verticals enforce DIRECT/ASSUMED before returning results.
- Shell global search (Ctrl+K) across all ten verticals, grouped results, create actions, recent searches, keyboard navigation, and direct record links.
- Each workbench has a prominent queue filter, `?record=` deep-link selection, and `?new=1` create entry.
- Predictive typeahead pickers for party, policy, contract, and payee fields replace raw UUID entry.
- Cross-links between claim/policy/party/contract/cession/retrocession/payment/notification records.
- Related-label resolution shows policy, contract, and party numbers/names instead of UUIDs, with graceful fallback.
- Process context panels explain why the record matters and where it sits in the workflow.
- Contracts: ten search paths, 8,874 checks, 0 failures.
- Live Kubernetes suite: 13/13 (dashboard, event stream, ten verticals, search-open-record, search-create-claim).

## Round 9: search workspace and process transparency

- Added a dedicated `/search` workspace with type/status facets, result counts, saved searches, create actions, and direct navigation.
- Global search now links to the full workspace and retains its Ctrl+K quick search.
- Added policy-by-insured-party filtering to the policy read model and a “Policies for this party” card on Party.
- Added a Guidewire-style claim progress stepper to Direct and Assumed Claims with current, completed, denied, and next-step states.
- Live browser suite: 14/14, including the search workspace.
- Full matrix: 168 suites, 1,333 tests, 0 failures.
