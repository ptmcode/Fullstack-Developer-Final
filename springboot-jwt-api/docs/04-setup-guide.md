# 4. Setup & Run Guide

Step-by-step instructions for setting up the database and running the School Management
System on a fresh machine. No prior knowledge of this project is assumed.

## Prerequisites

| Tool | Version | Check with |
|------|---------|-----------|
| Docker Desktop | any recent | `docker --version` |
| JDK | **21** (e.g. Eclipse Temurin) | `java -version` |
| Git | any | `git --version` |

> ⚠️ Gradle in this project runs on **JDK 21**. A newer JDK (22+) fails with
> `Unsupported class file major version`. Install Temurin 21 from
> https://adoptium.net if needed — see [Troubleshooting](#troubleshooting).

---

## Step 1 — Install PostgreSQL with Docker

The project ships a ready-made compose file in [postgres/docker-compose.yml](../postgres/docker-compose.yml):

```bash
cd postgres
docker compose up -d
```

This starts a container named `school-postgres` with:

| Setting | Value |
|---------|-------|
| Host / port | `localhost:5432` |
| Superuser | `postgres` |
| Password | `12345678` |
| Database | `school_management_db` (created automatically on first start) |
| Data volume | `school_pgdata` (data survives container restarts) |

Equivalent single command, if you prefer `docker run`:

```bash
docker run --name school-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=12345678 \
  -e POSTGRES_DB=school_management_db \
  -p 5432:5432 \
  -v school_pgdata:/var/lib/postgresql/data \
  -d postgres:17
```

**Verify it is running:**

```bash
docker ps                              # STATUS should say "Up ..."
docker exec -it school-postgres psql -U postgres -c "\l"
```

You should see `school_management_db` in the database list. If it is missing
(e.g. you reused an existing container), create it manually:

```bash
docker exec -it school-postgres psql -U postgres -c "CREATE DATABASE school_management_db;"
```

> **Already have PostgreSQL running locally?** You can skip Docker — just create the
> database and use your own credentials in Step 2.

---

## Step 2 — Point the project at your database

The connection settings live in
[src/main/resources/application.yml](../src/main/resources/application.yml):

```yaml
spring:
  datasource:
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://localhost:5432/school_management_db
    username: postgres
    password: 12345678
```

If your PostgreSQL uses a different port, user, or password, edit these three lines —
nothing else in the project needs to change.

Alternatively, override them **without editing any file** using environment variables
(useful for demos and CI):

```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/school_management_db
export SPRING_DATASOURCE_USERNAME=postgres
export SPRING_DATASOURCE_PASSWORD=12345678
```

---

## Step 3 — Initial data (automatic, nothing to run by hand)

There are **no manual SQL scripts to execute**. The project uses
**Flyway migrations** — on the first start the application connects to the empty
database and applies, in order:

| Migration | Creates |
|-----------|---------|
| `V1__create_auth_tables.sql` | users, roles, permissions, refresh/reset tokens, audit log |
| `V2__create_master_data_tables.sql` | students, teachers, subjects, classes |
| `V3__create_business_tables.sql` | enrollments, grades (with unique + check constraints) |
| `V4__seed_data.sql` | roles ↔ permissions mapping, demo accounts, sample school data |

The seed data gives you a working system out of the box:

**Demo accounts**

| Username | Password | Role |
|----------|----------|------|
| `admin` | `admin@123` | ROLE_ADMIN — everything |
| `teacher1` | `teacher@123` | ROLE_TEACHER — read master data, manage enrollments & grades |
| `student1` | `student@123` | ROLE_STUDENT — read-only |

**Sample data:** 10 students, 4 teachers, 6 subjects, 3 classes, 10 enrollments and
10 grades — so the dashboard and lists are populated on first login.

Flyway records what it has applied in the `flyway_schema_history` table, so
restarting the app never re-runs or duplicates the seed.

**Reset to a clean database** (any time you want to start over):

```bash
docker exec -it school-postgres psql -U postgres -c "DROP DATABASE school_management_db;"
docker exec -it school-postgres psql -U postgres -c "CREATE DATABASE school_management_db;"
```

Then restart the application — Flyway rebuilds and reseeds everything.

---

## Step 4 — Run the project

From the project root:

```bash
./gradlew bootRun          # macOS / Linux
gradlew.bat bootRun        # Windows
```

First run downloads dependencies (needs internet, takes a few minutes); afterwards the
app starts in a few seconds. Success looks like:

```
Successfully applied 4 migrations to schema "public", now at version v4
Tomcat started on port 30033 (http)
Started SchoolManagementApplication in 2.7 seconds
```

**Other ways to run:**

- **From an IDE** — open the Gradle project in IntelliJ IDEA or VS Code
  (Extension Pack for Java) and run `SchoolManagementApplication`.
- **As a jar** —
  ```bash
  ./gradlew bootJar
  java -jar build/libs/school-management-system-0.0.1-SNAPSHOT.jar
  ```
- **Fully in Docker** — `docker compose up --build` in the project root builds the
  app image and connects it to the host's PostgreSQL via `host.docker.internal`.
- **If your default JDK is not 21** — point Gradle at a JDK 21 installation:
  ```bash
  ./gradlew bootRun -Dorg.gradle.java.home=/path/to/jdk-21
  ```

---

## Step 5 — Open and verify

| What | URL |
|------|-----|
| Admin web UI | http://localhost:30033/ |
| Swagger UI (all APIs, try them live) | http://localhost:30033/swagger-ui.html |
| OpenAPI spec (JSON) | http://localhost:30033/v3/api-docs |

Quick smoke test from a terminal:

```bash
curl -s http://localhost:30033/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin@123"}'
```

A JSON response containing `"accessToken"` means everything works. You can also import
[SchoolManagementSystem.postman_collection.json](../SchoolManagementSystem.postman_collection.json)
into Postman — run **Auth / Login** first; it stores the token for all other requests.

> **Forgot-password demo:** the reset token is not emailed — it is printed in the
> application console log by `MailService`, e.g.
> `[MAIL] To: student1@school.edu.kh — Your password reset token is: <uuid>`.

---

## Troubleshooting

| Symptom | Cause & fix |
|---------|-------------|
| `Unsupported class file major version ...` when running Gradle | Your default JDK is newer than 21. Install Temurin 21 and set `JAVA_HOME`, or pass `-Dorg.gradle.java.home=/path/to/jdk-21`. |
| `Connection to localhost:5432 refused` | PostgreSQL is not running — `docker compose up -d` in `postgres/`, then `docker ps` to confirm. |
| `password authentication failed for user "postgres"` | Credentials in `application.yml` don't match the container's `POSTGRES_PASSWORD`. Align them (Step 2). |
| `database "school_management_db" does not exist` | Create it: `docker exec -it school-postgres psql -U postgres -c "CREATE DATABASE school_management_db;"` |
| `Port 5432 is already in use` when starting the container | Another PostgreSQL is running locally. Either use it directly (Step 2), stop it, or map another port (`-p 5433:5432`) and update the JDBC url. |
| `Port 30033 was already in use` when starting the app | Another instance is running. Stop it (`lsof -i :30033` → kill) or change `server.port` in `application.yml`. |
| Flyway `Migration checksum mismatch` | An applied migration file was edited. Never edit applied migrations — restore the file, or reset the database (Step 3) on a dev machine. |
