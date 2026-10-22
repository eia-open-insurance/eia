# Local implementation evidence

Date: 2026-10-19

## Repository verification

```text
pwsh ./repos/verify.ps1 -Build
Repository baseline verified. No hosted pipeline used.
exit code: 0
```

- 37 repositories checked.
- 296 JUnit suites, **3,063 tests, 0 failures/errors**.
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
- 296 JUnit suites, **3,063 tests, 0 failures**.
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
- Contracts: ten search paths, 13,978 checks, 0 failures.
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
- Contracts: 13,978 checks, 0 failures; 172 published events.
- Full matrix: 173 suites, 1,400 tests, 0 failures.


## Round 11: Assumed Claims diary

- Added claim tasks and notes to Assumed Claims, matching Direct Claims.
- Tables, APIs, optimistic task versioning, ASSUMED book wall, and outbox events.
- Diary & Notes tab, Open tasks card, overdue styling, and notes timeline.
- Live evidence: created and completed `TSK-2026-0000001` on `RNS-2026-0000002`; inbox received `assumed.claim.task-created` and `assumed.claim.task-completed`.
- Contracts: 13,978 checks, 0 failures; 176 published events.
- Full matrix: 180 suites, 1,481 tests, 0 failures.

## Round 12: settlement-to-payment hand-off

- Payments carry optional sourceType/sourceId/sourceReference.
- Payment search finds payments by claim id and reference.
- Direct Claims settlement actions hand off to Payment with prefilled amount, currency, payee, and source.
- Payment workbench shows the source record and routes back to the claim/policy.
- Claim Settlements tab shows related payments with hydrated amounts.
- Live: authorized settlement `SET-2026-0000001` handed off to `PAY-2026-0000002`, source `DIRECT_CLAIM` / `CLM-2026-0000001`.
- Contracts: 13,978 checks, 0 failures; 176 published events.
- Full matrix: 181 suites, 1,508 tests, 0 failures.

## Round 13: idempotent claim diary writes

- Direct and Assumed Claims task/note POSTs accept `Idempotency-Key`.
- Same key + identical body returns the original 201 with `Idempotent-Replay: true`; no duplicate row/event.
- Same key + different body returns 409 `EIA-DIR-4091` / `EIA-RNS-4091` `IDEMPOTENCY_KEY_REUSED`.
- Requests without a key behave as before.
- Direct and Assumed UIs generate stable keys and retain them across failed retries.
- Live: repeated direct task POST returned the same task ID with replay=true; repeated assumed task POST likewise; changed body returned 409.
- Contracts: 13,978 checks, 0 failures.
- Full matrix: 185 suites, 1,568 tests, 0 failures.

## Round 14: claim ownership and name-based search

- Direct and Assumed Claims now support assigned adjuster and team.
- `PATCH /api/v1/claims/{id}/assignment` and `/api/v1/assumed-claims/claims/{id}/assignment` with optimistic versioning.
- Assignment is versioned, audited, and emits `direct.claim.assigned` / `assumed.claim.assigned`.
- Record headers, queue rows, summaries, and filters show ownership.
- Search enriches an insured-party hit with that party's direct policies, so searching an insured name finds their policies.
- Contracts: 13,978 checks, 0 failures; 178 published events.
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
- Contracts: 13,978 checks, 0 failures; 180 published events.
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
- Contracts: 13,978 checks, 0 failures; 183 published events.
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

## Round 26: contract bordereaux

- Contract period bordereaux with create/list and RECEIVED→PROCESSED/FAILED.
- Processing creates or reuses the period technical account and links it.
- UI list/create/process/fail, summary cards, and technical-account hand-off.
- Events contract.bordereau.received/processed/failed.
- Live: BRD-2026-00001 processed and linked TA-2026-00002.
- Full matrix: 217 suites, 1,964 tests; contracts 10,593 checks; 188 events; live 17/17.

## Round 27: claim allocations

- Direct claim allocations by policy year and layer with percentage and amount.
- Sum of allocations capped at 100%; policy must match claim policy.
- UI Allocations tab with summary, ledger, create form, 100% guard.
- Event direct.claim.allocation-created.
- Live: CLM-2026-0000001 allocation 2026 PRIMARY 50% $3,000; total 0.5 / $3,000.
- Full matrix: 220 suites, 2,015 tests; contracts 10,738 checks; 189 events; live 17/17.

