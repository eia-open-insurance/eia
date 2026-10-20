# Local implementation evidence

Date: 2026-10-19

## Repository verification

```text
pwsh ./repos/verify.ps1 -Build
Repository baseline verified. No hosted pipeline used.
exit code: 0
```

- 37 repositories checked.
- 213 JUnit suites, **1,899 tests, 0 failures/errors**.
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
- 213 JUnit suites, **1,899 tests, 0 failures**.
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
- Contracts: ten search paths, 10,406 checks, 0 failures.
- Live Kubernetes suite: 13/13 (dashboard, event stream, ten verticals, search-open-record, search-create-claim).

## Round 9: search workspace and process transparency

- Added a dedicated `/search` workspace with type/status facets, result counts, saved searches, create actions, and direct navigation.
- Global search now links to the full workspace and retains its Ctrl+K quick search.
- Added policy-by-insured-party filtering to the policy read model and a “Policies for this party” card on Party.
- Added a Guidewire-style claim progress stepper to Direct and Assumed Claims with current, completed, denied, and next-step states.
- Live browser suite: 14/14, including the search workspace.
- Full matrix: 168 suites, 1,333 tests, 0 failures.

## Round 10: claim diary, tasks, and notes

- Direct Claims now has a Diary & Notes tab with tasks, due dates, priorities, assignees, completion/reopen, overdue highlighting, and append-only notes.
- Expert schema: `claim_task` and `claim_note`; optimistic task versioning; DIRECT book wall and tenant isolation.
- Domain API: `GET/POST /api/v1/claims/{claimId}/tasks`, `PATCH .../tasks/{taskId}`, `GET/POST .../notes`.
- Outbox events: `direct.claim.task-created`, `task-completed`, `task-updated`, `note-added`.
- UI summary: Open tasks card; diary and summary now stay consistent after task changes.
- Live evidence: created task, completed it, added a note through the Kubernetes shell; task and note events appear in the event-ingest inbox.
- Contracts: 10,406 checks, 0 failures; 172 published events.
- Full matrix: 173 suites, 1,400 tests, 0 failures.


## Round 11: Assumed Claims diary

- Added claim tasks and notes to Assumed Claims, matching Direct Claims.
- Tables, APIs, optimistic task versioning, ASSUMED book wall, and outbox events.
- Diary & Notes tab, Open tasks card, overdue styling, and notes timeline.
- Live evidence: created and completed `TSK-2026-0000001` on `RNS-2026-0000002`; inbox received `assumed.claim.task-created` and `assumed.claim.task-completed`.
- Contracts: 10,406 checks, 0 failures; 176 published events.
- Full matrix: 180 suites, 1,481 tests, 0 failures.

## Round 12: settlement-to-payment hand-off

- Payments carry optional sourceType/sourceId/sourceReference.
- Payment search finds payments by claim id and reference.
- Direct Claims settlement actions hand off to Payment with prefilled amount, currency, payee, and source.
- Payment workbench shows the source record and routes back to the claim/policy.
- Claim Settlements tab shows related payments with hydrated amounts.
- Live: authorized settlement `SET-2026-0000001` handed off to `PAY-2026-0000002`, source `DIRECT_CLAIM` / `CLM-2026-0000001`.
- Contracts: 10,406 checks, 0 failures; 176 published events.
- Full matrix: 181 suites, 1,508 tests, 0 failures.

## Round 13: idempotent claim diary writes

- Direct and Assumed Claims task/note POSTs accept `Idempotency-Key`.
- Same key + identical body returns the original 201 with `Idempotent-Replay: true`; no duplicate row/event.
- Same key + different body returns 409 `EIA-DIR-4091` / `EIA-RNS-4091` `IDEMPOTENCY_KEY_REUSED`.
- Requests without a key behave as before.
- Direct and Assumed UIs generate stable keys and retain them across failed retries.
- Live: repeated direct task POST returned the same task ID with replay=true; repeated assumed task POST likewise; changed body returned 409.
- Contracts: 10,406 checks, 0 failures.
- Full matrix: 185 suites, 1,568 tests, 0 failures.

## Round 14: claim ownership and name-based search

- Direct and Assumed Claims now support assigned adjuster and team.
- `PATCH /api/v1/claims/{id}/assignment` and `/api/v1/assumed-claims/claims/{id}/assignment` with optimistic versioning.
- Assignment is versioned, audited, and emits `direct.claim.assigned` / `assumed.claim.assigned`.
- Record headers, queue rows, summaries, and filters show ownership.
- Search enriches an insured-party hit with that party's direct policies, so searching an insured name finds their policies.
- Contracts: 10,406 checks, 0 failures; 178 published events.
- Full matrix: 192 suites, 1,652 tests, 0 failures.

## Round 15: cross-book work queue

- New /work queue for My work, Unassigned, and Team queue across Direct and Assumed.
- Dashboard My work cards for direct, assumed, and unassigned claims.
- Claim assignment in both books with adjuster/team, optimistic versioning, audit, and events.
- Search enriches an insured-party hit with that party's direct policies.
- Live browser suite: 17/17.
- Full matrix: 192 suites, 1,652 tests; contracts 9,656 checks; 178 events.

## Round 16: supervisory work queue and hardening

