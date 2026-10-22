# Implementation progress

## Completed

- 37-repository topology: 30 vertical repositories, 7 platform repositories.
- Gradle 8.14.3 Kotlin DSL for all Java repositories; Maven removed.
- Platform runtime: gateway, auth (OIDC authorization code), config, lineage.
- Ten vertical first slices, each with:
  - expert service with PostgreSQL persistence and schema bootstrap
  - domain service with tenant/book guards, lifecycle rules, and structured errors
  - React 19 / Webpack 5 Module Federation remote
  - JUnit tests and a Playwright workbench test
- Shell routes all ten federated vertical remotes.
- Canonical OpenAPI 3.1, AsyncAPI 3, and JSON Schema contracts.
- Deterministic FS-RI, S/4, bank, email, OCR, and sanctions simulators with 34 tests and 22 cross-system journey checks.
- Local Compose, Kubernetes, and Helm deployment assets with 41 offline validation checks.
- Local stack of 35 processes starts and reports healthy.
- Gateway smoke test passes for all ten vertical APIs.
- Shell end-to-end navigation passes for all ten verticals.
- OIDC authorization-code flow verified.
- Full repository build/test: 67 JUnit suites, 509 tests, 0 failures; 12 Playwright suites including the opt-in live all-vertical suite.\n- Policy hardened with RFC 9457 errors, pagination, ETag/If-Match, and idempotent creates.\n- Transactional outbox library and Party event emission.\n- Cession/Retrocession FS-RI simulator hand-off with atomic confirmation persistence.\n- PostgreSQL connection pools capped; max_connections raised for the 35-process local stack.

## Open gaps

- Coverage, limits, endorsements, policy versions, claims depth, litigation, reserves history, settlements, recoveries, and bordereaux are not implemented beyond the first aggregate.
- No transactional outbox/inbox, event publisher, or subscriber; all 151 events are planned only.
- No RLS, gateway JWT validation, role enforcement, or full RBAC; services trust tenant/book headers.
- No decision/payment approval evidence, segregation of duties, or authority engine.
- FS-RI and S/4 adapters are simulators only; no live hand-off wiring from Cession/Retrocession.
- No pagination, ETag/If-Match, `_links`, or `Idempotency-Key` across the API surface.
- Error envelopes remain inconsistent; the canonical RFC 9457 shape is not applied everywhere.
- Contract field-name and base-path deviations remain documented in `eia-contracts/MISMATCHES.md`.
- Kubernetes was not executed because Docker Desktop/WSL2 requires a Windows reboot.
- Production gates 1, 5, 6, 7, and 8 are not evidenced.


## Round 4: Kubernetes execution

- Docker Desktop Linux engine and minikube are operational after reboot.
- 37/37 pods Ready in namespace `eia-local`: 4 platform services, 10 experts, 10 domains, 10 web remotes, shell, FS-RI simulator, PostgreSQL.
- 10/10 vertical APIs pass through the cluster gateway.
- 10/10 federated vertical UIs load through the Kubernetes-hosted shell.
- FS-RI hand-off verified in-cluster: cession `CES-000000001` is `HANDED_OFF` with `fsriStatus=POSTED`.
- Two Ingresses (`eia`, `eia-remotes`) and 45 deployment-asset checks pass.
- Remaining: signed runtime federation manifest/SRI, production FS-RI adapter, TLS/mTLS, HA PostgreSQL.

## Round 6: UI/UX and operational depth

- Shared CSS design system applied across all federated verticals.
- Operations dashboard with claims, policy, contract, payment, document, and notification metrics.
- Context header with tenant, book, environment, role, and date.
- Policy second slice: versions, coverages/limits, endorsements, insureds/locations, cancellation.
- Contract second slice: layers, participants, terms, security, cessions, bordereaux, commutation, bind.
- Direct Claims second slice: injuries, exposures, reserve history, coverage, litigation, settlement, recovery, liens.
- Assumed Claims second slice: loss advice, bordereaux, reserve history, cash calls, recovery, commutation, disputes, audit.
- Outbox publishers added to Cession, Retrocession, Document, Payment, Notifications.
- Full matrix: 137 JUnit suites, 1,130 tests, 0 failures; exit 0.

## Round 7: event-driven platform

- Transactional outbox producers added to Policy, Contract, Direct Claims, and Assumed Claims; all ten verticals now publish.
- Event-ingest inbox deployed with idempotency, HMAC verification, conflict detection, and read APIs.
- Kubernetes and Compose deliver signed events from every expert.
- Dashboard event stream shows processed counts, event types, latest deliveries, and live status.
- Full matrix: 156 suites, 1,206 tests, 0 failures.

## Round 8: search-first operational UX

