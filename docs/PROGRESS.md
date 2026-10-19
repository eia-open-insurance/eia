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

