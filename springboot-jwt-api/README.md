# School Management System

Master's degree final project (BBU — Fullstack Developer). A Spring Boot REST API with a
lightweight web admin UI for managing a school's users, master data (students, teachers,
subjects, classes) and business records (enrollments, grades), with JWT security,
role/permission-based authorization, validation, an audit trail, and Swagger documentation.

Built with **Agile Scrum in two sprints** — see [docs/](docs/README.md) for the Sprint 1
deliverables (requirement analysis, system design, database design).

## Technology

| Layer | Technology |
|-------|------------|
| Backend | Java 21, Spring Boot 3.5 (Web, Data JPA, Security, Validation, AOP) |
| Database | PostgreSQL, schema managed by **Flyway** (V1–V4) |
| Security | JWT access tokens (~15 min) + refresh tokens, BCrypt, role→permission RBAC |
| API docs | springdoc-openapi / Swagger UI |
| UI | Static Bootstrap 5 pages served by Spring Boot (`src/main/resources/static`) |
| Build | Gradle |

## Getting started

> **New machine?** Follow the full walkthrough in
> [docs/04-setup-guide.md](docs/04-setup-guide.md) — PostgreSQL via Docker,
> credentials, initial data, running, and troubleshooting.

1. **PostgreSQL** — start the bundled container (creates `school_management_db` automatically):

   ```bash
   cd postgres && docker compose up -d
   ```

   Credentials live in `src/main/resources/application.yml` — adjust them there if
   you use your own PostgreSQL.

2. **Run** (requires JDK 21 for Gradle):

   ```bash
   ./gradlew bootRun
   ```

   Flyway creates all tables and seeds demo data on first start — no manual SQL.

3. **Open**

   | What | URL |
   |------|-----|
   | Admin web UI | http://localhost:30033/ |
   | Swagger UI | http://localhost:30033/swagger-ui.html |
   | OpenAPI JSON | http://localhost:30033/v3/api-docs |

## Demo accounts

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin@123` | ROLE_ADMIN — full access |
| `teacher1` | `teacher@123` | ROLE_TEACHER — read master data, manage enrollments & grades |
| `student1` | `student@123` | ROLE_STUDENT — read-only |

Forgot-password demo: the reset token is written to the application log
(`MailService`) instead of being emailed.

## Project structure

```
com.school.management
├── config/          Security + OpenAPI configuration
├── security/        JWT filter, token provider, user details
├── common/          ApiResponse, PageResponse, exceptions, audit AOP, BaseEntity
├── auth/            Login, logout, refresh, forgot/reset password
├── user/            Users, roles, permissions
├── masterdata/      Students, teachers, subjects, classes (CRUD + search + paging)
├── enrollment/      Enrollments + grades (business module)
├── dashboard/       Summary statistics
└── auditlog/        Immutable audit trail + search API
```

- API base path: `/api/v1`; responses use the envelope `{code, message, data}`.
- Deletes are soft (`status` = `ACT`/`DEL`); uniqueness and referential integrity are
  enforced in the database (see `src/main/resources/db/migration`).
- Every write is audited via the `@Auditable` AOP aspect (who, what, when, from where).

## API testing

Import `SchoolManagementSystem.postman_collection.json` into Postman and run
**Auth / Login** first — it stores the JWT for all other requests.
