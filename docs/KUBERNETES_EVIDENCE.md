# Kubernetes local evidence

Cluster: minikube profile `minikube`, Kubernetes v1.37.0, Docker driver, namespace `eia-local`.

## Final workload state

```text
37 pods total
37 pods Running and Ready
2 Ingresses: eia, eia-remotes
```

- 4 platform services: gateway, auth, config, lineage
- 10 experts and 10 domains
- 10 federated web remotes
- shell
- FS-RI simulator
- PostgreSQL 17

## API smoke test

Through the gateway:

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

## Federated UI

The shell is served from the cluster and loads remotes from relative `/remotes/<vertical>/remoteEntry.js` paths.

```text
npx playwright test tests/live-all.spec.js
10 passed (5.7s)
```

All ten vertical workbenches loaded through the Kubernetes-hosted shell.

## Policy conformance in-cluster

```text
POST /api/v1/policies -> 201, ETag "0"
replay same Idempotency-Key -> 200, Idempotent-Replayed: true
GET ?page=0&size=1 -> page envelope with total
```

## FS-RI hand-off in-cluster

```text
cessionNumber   status       fsriStatus   fsriHandoffId
CES-000000001   HANDED_OFF   POSTED       FSRI-CES-DIRECT-000001
```

The Cession domain ran with `EIA_FSRI_BASE_URL=http://eia-fsri-simulator:8181` and persisted the FS-RI confirmation.

## Ingress

```text
NAME          CLASS   HOSTS       ADDRESS        PORTS
eia           nginx   eia.local   192.168.49.2   80
eia-remotes   nginx   eia.local   192.168.49.2   80
```

The shell nginx config proxies `/remotes/<vertical>/` to the corresponding Service, so both ingress and direct shell port-forward work.

## Verification commands

```powershell
kubectl -n eia-local get pods
pwsh ./repos/smoke-local.ps1 -Gateway http://localhost:8080
pwsh ./repos/eia-ops/scripts/validate.ps1
```

The local stack is test-double based: FS-RI is the deterministic eia-quality simulator, PostgreSQL is a single replica, and no TLS/mTLS is configured.


![Kubernetes-hosted Policy workbench](images/kubernetes-shell.png)


## Operational UI

![Claims operations dashboard](images/operations-dashboard.png)

The shell now has a shared design system, contextual header, operations dashboard, and consistent vertical navigation. The dashboard aggregates direct/assumed claims, policies, contracts, cession/retrocession hand-offs, documents, payments, and notifications.

![Policy workspace](images/policy-workspace.png)

![Direct Claims workspace](images/direct-claims-workspace.png)

### Record detail

The Policy record opens into version, coverage, endorsement, insured/location, and cancellation tabs.

![Policy record detail](images/policy-detail.png)

Direct Claims opens into injury, reserve, coverage, litigation, settlement, and recovery tabs.

![Direct claim detail](images/claim-detail.png)

## Shared record redesign

Policy, Contract, Direct Claims, and Assumed Claims now use the same record layout: left queue, right record header, summary cards, canonical tabs, form grids, tables, and action hierarchy.

- Policy detail tabs: Overview, Versions, Coverages & Limits, Endorsements, Insureds & Locations, Cancellation.
- Direct claim tabs: Overview, Injuries & Exposures, Reserve History, Coverage, Litigation, Settlements, Recovery & Liens.
- Assumed claim tabs: Overview, Loss Advice, Reserve History, Cash Calls, Recoveries, Commutation, Disputes, Audit.
- Contract tabs: Overview, Layers, Participants, Terms, Security, Cessions, Bordereaux, Commutation.

After the redesign, the live Kubernetes browser suite passed **10/10** in 6.0 seconds.

## Consistent workbench coverage

All ten workbenches now use the shared queue-record-summary-tabs pattern:

- Party
- Policy
- Contract
- Direct Claims
- Assumed Claims
- Cession
- Retrocession
- Document
- Payment
- Notifications

The UI uses the same header, queue, record panel, summary cards, tab strip, form grid, tables, badges, and action hierarchy.

![Party record](images/party-workspace.png)

![Payment record](images/payment-workspace.png)

![Cession record](images/cession-workspace.png)

![Document record](images/document-workspace.png)

## Event pipeline

- `eia-event-ingest` Deployment and Service are live in `eia-local`.
- All ten expert Deployments carry the transactional outbox endpoint and signing secret.
- Event Stream dashboard card is fed by `/api/v1/events/stats` and `/recent`.
- Live smoke: 14 events processed, 0 failed; 38/38 pods Ready.

## Global record search

The shell now carries a persistent Ctrl+K search across all ten verticals. It groups results, shows record status and secondary context, supports keyboard navigation, and offers create actions for every record type.

![Global search](images/global-search.png)

![Predictive form entry](images/predictive-form.png)

- Search endpoints are tenant-scoped and book-walled.
- Deep links (`?record=`) select the record in its workbench.
- `?new=1` opens creation from search.
- Cross-links navigate between related records in the SPA.
- Live suite after deployment: **13/13 passed**, including search-open-record and search-create-claim.

## Search workspace and process steps

![Search workspace](images/search-workspace.png)

The dedicated search page adds type and status facets, result counts, saved searches, and create actions. Global Ctrl+K search remains available on every page and links to this workspace.

![Claim progress stepper](images/claim-stepper.png)

Direct and Assumed Claims now show a process stepper with completed, current, denied, and upcoming steps plus a “What happens next” explanation.

![Party policies](images/party-policies.png)

