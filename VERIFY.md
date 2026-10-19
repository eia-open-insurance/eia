# Local verification

No hosted CI is used. Run the repository baseline check locally:

```powershell
pwsh ./verify.ps1
```

To also run Maven and Node builds where build files exist:

```powershell
pwsh ./verify.ps1 -Build
```

The script checks each repository for README, CODEOWNERS, SECURITY, CONTRIBUTING, CHANGELOG, LICENSE, and NOTICE. With `-Build`, it runs `mvn verify` for Maven projects and `npm build`/`npm test` for Node projects.

Attach the output to the release evidence. There is no required status check at GitHub.
