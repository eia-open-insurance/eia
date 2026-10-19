# EIA Open Insurance

**An open-source policy, claims, and reinsurance administration suite for commercial mass tort and reinsurance.**

- Organization: [github.com/eia-open-insurance](https://github.com/eia-open-insurance)
- Specification: [SPEC.md](SPEC.md)
- License: Apache License 2.0
- Status: specification complete; local first vertical slice implemented and running. **Not production-ready.**

## What this is

EIA Open Insurance is a specification-first insurance administration platform for two separate books:

| Book | Policy administration | Claims administration | Reinsurance |
|---|---|---|---|
| `DIRECT` | Policy | Direct Claims | Cession |
| `ASSUMED` | Contract | Assumed Claims | Retrocession |

The books are separated by a hard access wall. They share Party, Document, Payment, Notifications, and Lineage, but no operational policy, claim, cession, or retrocession data crosses between them.

The platform is a **policy, claims, and reinsurance administration system of record and transactional system**. It is not an ERP, general ledger, HR, legal, procurement, or vendor-management system.

## Why open source

Insurance administration is dominated by closed, expensive, and hard-to-integrate systems. This project exists to make the core data model, transaction model, controls, and integration contracts transparent and reusable.

The goals are:

- a canonical, standards-aligned insurance data model;
- a clear separation of policy, claims, and reinsurance domains;
- an auditable transaction and lineage model;
- integration contracts for SAP S/4HANA and SAP FS-RI without making either system the application;
- a testable, Playwright-first implementation standard;
- a governance model that allows adopters and contributors to trust the project.

## Architecture at a glance

```text
Shell
  -> Gateway -> Auth
  -> 10 vertical front-ends

10 verticals, each with front-end, domain, expert, database:
  Party, Policy, Contract, Direct Claims, Assumed Claims,
  Cession, Retrocession, Document, Payment, Notifications

Platform services:
  Gateway, Auth, Config, Lineage, Simulators, E2E

External systems:
  SAP S/4HANA (AR/AP/GL)
  SAP FS-RI (actual cessions, retrocessions, recoverables, statements)
```

The repository topology is one repository per individually deployable component. See [REPOSITORIES.md](REPOSITORIES.md).


## Current implementation

The local first vertical slice runs end to end: PostgreSQL, all ten experts and domains, gateway, auth, lineage, the federated vertical remotes, and the shell.

![EIA shell running the Policy vertical](repos/eia/docs/images/platform-shell.png)

Evidence: [docs/EVIDENCE.md](repos/eia/docs/EVIDENCE.md). Local run: [docs/LOCAL_RUN.md](repos/eia/docs/LOCAL_RUN.md).
## Repository map

| Group | Count | Examples |
|---|---:|---|
| Vertical applications | 30 | `eia-policy-web`, `eia-policy-domain`, `eia-policy-expert` |
| Platform runtime | 1 | `eia-platform` (gateway, auth, config, lineage, shared libs) |
| Front-end platform | 1 | `eia-frontend` (shell, runtime, UI kit, federation) |
| Contracts | 1 | `eia-contracts` |
| Quality | 1 | `eia-quality` (simulators, E2E) |
| Operations | 1 | `eia-ops` (infra, environments, observability, release, security) |
| Organization profile | 1 | `.github` |
| Umbrella repository | 1 | `eia` |
| **Total** | **37** | |

## Status

This is a **working local first vertical slice**, not a production system.

- [x] Architecture, domain models, and data dictionaries
- [x] Transaction model, lineage, security, and access boundaries
- [x] Reinsurance calculations, credit, collateral, and FS-RI boundary
- [x] Master data, ACORD/NAIC/ISO/SAP alignment
- [x] Repository topology and baseline local verification
- [x] Working vertical applications (first slice)
- [ ] FS-RI and S/4HANA integrations
- [ ] Production test evidence

See [ROADMAP.md](ROADMAP.md) for the implementation sequence.

## Getting started

1. Read [SPEC.md](SPEC.md).
2. Choose a vertical or platform repository from [REPOSITORIES.md](REPOSITORIES.md).
3. Read that repository's `README.md` and `IMPLEMENTATION.md`.
4. Open an issue or discussion before starting significant work.
5. Follow [CONTRIBUTING.md](CONTRIBUTING.md).

Run the local stack with [docs/LOCAL_RUN.md](repos/eia/docs/LOCAL_RUN.md).

## Contributing

Contributions are welcome under the Apache License 2.0 and the Developer Certificate of Origin. There is no CLA.

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [GOVERNANCE.md](GOVERNANCE.md)
- [SECURITY.md](SECURITY.md)
- [DCO](DCO)

## Security

Report vulnerabilities privately through GitHub Security Advisories or `support@rmburgess.com`. Do not open a public issue for a suspected vulnerability.

## Trademarks and affiliation

EIA Open Insurance is an independent open-source project. It is not affiliated with or endorsed by SAP, ACORD, NAIC, ISO, Verisk, or any carrier, broker, or regulator. SAP, ACORD, NAIC, ISO, and other names are trademarks of their respective owners.

See [TRADEMARK.md](TRADEMARK.md).

## Disclaimer

Insurance is a regulated activity. This software and specification are provided **as is**, without warranty. Adopters are responsible for regulatory compliance, legal review, security, data protection, and fitness for their jurisdiction and business.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).




