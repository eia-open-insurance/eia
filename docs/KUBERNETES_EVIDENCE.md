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
