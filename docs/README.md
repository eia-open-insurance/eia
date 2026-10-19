# eia/docs

- GitHub organization: `eia-open-insurance`
- Repository URL: https://github.com/eia-open-insurance/eia/tree/main/docs
- Type: Documentation
- Deployable: No
- Owner: Platform
- Runtime: Markdown and static docs
- Data store: Not applicable
- Depends on: eia/architecture

## Purpose

User, administrator, operations, and integration documentation.

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

Publishes the documentation site.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
