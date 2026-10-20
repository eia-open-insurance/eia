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
