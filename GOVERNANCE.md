# Governance

## Bootstrap phase

EIA Open Insurance is in its bootstrap phase. The founding maintainer is `@rmburgess-dev`. The bootstrap phase ends when at least three maintainers from two or more organizations are active.

## Roles

| Role | Responsibility |
|---|---|
| Maintainer | Reviews and merges changes; owns a repository or domain |
| Technical Steering Committee member | Sets technical primaryion, resolves disputes, approves RFCs |
| Contributor | Submits issues, code, documentation, tests, or designs |
| Adopter | Uses the software and reports defects or requirements |

## Decision making

The project uses lazy consensus:

1. A proposal is opened as an issue or RFC.
2. Maintainers and contributors discuss for at least five business days.
3. If no sustained objection remains, the proposal is accepted.
4. A sustained objection is resolved by the Technical Steering Committee.

## RFCs

A change to architecture, data model, security model, licensing, or a `MUST` requires an RFC in `eia-architecture`. An RFC includes context, options, decision, consequences, and migration impact.

## Maintainers

Maintainers are listed in `MAINTAINERS.md` and in repository `CODEOWNERS`. A new maintainer is nominated by an existing maintainer and approved by lazy consensus. Maintainers who are inactive for six months move to emeritus status.

## Releases

Releases follow Semantic Versioning. A release requires:

- passing local verification and review;
- updated changelog;
- security review for security-sensitive changes;
- signed artifacts;
- release notes.

## Security

Security reports are handled under `SECURITY.md`. Security fixes may bypass the normal discussion period, but require a post-release review.

## Trademarks

The project name and logo are governed by `TRADEMARK.md`. The Apache License 2.0 does not grant trademark rights.

## Amendments

This governance document is amended by an RFC approved by the Technical Steering Committee.
