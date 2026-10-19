# Vertical implementation baseline

This is the working pattern for the first implementation slice of each business vertical. The Party vertical is the reference implementation.

## Toolchain

- JDK 22: `C:\Program Files\Eclipse Adoptium\jdk-22.0.2.9-hotspot`
- Gradle 8.14.3: `C:\Users\MediaCenter\Desktop\enterprise-insurance-administration\.tools\gradle-8.14.3\bin\gradle.bat`
- Node 24 / npm 11: `C:\Program Files\nodejs`
- PostgreSQL 17: `C:\Program Files\PostgreSQL\17\bin\psql.exe`, user `postgres`, password `postgres`
- Playwright Chromium is installed under the user profile.

Set the environment before building:

```powershell
$env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-22.0.2.9-hotspot'
$env:Path="$env:JAVA_HOME\bin;C:\Program Files\nodejs;C:\Users\MediaCenter\Desktop\enterprise-insurance-administration\.tools\gradle-8.14.3\bin;$env:Path"
```

## Repository rules

- Each vertical owns exactly three repositories: `eia-<vertical>-web`, `eia-<vertical>-domain`, `eia-<vertical>-expert`.
- Do not edit `SPEC.md`, `REPOSITORIES.md`, `repositories.json`, the umbrella `eia` repository, or another vertical's repositories.
- Do not add CI workflows or hosted pipelines.
- Use Gradle Kotlin DSL for every Java repository. Do not add `pom.xml`.
- Commit the Gradle wrapper (`gradlew`, `gradlew.bat`, `gradle/wrapper/`).

## Expert service

- Spring Boot 3.4.0, Java 22.
- Package: `com.eia.<vertical>.expert`.
- Spring Web, JDBC, Validation, Actuator, PostgreSQL, Test.
- PostgreSQL database: `eia_<vertical>`.
- Own schema and `schema.sql` bootstrap for the first slice.
- Expose internal endpoints under `/internal/v1/<aggregate>`.
- Use `JdbcTemplate`, explicit SQL, UUID primary keys, optimistic `version`, `created_at`, `updated_at`.
- Port assignment table below.

## Domain service

- Spring Boot 3.4.0, Java 22.
- Package: `com.eia.<vertical>.domain`.
- Spring Web, Validation, Actuator, Test.
- Expose `/api/v1/<aggregate>`.
- Require `X-EIA-Tenant` header.
- Call the expert through a `RestClient` component.
- Own business validation and state transitions; the expert writes data.
- Port assignment table below.

## Web remote

- React 19 and React DOM only at runtime.
- Webpack 5 Module Federation container.
- Expose `./App`.
- Async bootstrap: `index.jsx` imports `./bootstrap`, and `bootstrap.jsx` mounts React. This is required for shared React.
- Pin `@swc/core` to `1.10.7`; later SWC releases fail on this machine's ACL cache validation.
- Dev server proxies `/api` to the domain service.
- Include one Playwright test that mocks the API and verifies the workbench renders.
- No CI.

## Ports

| Vertical | Expert | Domain | Web |
|---|---:|---:|---:|
| Party | 8081 | 8082 | 3001 |
| Policy | 8083 | 8084 | 3002 |
| Contract | 8085 | 8086 | 3003 |
| Direct Claims | 8087 | 8088 | 3004 |
| Assumed Claims | 8089 | 8090 | 3005 |
| Cession | 8091 | 8092 | 3006 |
| Retrocession | 8093 | 8094 | 3007 |
| Document | 8095 | 8096 | 3008 |
| Payment | 8097 | 8098 | 3009 |
| Notifications | 8099 | 8100 | 3010 |

## Minimum slice

The first slice for each vertical must:

1. Define the primary aggregate with the core identifiers and status fields from the SPEC.
2. Support create, list, and get through domain and expert.
3. Enforce one or two real invariants from the SPEC.
4. Have a JUnit controller test for the domain and expert.
5. Have a Playwright test for the web remote.
6. Build successfully with Gradle and npm.

Feature depth beyond this slice is tracked in the umbrella roadmap and added incrementally.