## Round 28: premium receivables

- Tenant-wide receivable queue across policy installments.
- Status DUE/OVERDUE derived from due date; days past due; summary totals.
- Shell `/receivables` workspace with All/Overdue/Due tabs, prominent filter, policy links, and Open policy.
- Dashboard Premium receivables card.
- Gateway route `/api/v1/billing/**` to policy domain.
- Live: 3 DUE installments USD 750 for POL-2026-0000004.
- Full matrix: 225 suites, 2,052 tests; contracts 10,847 checks; 189 events; live 17/17.

## Round 29: mass tort profile

- Policy mass-tort profile with tort type, trigger, allocation method, notes, coverage block, DRAFT/COMPLETE.
- Validation for complete profiles; UI tab with form, summary, and context.
- Event policy.mass-tort-profile.updated.
- Live: POL-2026-0000004 COMPLETE ASBESTOS/EXPOSURE/ALL_SUMS block 2000–2024.
- Full matrix: 230 suites, 2,098 tests; contracts 11,032 checks; 189 events; live 17/17.

## Round 30: claimant search enrichment

- Direct claim list accepts claimantPartyId, tenant-scoped and exact.
- Party search hits now enrich with the party's direct claims alongside policies.
- Search result type/link/secondary show claimant claims.
- Live: Acme search returns 1 party, 3 policies, 3 direct claims (CLM-2026-0000001..3).
- Full matrix: 231 suites, 2,117 tests; contracts 11,054 checks; 189 events; live 17/17.

## Round 31: billing payment application

- Policy Billing links an existing POLICY-source payment to a DUE/OVERDUE installment.
- PATCH sends status PAID + paymentId; no payment creation/execution from Policy.
- Modal lists policy payments, amount mismatch warning, linked payment number on the row.
- Live: PAY-2026-0000003 linked to POL-2026-0000004 installment 2; paid total $500, outstanding $500.
- Full matrix: 231 suites, 2,117 tests; contracts 11,054 checks; 189 events; live 17/17.

## Round 32: contract cash calls

- Cash calls with period, amount/currency, due date, notes, REQUESTED/ISSUED/SETTLED/CANCELLED.
- UI tab with summary, create, issue, settle, cancel.
- Events contract.cash-call.requested/issued/settled/cancelled.
- Live: CC-2026-00001 USD 50,000 issued, due 2026-11-30.
- Full matrix: 235 suites, 2,187 tests; contracts 11,292 checks; 192 events; live 17/17.

## Round 33: payment allocations

- Payment allocation ledger splits one payment across claim/policy targets and components.
- Sum cannot exceed the payment amount; cancelled/reversed/failed payments cannot allocate.
- Predictive target picker by type; links back to claim/policy.
- Event payment.allocation.created.
- Live: PAY-2026-0000003 USD 250 → POLICY allocation USD 100; total 100, unallocated 150.
- Full matrix: 238 suites, 2,223 tests; contracts 11,477 checks; 193 events; live 17/17.

## Round 34: allocation-to-policy erosion

- Claim allocations accept an optional policy limit.
- Direct Claims posts an erosion fact to Policy, records POSTED/FAILED on the allocation, and supports retry.
- UI shows policy-limit picker, erosion badges, failure message, and Retry erosion.
- Live: allocation 25% / USD 1,000 posted to limit 93e3960f; policy remaining moved 100,000 → 99,000.
- Full matrix: 239 suites, 2,271 tests; contracts 11,527 checks; 193 events; live 17/17.

## Round 35: contract security

- Contract collateral records: type, required/held amounts, currency, provider, expiry, approval reference, status.
- Security tab now backed by real GET/POST; create derives ACTIVE/EXPIRED, enforces contract currency, over-collateralisation approval.
- Event contract.security.recorded.
- Live: QS-043225 security LETTER_OF_CREDIT required 500,000 held 450,000 USD expiry 2027-06-30.
- Full matrix: 244 suites, 2,309 tests; contracts 11,646 checks; 193 events; live 17/17.

## Round 36: billing dunning