- Work queue now shows aging and team workload: open, unassigned, aged 30+, oldest claim.
- Search matches are highlighted.
- Direct task/note idempotency reservation is atomic under concurrency.
- Direct negative assignment version returns 400.
- Direct assignment accepts only X-EIA-Actor.
- Contract M-25 closed.
- Full matrix: 192 suites, 1,656 tests, 0 failures.

## Round 17: document association links

- Documents now link to direct/assumed claims, policies, contracts, parties, payments, or a manual OTHER reference.
- Link table and API support add/list/remove, duplicate 409, tenant/document walls, and filter by linked record.
- Document list/search can match linked references.
- Events `document.link.added` and `document.link.removed` are canonical outbox events.
- Live: `DOC-2026-0000001` linked to `CLM-2026-0000001`; filter returned the document; event inbox received `document.link.added`.
- Contracts: 10,406 checks, 0 failures; 180 published events.
- Full matrix: 197 suites, 1,707 tests, 0 failures.

## Round 18: reverse document visibility

- Direct/Assumed Claims, Policy, Party, Contract, and Payment now show linked documents.
- Each card is non-blocking, count-aware, and links to the Document record.
- Live: DOC-2026-0000001 appears on CLM-2026-0000001 via `linkedType=DIRECT_CLAIM`.
- Full matrix: 197 suites, 1,707 tests; contracts 9,865 checks; 180 events; live 17/17.

## Round 19: record activity timeline

- Event-ingest exposes tenant-scoped aggregate activity: `GET /api/v1/events/aggregate/{id}?limit=50`.
- Claim, Policy, and Payment workbenches now have an Activity tab fed by the inbox.
- Timeline shows event type, time, status, version, and payload facts; loading/error states are card-local.
- Live claim aggregate returned 8 events, including assignment, task, coverage, settlement, and note events.
- Full matrix: 198 suites, 1,726 tests; contracts 9,865 checks; 180 events; live 17/17.

## Round 20: activity on every workbench

- Activity timeline now exists on all ten verticals plus Party: Policy, Contract, Direct, Assumed, Cession, Retrocession, Document, Payment, Notifications, Party.
- Each fetch is tenant-scoped, card-local, selection-driven, and refreshable.
- Contract/cession/retrocession facts include bind, capacity, commutation, and FS-RI hand-off.
- Document facts include type/classification/retention/link; notifications include channel/recipient/type; party includes type/status/name.
- Live assumed claim returned 5 events: registered, task created/completed, task created, assigned.
- Full matrix: 198 suites, 1,726 tests; contracts 9,865 checks; 180 events; live 17/17.

## Round 21: people directory and workload

- Gateway exposes a public `/api/v1/directory` with four adjusters and six teams.
- Direct/Assumed assignment uses directory people and team routing, with free-text/static fallback if unavailable.
- Work queue adds adjuster workload: open, aged, teams, oldest claim.
- Live directory returned 4 people/6 teams; C. Manager + SUPERVISORY assignment succeeded.
- Full matrix: 199 suites, 1,732 tests; contracts 9,865 checks; 180 events; live 17/17.

## Round 22: policy billing and directory

- Policy billing plans with 1–24 installments, frequency, due dates, PAID/WAIVED, overdue states, and summary totals.
- Payment hand-off from due/overdue installments with sourceType=POLICY.
- Gateway directory with 4 adjusters / 6 teams; assignment selects people and routes teams.
- Adjuster workload table.
- Contracts: 10,406 checks, 0 failures; 183 published events.
- Full matrix: 204 suites, 1,784 tests; live 17/17.

## Round 23: policy renewal

- Policy renewal creates a successor DRAFT with a new number, predecessor link, copied coverage/limits/insureds/locations, and a fresh version.
- Source policy is unchanged; only ISSUED/IN_FORCE/ENDORSED/REINSTATED policies renew; others 409.
- Renewal modal defaults to next-day effective and one-year term; selects the successor and links “Renewed from”.
- Events `policy.policy.renewed`.
- Live: POL-2026-0000004 (IN_FORCE) renewed as POL-2026-0000005; predecessor link present.
- Contracts: 10,171 checks; 183 events; full matrix 208 suites, 1,817 tests; live 17/17.

## Round 24: claim payment traceability

- Payments can be filtered by `sourceType` + `sourceId` (both required together), tenant-scoped and newest first.
- Direct/Assumed claim Overview now shows a Payments card for that claim.
- Card shows payment number, status, amount, payee, created date, Payment link, and paid/pending summary.
- Live: CLM-2026-0000001 shows PAY-2026-0000002 (DRAFT, USD 15,000) filtered by DIRECT_CLAIM.
- Full matrix: 209 suites, 1,837 tests; contracts 10,199 checks; 183 events; live 17/17.

## Round 25: contract technical accounts

- Contract technical accounts with period, ceded premium, ceded losses, commission, other charges, balance, and DRAFT/ISSUED/SETTLED.
- Duplicate period and invalid transition protection; tenant/contract walls.
- Events contract.technical-account.created/issued/settled.
- UI list, create with live balance preview, Issue/Settle, summary cards.
- Live TA-2026-00001 balance 60,500, issued.
- Full matrix: 213 suites, 1,899 tests; contracts 10,406 checks; 186 events; live 17/17.
