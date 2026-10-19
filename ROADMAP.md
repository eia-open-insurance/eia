# Roadmap

The roadmap is a sequence, not a date commitment.

## Phase 0 - Specification and scaffolding

- [x] Architecture, domain models, data dictionaries
- [x] Transaction, lineage, security, and book wall
- [x] Assumed Claims calculations, credit, collateral, Schedule F
- [x] Master data and ACORD/NAIC/ISO/SAP alignment
- [x] Repository topology and baseline local verification

## Phase 1 - Walking skeleton

- Party and Document vertical slices
- Shell, gateway, auth, config, lineage
- Transaction engine and outbox
- Playwright harness and simulators
- PostgreSQL migrations and seed data

## Phase 2 - Direct book

- Policy
- Direct claims
- Payment
- Billing and SAP S/4HANA simulator integration

## Phase 3 - Assumed book

- Contract
- Assumed claims
- Cession and Retrocession
- FS-RI simulator integration

## Phase 4 - Shared services

- Notifications
- Lineage at scale
- Reporting and regulatory extracts
- Actuarial workbench

## Phase 5 - Production hardening

- SAP S/4HANA and FS-RI production interfaces
- Performance, security, and DR evidence
- Operational runbooks and staffing model
- Pilot and hypercare

## How to contribute

Pick an issue labelled `good first issue` or `help wanted`, or open a design discussion. See [CONTRIBUTING.md](CONTRIBUTING.md).