- Dunning actions on DUE/OVERDUE installments: REMINDER/FIRST_NOTICE/SECOND_NOTICE/COLLECTIONS, EMAIL/LETTER/PORTAL, notes.
- Receivables rows show last dunning level/date; Send dunning modal and queue refresh.
- Event policy.dunning.sent.
- Live: POL-2026-0000004 installment 3 REMINDER/EMAIL SENT; queue shows last dunning.
- Full matrix: 250 suites, 2,356 tests; contracts 11,808 checks; 194 events; live 17/17.

## Round 37: mass-tort allocation guard

- Claim allocation now enforces the policy mass-tort coverage block.
- COMPLETE profile with block dates: policyYear must be within inclusive start/end years.
- DRAFT/missing/unavailable profile fails open.
- 400 MASS_TORT_YEAR_OUTSIDE_BLOCK.
- Live: block 2020–2024 rejected policyYear 2027 and allowed 2024.
- Full matrix: 251 suites, 2,369 tests; contracts 11,809 checks; 194 events; live 17/17.

## Round 38: policy programs

- Program catalog with number, name, type, effective dates, status, lead policy.
- Policy program membership attach/detach; PolicyDto programId.
- UI Program tab with current program, attach existing, create, detach.
- Events policy.program.created and policy.policy.program-assigned.
- Live: PRG-2026-0000001 MASS_TORT attached to POL-2026-0000004.
- Full matrix: 258 suites, 2,437 tests; contracts 12,109 checks; 196 events; live 17/17.

## Round 39: document file content

- Raw file upload/download for documents, 10 MiB cap, SHA-256, metadata.
- UI File tab with upload/drag-drop/progress/download; optional file at registration.
- Event document.content.uploaded.
- Live: DOC-2026-0000001 stored evidence.pdf (`application/pdf`, 22 B), downloaded with attachment filename and checksum header.
- Full matrix: 262 suites, 2,481 tests; contracts 12,255 checks; 197 events; live 17/17.


## Round 40: contract security lifecycle

- Release/expire collateral with transition rules and terminal state.
- Dedicated Security panel with required/held/outstanding totals and actions.
- Event contract.security.status-changed.
- Live: QS-043225 LETTER_OF_CREDIT released; summary updated.
- Full matrix: 263 suites, 2,526 tests; contracts 12,333 checks; 198 events; live 17/17.


## Round 41: policy credit notes

- Credit notes with DRAFT -> ISSUED -> APPLIED / CANCELLED lifecycle.
- Billing tab credit-note ledger with issued/applied totals, create, issue, apply, cancel.
- Events policy.credit-note.issued/applied/cancelled.
- Live: CN-0000001 USD 100 audit return issued and applied on POL-2026-0000004.
- Full matrix: 269 suites, 2,590 tests; contracts 12,561 checks; 201 events; live 17/17.


## Round 42: document content versions

- Immutable document content versions; current pointer + full history.
- Version list/download routes; currentVersion in metadata and upload events.
- File tab shows current version and history with old-version downloads.
- Live: DOC-2026-0000001 v2 evidence-v2.pdf, v1 evidence.pdf retained and downloadable.
- Full matrix: 271 suites, 2,610 tests; contracts 12,657 checks; 201 events; live 17/17.


## Round 43: technical account lines

- Statement lines by PREMIUM/LOSS/COMMISSION/OTHER with reference/description/amount.
- DRAFT-only line editing; issue reconciles line totals to header components.
- UI expandable accounts with lines, totals, reconciliation, 409 detail.
- Events line-added/line-removed.
- Live: TA-2026-00002 four lines totaling 50k/10k/7.5k/250; issued reconciled.
- Full matrix: 275 suites, 2,678 tests; contracts 12,857 checks; 203 events; live 17/17.


## Round 44: policy legal entities

- Legal entity catalog: code, name, type, jurisdiction, regulator, license, status.
- Policy issuing-entity assignment/clear with version/ETag.
- Legal entity tab with current entity, attach, create, detach.
- Events policy.legal-entity.created and policy.policy.legal-entity-assigned.
- Live: EIA-INS-US INSURER attached/detached on POL-2026-0000004.
- Full matrix: 282 suites, 2,753 tests; contracts 13,143 checks; 205 events; live 17/17.


## Round 45: expanded technical line types

