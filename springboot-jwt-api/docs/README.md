# School Management System (SMS)

Master's degree final project — a basic but cleanly designed CRUD system built with
Spring Boot, PostgreSQL, Flyway, and JWT security.

This repository is being revised from the previous `springboot-jwt-api` teaching project
into the **School Management System**. The proven infrastructure (JWT security, Flyway,
Swagger, layered architecture) is kept; the old demo domains (posts, products, hotel)
will be removed once the new modules are complete.

## Documents

| # | Document | Sprint | Content |
|---|----------|--------|---------|
| 1 | [Requirement Analysis](01-requirement-analysis.md) | Sprint 1 | Actors, functional & non-functional requirements, user stories |
| 2 | [System Design](02-system-design.md) | Sprint 1 | Architecture, security design, API conventions, endpoint catalog |
| 3 | [Database Design](03-database-design.md) | Sprint 1 | ERD, data dictionary, Flyway migration plan, seed data |
| 4 | [Setup & Run Guide](04-setup-guide.md) | Sprint 2 | PostgreSQL via Docker, credentials, initial data, running the app |
| 5 | [API Documentation](05-api-documentation.md) | Sprint 2 | All 56 endpoints with permissions; exported OpenAPI spec in [api/](api/) |
| 6 | [Push Notifications](06-push-notifications.md) | Sprint 2 | Firebase Cloud Messaging: service account setup, Flutter integration, data model |

## Project Scope

A school back-office system where an **Admin** manages users, master data
(students, teachers, subjects, classes) and an Admin/Teacher records the business
transactions (enrollments and grades). The goal is a clear, correct, well-structured
system — not a feature-complete commercial product.

**In scope**

- Authentication: login, logout, refresh token, forgot password
- User management: CRUD, roles, permissions
- Dashboard: summary statistics
- Master data: Students, Teachers, Subjects, Classes (CRUD + search + pagination)
- Business module: Enrollments and Grades
- Audit log of user actions
- Validation, secure authentication, Swagger/OpenAPI documentation

**Out of scope** (documented deliberately to keep the project focused)

- Timetabling/scheduling, fee/billing, attendance, messaging, reporting exports,
  mobile app, multi-tenancy.

## Methodology — Agile Scrum, two sprints

### Sprint 1 — Analysis & Design

| Backlog item | Deliverable |
|--------------|-------------|
| Requirement analysis | `docs/01-requirement-analysis.md` |
| System design | `docs/02-system-design.md` |
| Database design | `docs/03-database-design.md` |

### Sprint 2 — Implementation & Presentation

| Backlog item | Deliverable |
|--------------|-------------|
| Project re-setup | New base package, `school_management_db`, fresh Flyway migrations |
| Authentication | Login / logout / refresh / forgot-password APIs |
| User management | User CRUD, role & permission assignment |
| Master data modules | Student, Teacher, Subject, Class CRUD + search + pagination |
| Business module | Enrollment + Grade APIs |
| Dashboard & audit log | Statistics endpoint, audit trail |
| API integration & UI | Swagger docs, Postman collection, admin web UI |
| Cleanup | Remove old `com.dinsaren.springbootjwtapi` code and old migrations |
| Final presentation | Demo script + slides |

## Technology Stack (unchanged from the base project)

| Layer | Technology |
|-------|------------|
| Language / runtime | Java 21 |
| Framework | Spring Boot 3.5.x (Web, Data JPA, Security) |
| Database | PostgreSQL (`school_management_db`, same credentials as before) |
| Migrations | Flyway |
| Auth | JWT (jjwt 0.12.x), refresh tokens, BCrypt |
| API docs | springdoc-openapi (Swagger UI) |
| Build | Gradle |
