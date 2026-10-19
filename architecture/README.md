# eia/architecture

- GitHub organization: `eia-open-insurance`
- Repository URL: https://github.com/eia-open-insurance/eia/tree/main/architecture
- Type: Architecture
- Deployable: No
- Owner: Architecture
- Runtime: Markdown and Mermaid
- Data store: Not applicable
- Depends on: None

## Purpose

Architecture decision records, diagrams, specification snapshots, and standards.

## Responsibilities

- Keep this repository focused on one deployable component or one platform concern.
- Follow the repository standard in `../CONVENTIONS.md` and the specification in `../../SPEC.md`.
- Publish and consume contracts through `eia-contracts`.
- Maintain README, CODEOWNERS, SECURITY, CHANGELOG, tests, and local verification.
- Contain no business logic in shared libraries or front-end remotes.

## Verification

- Lint and format
- Unit tests with 100% business-logic coverage where applicable
- Contract tests
- Integration or Playwright tests where applicable
- Security scan and SBOM
- Build and publish

## Notes

Source of truth for ADRs and architecture diagrams.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