- 13 detail line types with four-bucket roll-up; LOSS retired.
- Issue reconciliation uses bucket totals; mismatch names contributing types.
- UI type/bucket totals and 13 add-line options.
- Live: TA-2026-00003 lines PREMIUM/PAID_LOSS/ALAE/BROKERAGE/FUNDS_WITHHELD issued reconciled.
- Full matrix: 284 suites, 2,787 tests; contracts 13,190 checks; 205 events; live 17/17.


## Round 46: credit note application

- APPLIED credit notes now target a DUE/OVERDUE installment.
- Partial credit reduces outstanding; full credit marks CREDITED.
- Billing summary adds creditedAmount and net outstanding; receivables use outstanding.
- UI apply modal lists eligible installments, shows applied installment, net amounts.
- Live: CN-0000002 USD 100 applied to installment 3; credited 100, outstanding 400; receivable net 150.
- Full matrix: 285 suites, 2,806 tests; contracts 13,282 checks; 205 events; live 17/17.


## Round 47: program capacity

- Programs carry optional capacity amount/currency.
- Usage = sum of assigned policy limits; utilization %, policy count.
- Program tab shows capacity, used, utilization bar, over-capacity state.
- Live: PRG-2026-0000002 capacity 2,000,000, used 100,000, 5%.
- Full matrix: 285 suites, 2,831 tests; contracts 13,320 checks; 205 events; live 17/17.


## Round 48: document legal holds and disposition

- Place/release legal hold with reason; blocks disposition.
- Dispose only after retention date and no hold; tombstone + audit retained.
- Retention tab shows hold/disposition state and actions.
- Events legal-hold.placed/released and document.document.disposed.
- Live: DOC-2026-0000001 ACTIVE -> ON_HOLD; dispose 409; release -> ACTIVE.
- Full matrix: 289 suites, 2,880 tests; contracts 13,501 checks; 210 events; live 17/17.


## Round 49: auth foundation

- Auth service supports password grant for eia-shell: adjuster/password -> JWT.
- Issuer configurable; default http://localhost:9000; JWKS endpoint works.
- Gateway has opt-in JWT validation (eia.auth.enabled=false by default), issuer/signature/scope tests.
- Live K8s token: 3-part JWT, iss=http://localhost:9000, sub=adjuster, aud=eia-shell, scope openid/profile/eia.read; JWKS 1 RSA key.
- Gateway auth remains disabled until the shell login flow lands.
- Full matrix: 293 suites, 2,897 tests; contracts 13,501 checks; 210 events; live 17/17.

## Round 50: authentication enabled end to end

- Shell login (password grant) at /auth/oauth2/token through same-origin nginx proxy.
- JWT stored; fetch and XHR attach Bearer for /api; 401 clears and returns to login.
- Gateway JWT validation enabled in K8s; issuer http://localhost:3000/auth, JWKS internal.
- Auth service issuer set to the proxied URL.
- Manual: no token 401, valid token 200; UI login renders authenticated dashboard.
- Live suite signs in per test: 17/17.
- Full matrix: 293 suites, 2,897 tests; contracts 13,501 checks; 210 events.


## Round 51: auth scopes, actor, and refresh

- eia.read/eia.write scopes; gateway authorizes GET vs mutating methods.
- Authenticated JWT sub propagates as X-EIA-Actor when the caller omits it.
- Shell requests write scope and refreshes on 401, replaying once; concurrent 401s share one refresh.
- Auditor user is read-only; explicit eia.write is rejected.
- Password grants exclude openid so refresh does not need an authorization code.
- Live: adjuster token scope profile/eia.read/eia.write; auditor GET 200, POST 403; adjuster POST 400 validation (authorized); refresh returns new JWT.
- Full matrix: 295 suites, 2,919 tests; contracts 13,501 checks; 210 events; live 17/17.


## Round 52: tenant-bound tokens

- Access tokens carry tenant_id and roles (CLAIMS_ADJUSTER/AUDITOR).
- Gateway injects X-EIA-Tenant when absent and rejects mismatches with 403 TENANT_FORBIDDEN.
- Missing tenant claim fails closed for protected paths; directory/health remain public.
- Live: token tenant 1111.../CLAIMS_ADJUSTER; matching header 200; wrong header 403; missing header injected -> 200.
- Full matrix: 296 suites, 2,939 tests; contracts 13,501 checks; 210 events; live 17/17.


## Round 53: credit note reversal