- Global search across all ten verticals with grouped results and create actions.
- Deep links, queue filters, and predictive pickers across all ten workbenches.
- Cross-links and process-context panels between policy, claim, party, contract, cession, retrocession, payment, and notification records.
- Search contracts and validation: 8,874 checks.
- Full matrix: 167 suites, 1,324 tests, 0 failures.

## Round 9: search workspace and claim progress

- Dedicated search page with facets, saved searches, create actions, and global search hand-off.
- Party-to-policy cross-links using the insured-party policy filter.
- Claim progress steppers for Direct and Assumed Claims with next-step guidance.
- Full matrix: 168 suites, 1,333 tests, 0 failures.

## Round 10: claim diary and notes

- Claim task and note persistence, APIs, and outbox events.
- Diary & Notes workbench with overdue tasks, completion, version conflicts, and append-only notes.
- Open tasks summary and live event-ingest confirmation.
- Full matrix: 173 suites, 1,400 tests, 0 failures; contracts 9,155 checks.

## Round 11: Assumed Claims diary

- Task and note persistence, APIs, and outbox events for Assumed Claims.
- Diary & Notes workbench, Open tasks summary, overdue handling, version conflicts.
- Live event inbox and browser evidence; contracts 9,361 checks; 176 events.
- Full matrix: 180 suites, 1,481 tests, 0 failures.

## Round 12: settlement-to-payment hand-off

- Payment source linkage, source-aware search, and created-event payload.
- Settlement hand-off with prefilled payment and source link back to the claim.
- Related payments on the claim with hydrated amounts.
- Contracts 9,411 checks; full matrix 181 suites, 1,508 tests, 0 failures.

## Round 13: idempotent diary writes

- Idempotency-Key support and replay/conflict semantics for task/note creates.
- Stable UI keys across retries; new key after success.
- Contract 9,470 checks; full matrix 185 suites, 1,568 tests.

## Round 14: claim ownership

- Adjuster/team assignment with optimistic versioning and outbox events in both claims books.
- Ownership in headers, summaries, queue rows, and filters; audited reassignment.
- Search enriches insured-party hits with policies.
- Contracts 9,656 checks; full matrix 192 suites, 1,652 tests, 0 failures.

## Round 15: work queue and ownership

- Cross-book /work queue with My work, Unassigned, and Team views.
- Dashboard ownership summary.
- Claim assignment with adjuster/team, optimistic versioning, audit, and events.
- Search enrichment for insured-party policies.
- Contracts 9,656 checks; 192 suites, 1,652 tests; live 17/17.

## Round 16: supervisory work queue

- Aging and team workload analytics.
- Highlighted search matches.
- Atomic Direct idempotency under concurrency.
- Assignment validation/actor alignment.
- 192 suites, 1,656 tests; live 17/17.

## Round 17: document associations

- Document-to-record links with predictive picker, filter, and canonical events.
- Link CRUD and duplicate/wall handling.
- Contracts 9,865 checks; 180 events; 197 suites, 1,707 tests.

## Round 18: reverse document links

- Linked-document cards on claims, policies, parties, contracts, payments.
- Document evidence is visible from both directions.
- Full matrix 197 suites, 1,707 tests; contracts 9,865 checks; live 17/17.

## Round 19: activity timeline

- Tenant-scoped aggregate event query.
- Activity tabs on claim, policy, payment.
- Full matrix 198 suites, 1,726 tests; contracts 9,865 checks; live 17/17.

## Round 20: activity everywhere

- Activity timelines on all ten verticals and Party.
- Full matrix 198 suites, 1,726 tests; contracts 9,865 checks; live 17/17.

## Round 21: directory and capacity

- Public people/team directory.
- Directory-backed assignment in both claims books.
- Adjuster workload in the work queue.
- 199 suites, 1,732 tests; live 17/17.

## Round 22: billing and directory

- Policy billing plans/installments with payment hand-off.
- Gateway people/team directory and directory-backed assignment.
- Adjuster workload.
- Contracts 10,105 checks; 183 events; 204 suites, 1,784 tests; live 17/17.

## Round 23: renewal

- Policy renewal with lineage and copied terms.
- Contracts 10,171 checks; 208 suites, 1,817 tests; live 17/17.

## Round 24: payment traceability

- Source-filtered payment list.
- Claim Payments cards in both books.
- Contracts 10,199 checks; 209 suites, 1,837 tests; live 17/17.

## Round 25: technical accounts

- Contract technical accounts with lifecycle and events.
- Contracts 10,406 checks; 186 events; 213 suites, 1,899 tests; live 17/17.

## Round 26: bordereaux

- Contract period bordereaux with processing to technical accounts.
- Contracts 10,593 checks; 188 events; 217 suites, 1,964 tests; live 17/17.

## Round 27: claim allocations