Party records cross-link to their direct policies through the new `insuredPartyId` policy filter.

Live browser suite after rollout: **14/14 passed**.

## Claim diary and notes

![Direct claim diary](images/diary-notes.png)

The Direct Claims record now includes a Diary & Notes tab:

- task number, title, due date, priority, assignee, status
- overdue highlight
- Add task modal, Complete/Reopen with optimistic versioning
- newest-first claim notes with type, author, timestamp
- Open tasks summary card

Live end-to-end check in `eia-local`:

1. Opened `CLM-2026-0000001`.
2. Created task `TSK-2026-0000001` with due date 2027-01-15.
3. Completed it; summary changed from 1 open task to 0.
4. Added a `DIARY` note; it appeared at the top of the timeline.
5. Event inbox received `direct.claim.task-created`, `direct.claim.task-completed`, and `direct.claim.note-added`.

The claim progress stepper remains visible above the tabs.

## Diary contracts

The Direct Claims OpenAPI now includes task/note routes and schemas. AsyncAPI adds `direct.claim.task-created`, `task-completed`, `task-updated`, and `note-added`; the catalog has 172 published events. Validation: **9,155 checks, 0 failures**.

## Assumed claim diary

![Assumed claim diary](images/assumed-diary.png)

Assumed Claims now mirrors the Direct Claims Diary & Notes workspace:

- task list with overdue highlighting, priorities, assignees, status
- add task, complete/reopen with optimistic versioning
- newest-first notes with type, author, timestamp
- Open tasks summary card
- ASSUMED book wall and process stepper preserved

Live evidence on `RNS-2026-0000002`:

1. Created `TSK-2026-0000001`, due 2027-02-01, priority NORMAL.
2. Completed it; Open tasks moved from 1 to 0.
3. Event inbox received `assumed.claim.task-created` and `assumed.claim.task-completed`.

Live suite after rollout: **16/16 passed**, including both claim diary tabs.

## Settlement-to-payment hand-off

![Settlement payment hand-off](images/payment-handoff.png)

Direct Claims hands an authorized settlement to Payment with amount, currency, payee, and source claim prefilled.

![Payment source record](images/payment-source.png)

Payment preserves `sourceType=DIRECT_CLAIM`, `sourceId`, and `sourceReference`, shows the source link, and appears back on the claim.

![Claim related payments](images/claim-payments.png)

Live evidence:

1. Authorized `SET-2026-0000001` on `CLM-2026-0000001`.
2. Clicked **Create payment**; Payment opened with $15,000 / USD / Jordan Claimant / source CLM-2026-0000001.
3. Saved `PAY-2026-0000002` with source linkage.
4. Claim Settlements tab shows the related payment with amount.
5. Payment search finds the payment by claim id.

## Idempotent diary writes

Direct and Assumed Claims task/note creates now accept `Idempotency-Key` and store the response in `claim_command_idempotency`.

Live evidence in `eia-local`:

- first direct task POST: `replay=false`, new ID
- identical replay: same ID, `replay=true`, no duplicate/event
- changed body with the same key: `409`
- assumed claims: identical replay returned the same ID with `replay=true`

The browser forms generate a UUID per create attempt and reuse it only while the attempt is unresolved.

## Claim ownership

![Direct claim assigned](images/claim-assigned.png)

Both claims books now show the owner in the record header, summary, and queue, with an Assign action.

Live evidence:

- `CLM-2026-0000001` assigned to `A. Adjuster` / `DIRECT_CLAIMS`.
- `RNS-2026-0000002` assigned to `B. Examiner` / `ASSUMED_CLAIMS`.
- Both assignment events reached the event inbox.
- Queue filters match owner, team, and Unassigned.

## Insured-name search

Searching `Acme` now returns the Acme party plus its direct policies (`POL-2026-…`) by resolving `GET /api/v1/policies?insuredPartyId=…` for the matched party. Clicking a policy opens the policy record.

## Cross-book work queue

![Work queue](images/work-queue.png)

The work queue shows:

- My work
- Unassigned work
- Team queue
- Direct/assumed split
- book filter, owner/team filter, closed toggle
- open claim from the queue

Dashboard adds My work cards for direct, assumed, and unassigned claims. Owner assignment is visible in the claim header, summary, and queue, and emits `direct.claim.assigned` / `assumed.claim.assigned`.

Live suite after rollout: **17/17 passed**.

## Supervisory workload and hardening

![Work queue workload](images/work-queue.png)

The work queue now includes:

- open, unassigned, team queue, and aged 30+ cards
- team workload table with open/unassigned/aged/oldest claim
- aging measured from loss date
- highlighted search matches

Hardening:

- Direct idempotency reservation now uses atomic `ON CONFLICT DO NOTHING`; concurrent same-key creates produce one row/event and one replay, not a constraint error.
- Direct negative assignment `expectedVersion` returns 400.
- Direct assignment accepts only `X-EIA-Actor`.
- Assumed audit accepts `CLAIM_ASSIGNED`.
- M-25 assignment contract gaps closed.

## Document association links

![Document associations](images/document-links.png)

The Document Associations tab now supports predictive linking to:

- direct claims
- assumed claims
- policies
- contracts
- parties
- payments
- manual OTHER reference

Live evidence:

1. Opened `DOC-2026-0000001`.
2. Added a DIRECT_CLAIM link to `CLM-2026-0000001`.
3. The link appeared with type, reference, linked record, and added time.
4. `GET /api/v1/documents?linkedType=DIRECT_CLAIM&linkedId=…` returned the document.
5. Event inbox received `document.link.added`.