- APPLIED -> REVERSED with required reason; installment credit restored.
- CREDITED reopens to DUE/OVERDUE; billing/receivables recalculate.
- Event policy.credit-note.reversed.
- UI Reverse action with reason, REVERSED row and reversal details.
- Live: CN-0000002 USD 100 reversed; credited 100 -> 0, outstanding 400 -> 500; receivable 500.
- Full matrix: 296 suites, 2,963 tests; contracts 13,558 checks; 210 events; live 17/17.


## Round 54: cash call settlement references

- SETTLED cash calls require a non-blank payment/settlement reference.
- Cash call DTO and settled event carry settlementReference.
- ISSUED calls link to Payment with sourceType CONTRACT_CASH_CALL.
- UI settle modal validates the reference; settled rows show it.
- Live: CC-2026-00001 settled with PAY-2026-000042; CC-2026-00002 ISSUED with Create payment.
- Full matrix: 296 suites, 2,976 tests; contracts 13,576 checks; 210 events; live 17/17.


## Round 55: cancellation-linked credit notes

- Cancellations carry CX-{7} numbers; credit notes can link one cancellation.
- Linked create enforces same policy, ACTIVE cancellation, exact return premium (0.01) and currency; one note per cancellation.
- New event policy.credit-note.created.
- UI creates a locked return-premium credit note from Cancellation and links the ledger.
- Cancellation number exposed through domain.
- Full matrix: 296 suites, 2,994 tests; contracts 13,645 checks; 210 events; live 17/17.
- Live cancellation initially returned 409 VERSION_RANGE_OVERLAP because a DRAFT version remained current; fixed in Round 56 and then exercised live.


## Round 56: version timeline fix and live cancellation credit

- VersionIssuer now treats the latest non-superseded DRAFT or ISSUED version as current.
- supersede closes DRAFT as well as ISSUED, so a change on an unissued initial version no longer overlaps.
- Live: POL-2026-0000004 cancelled PRO_RATA 2026-10-22; CX-0000001; return premium 194.5210; status ACTIVE.
- Live: CN-0000003 created from the cancellation, amount 194.5210 USD, linked to CX-0000001.
- UI shows Credit note created · CN-0000003 in the Cancellation tab.
- Full matrix: 296 suites, 2,994 tests; contracts 13,645 checks; 210 events; live 17/17.


## Round 57: technical account settlement references

- SETTLED technical accounts require a non-blank payment/settlement reference.
- Technical account DTO and settled event carry settlementReference.
- UI settle modal requires the reference and shows it on settled statements.
- Live: TA-2026-00003 settled with SET-2026-000088.
- Full matrix: 296 suites, 3,005 tests; contracts 13,688 checks; 210 events; live 17/17.


## Round 58: claim settlement payment links

- Settlements link to one claim payment; link/unlink with claim version and event.
- Settlement DTO exposes paymentId/paymentLinkedAt.
- UI Payment column, PAID payment picker, unlink, no-PAID guidance.
- Event direct.claim.settlement-payment-linked.
- Live: SET-2026-0000001 linked to PAY-2026-0000002 (demo payment marked PAID); claim progress Payment step current.
- Full matrix: 296 suites, 3,032 tests; contracts 13,815 checks; 210 events; live 17/17.


## Round 59: payment execution lifecycle

- Public PATCH /api/v1/payments/{id}/status proxied to the expert.
- UI drives DRAFT -> PENDING_AUTHORITY -> AUTHORIZED -> APPROVED -> SCHEDULED -> SUBMITTED -> ACCEPTED -> PROCESSING -> PAID -> RECONCILED with versioned transitions.
- Mark paid and Reconcile require confirmation; 409 reloads and contains.
- Live: PAY-2026-0000003 driven through all 10 states, version 0 -> 9, final RECONCILED.
- Full matrix: 296 suites, 3,043 tests; contracts 13,978 checks; 210 events; live 17/17.


## Round 60: payment terminal actions

- Cancel, Void, and Stop actions mapped by status; reasons required for Void/Stop.
- Expert validates reason <=200 before persistence (400, not 502).
- Live: overlong reason 400; PAY-2026-0000001 VOID v1 with reason; new DRAFT payment shows Cancel/Void.
- Full matrix: 296 suites, 3,063 tests; contracts 13,978 checks; 210 events; live 17/17.