- Policy-year/layer claim allocations with 100% guard.
- Contracts 10,738 checks; 189 events; 220 suites, 2,015 tests; live 17/17.

## Round 28: receivables

- Cross-policy premium receivables queue and dashboard card.
- Contracts 10,847 checks; 225 suites, 2,052 tests; live 17/17.

## Round 29: mass tort profile

- Policy mass-tort profile and validation.
- Contracts 11,032 checks; 230 suites, 2,098 tests; live 17/17.

## Round 30: claimant search

- Party hits enrich with policies and direct claims.
- Contract 11,054 checks; 231 suites, 2,117 tests; live 17/17.

## Round 31: billing payment application

- Link existing policy payments to installments.
- Contracts 11,054 checks; 231 suites, 2,117 tests; live 17/17.

## Round 32: cash calls

- Contract cash calls with lifecycle and events.
- Contracts 11,292 checks; 192 events; 235 suites, 2,187 tests; live 17/17.

## Round 33: payment allocations

- Payment allocation ledger and predictive target picker.
- Contracts 11,477 checks; 193 events; 238 suites, 2,223 tests; live 17/17.

## Round 34: allocation erosion

- Allocation-to-policy limit erosion with status/retry.
- Contracts 11,527 checks; 239 suites, 2,271 tests; live 17/17.

## Round 35: contract security

- Contract security collateral records.
- Contracts 11,646 checks; 244 suites, 2,309 tests; live 17/17.

## Round 36: dunning

- Installment dunning actions and receivables visibility.
- Contracts 11,808 checks; 250 suites, 2,356 tests; live 17/17.

## Round 37: mass-tort guard

- Allocation coverage-block enforcement.
- Contracts 11,809 checks; 251 suites, 2,369 tests; live 17/17.

## Round 38: policy programs

- Program catalog and policy membership.
- Contracts 12,109 checks; 258 suites, 2,437 tests; live 17/17.

## Round 39: document content

- File upload/download for document evidence.
- Contracts 12,255 checks; 262 suites, 2,481 tests; live 17/17.

## Round 40: security lifecycle

- Collateral release/expire and dedicated panel.
- Contracts 12,333 checks; 263 suites, 2,526 tests; live 17/17.

## Round 41: credit notes

- Policy credit notes with lifecycle and billing visibility.
- Contracts 12,561 checks; 269 suites, 2,590 tests; live 17/17.

## Round 42: document versions

- Immutable content revisions and history.
- Contracts 12,657 checks; 271 suites, 2,610 tests; live 17/17.

## Round 43: technical account lines

- Statement line detail and issue reconciliation.
- Contracts 12,857 checks; 275 suites, 2,678 tests; live 17/17.

## Round 44: legal entities

- Legal entity catalog and policy issuing-entity assignment.
- Contracts 13,143 checks; 282 suites, 2,753 tests; live 17/17.

## Round 45: technical line types

- 13 detailed line types with bucket roll-up.
- Contracts 13,190 checks; 284 suites, 2,787 tests; live 17/17.

## Round 46: credit application

- Credit notes applied to installments with net billing/receivables.
- Contracts 13,282 checks; 285 suites, 2,806 tests; live 17/17.

## Round 47: program capacity

- Program capacity/usage and utilization.
- Contracts 13,320 checks; 285 suites, 2,831 tests; live 17/17.

## Round 48: document holds

- Legal holds and disposition with retention gating.
- Contracts 13,501 checks; 289 suites, 2,880 tests; live 17/17.

## Round 49: auth foundation

- Password-grant JWT issuance and opt-in gateway validation.
- 293 suites, 2,897 tests; live 17/17.

## Round 50: auth enabled

- Shell login, bearer injection, gateway enforcement, live login per test.
- 293 suites, 2,897 tests; live 17/17.

## Round 51: auth scopes and refresh

- Read/write scopes, actor propagation, refresh retry.
- 295 suites, 2,919 tests; live 17/17.

## Round 52: tenant binding

- Tokens carry tenant/roles; gateway rejects tenant mismatches.
- 296 suites, 2,939 tests; live 17/17.

## Round 53: credit reversal

- APPLIED -> REVERSED restores installment credit.
- 296 suites, 2,963 tests; contracts 13,558 checks; 208 events; live 17/17.

## Round 54: cash call settlement

- Settlement references and Payment handoff for cash calls.
- 296 suites, 2,976 tests; contracts 13,576 checks; live 17/17.

## Round 55: cancellation credit notes

- Linked return-premium credit notes and cancellation numbers.
- 296 suites, 2,994 tests; contracts 13,645 checks; 209 events; live 17/17.
- Found seeded-policy version overlap blocking live cancellation; to fix next.

## Round 56: withdrawal version fix

- DRAFT current version superseded on change; live cancellation + linked credit note.
- 296 suites, 2,994 tests; contracts 13,645 checks; 209 events; live 17/17.

## Round 57: technical settlement

- Technical account settlement references.
- 296 suites, 3,005 tests; contracts 13,688 checks; live 17/17.

## Round 58: settlement payment links

- Claim settlement to payment link, UI picker, event.
- 296 suites, 3,032 tests; contracts 13,815 checks; 210 events; live 17/17.

## Round 59: payment lifecycle

- Payment execution transitions and UI timeline.
- 296 suites, 3,043 tests; contracts 13,978 checks; live 17/17.

## Round 60: payment terminal actions

- Cancel/Void/Stop controls and reason validation.
- 296 suites, 3,063 tests; live 17/17.

## Round 61: reinstatement guard

- Block reinstatement on open cancellation credit notes.
- 297 suites, 3,078 tests; live 17/17.

## Round 62: content tombstones

- Document content deletion with retained audit and hold protection.
- 298 suites, 3,100 tests; contracts 14,058 checks; 211 events; live 17/17.

## Round 63: dunning notice handoff

- DUNNING_NOTICE type and prefilled notification draft from receivables.
- 298 suites, 3,103 tests; contracts 14,069 checks; live 17/17.

## Round 63 (cont.): dunning template

- Seeded ACTIVE DUNNING_NOTICE template v1; handoff binds it; create + send succeed.

## Round 64: post-payment exceptions

- Return, reverse, escheat, reschedule controls.
- 298 suites, 3,129 tests; live 17/17.

## Round 65: read-only auditor

- Scope fallback and read-only session UI.
- 298 suites, 3,129 tests; live 17/17.

## Round 66: disposition content

- Disposition destroys content automatically.
- 299 suites, 3,134 tests; contracts 14,088 checks; live 17/17.

## Round 67: payment status reasons

- Expose and display latest payment status reason.
- 300 suites, 3,141 tests; contracts 14,098 checks; live 17/17.

## Round 68: recent records

- Recent records in global search and /search.
- 300 suites, 3,141 tests; contracts 14,098 checks; live 17/17.

## Round 69: version issuance hardening

- Close all open versions transactionally on issuance.
- 302 suites, 3,144 tests; live 17/17.

## Round 70: saved searches

- Saved searches, lens filters, apply/delete.
- 302 suites, 3,144 tests; live 17/17.

## Round 71: payment link mismatch warnings

- Surface reversed payments linked to policy installments and claim settlements.
- 302 suites, 3,144 tests; contracts 14,098 checks; live 17/17.

## Round 72: allocation reversal

- Append-only allocation reversal with net/reversed summary.
- 303 suites, 3,169 tests; contracts 14,205 checks; 212 events; live 17/17.

## Round 73: notification templates

- Template registry with draft/approve/retire.
- 309 suites, 3,244 tests; contracts 14,465 checks; 215 events; live 17/17.

## Round 74: template versioning

- New version from existing template.
- 309 suites, 3,244 tests; live 17/17.

## Round 75: premium audit

- Premium audit command + UI.
- 315 suites, 3,294 tests; contracts 14,576 checks; 216 events; live 17/17.

## Round 76: billing variance

- Surface policy premium vs plan total mismatch.
- 315 suites, 3,294 tests; live 17/17.

## Round 77: retention scheduler

- Automatic disposition at retention expiry.
- 320 suites, 3,303 tests; live 17/17.

## Round 78: net billing variance

- Variance net of credits.
- 320 suites, 3,303 tests; live 17/17.

## Round 79: billing adjustment

- Positive adjustment installment and negative credit-note guidance.
- 323 suites, 3,351 tests; contracts 14,694 checks; 217 events; live 17/17.

## Round 80: litigation damages

- Pleaded damages and predictive counsel picker.
- 324 suites, 3,376 tests; contracts 14,825 checks; 218 events; live 17/17.

## Round 81: notification source

- Source linkage and links.
- 325 suites, 3,404 tests; contracts 14,914 checks; live 17/17.

## Round 82: related notifications

- Claim/policy cards and source-filtered notification queue.
- 326 suites, 3,427 tests; contracts 14,947 checks; live 17/17.

## Round 83: notification cards everywhere

- Payment, contract, assumed claim cards.
- 326 suites, 3,427 tests; live 17/17.

## Round 84: party master data

- Identifiers and addresses.
- 330 suites, 3,465 tests; contracts 15,375 checks; 220 events; live 17/17.

## Round 85: party status

- Party lifecycle transitions.
- 330 suites, 3,478 tests; contracts 15,478 checks; live 17/17.

## Round 86: reinsurance notifications

- Cession/retro cards and source types.
- 330 suites, 3,483 tests; contracts 15,481 checks; live 17/17.
