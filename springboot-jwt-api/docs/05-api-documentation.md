# 5. API Documentation

Complete REST API reference for the School Management System — **56 endpoints**, generated
from the live OpenAPI specification (springdoc). Machine-readable versions:
[openapi.json](api/openapi.json) · [openapi.yaml](api/openapi.yaml).

## Interactive documentation (Swagger UI)

With the application running:

| What | URL |
|------|-----|
| **Swagger UI** — browse and *try* every endpoint | http://localhost:30033/swagger-ui.html |
| OpenAPI 3 spec (JSON) | http://localhost:30033/v3/api-docs |
| OpenAPI 3 spec (YAML) | http://localhost:30033/v3/api-docs.yaml |

**Using Swagger UI with authentication:**
1. Expand **Authentication -> POST /api/v1/auth/login**, click *Try it out*, log in
   (e.g. `admin` / `admin@123`) and copy the `accessToken` from the response.
2. Click the **Authorize** button (top right), paste the token, *Authorize*.
3. Every request now carries `Authorization: Bearer <token>` automatically.

## Conventions

- **Base path:** `/api/v1` — all paths below are absolute.
- **Success envelope:** `{"code": "OK", "message": "Success", "data": ...}`
- **Error shape:** `{"code": "E4xx/E500", "message": "...", "errors": [{"field", "message"}]}`
  — `E400` validation, `E401` authentication, `E403` permission, `E404` not found, `E409` conflict.
- **Pagination:** list endpoints accept `?search=&page=0&size=10&sort=id,desc` and return
  `{content, page, size, totalElements, totalPages}`.
- **Auth column:** `Public` = no token needed · `Authenticated` = any valid token ·
  a permission code = token whose user holds that permission (ADMIN has all; see
  [Database Design](03-database-design.md) for the role -> permission matrix).


## Authentication

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/api/v1/auth/forgot-password` | Forgot password — Sends a single-use reset token to the registered email | Public |
| `POST` | `/api/v1/auth/login` | Login — Authenticate with username (or email) and password; returns access + refresh tokens | Public |
| `POST` | `/api/v1/auth/logout` | Logout — Revokes all refresh tokens of the current user | Authenticated |
| `POST` | `/api/v1/auth/refresh` | Refresh access token — Exchange a valid refresh token for a new access token | Public |
| `POST` | `/api/v1/auth/reset-password` | Reset password — Sets a new password using a valid reset token | Public |

## User Management

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/users` | List users — Paginated, searchable by username/email/name | `user.read` |
| `POST` | `/api/v1/users` | Create user | `user.create` |
| `GET` | `/api/v1/users/me` | Current user profile | Authenticated |
| `PUT` | `/api/v1/users/me/password` | Change own password | Authenticated |
| `DELETE` | `/api/v1/users/{id}` | Deactivate user (soft delete) | `user.delete` |
| `GET` | `/api/v1/users/{id}` | Get user by id | `user.read` |
| `PUT` | `/api/v1/users/{id}` | Update user | `user.update` |
| `PUT` | `/api/v1/users/{id}/roles` | Assign roles to user | `user.update` |

## Roles & Permissions

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/permissions` | List all permission codes | `role.read` |
| `GET` | `/api/v1/roles` | List roles with their permissions | `role.read` |
| `PUT` | `/api/v1/roles/{id}/permissions` | Replace the permissions of a role | `role.update` |

## Dashboard

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/dashboard/summary` | Dashboard summary — Active counts plus recent enrollments and audit entries | `dashboard.read` |

## Students

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/students` | List students — Paginated, searchable by code and name | `student.read` |
| `POST` | `/api/v1/students` | Create student | `student.create` |
| `DELETE` | `/api/v1/students/{id}` | Delete student (soft delete) | `student.delete` |
| `GET` | `/api/v1/students/{id}` | Get student by id | `student.read` |
| `PUT` | `/api/v1/students/{id}` | Update student | `student.update` |

## Teachers

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/teachers` | List teachers — Paginated, searchable by code, name and specialization | `teacher.read` |
| `POST` | `/api/v1/teachers` | Create teacher | `teacher.create` |
| `DELETE` | `/api/v1/teachers/{id}` | Delete teacher (soft delete) | `teacher.delete` |
| `GET` | `/api/v1/teachers/{id}` | Get teacher by id | `teacher.read` |
| `PUT` | `/api/v1/teachers/{id}` | Update teacher | `teacher.update` |

## Subjects

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/subjects` | List subjects — Paginated, searchable by code and name | `subject.read` |
| `POST` | `/api/v1/subjects` | Create subject | `subject.create` |
| `DELETE` | `/api/v1/subjects/{id}` | Delete subject (soft delete) | `subject.delete` |
| `GET` | `/api/v1/subjects/{id}` | Get subject by id | `subject.read` |
| `PUT` | `/api/v1/subjects/{id}` | Update subject | `subject.update` |

## Classes

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/classes` | List classes — Paginated, searchable by code, name and academic year | `class.read` |
| `POST` | `/api/v1/classes` | Create class | `class.create` |
| `DELETE` | `/api/v1/classes/{id}` | Delete class (soft delete) | `class.delete` |
| `GET` | `/api/v1/classes/{id}` | Get class by id | `class.read` |
| `PUT` | `/api/v1/classes/{id}` | Update class | `class.update` |

## Enrollments

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/classes/{classId}/enrollments` | List enrollments of a class | `enrollment.read` |
| `GET` | `/api/v1/enrollments` | List enrollments — Paginated; optional studentId / classId filters | `enrollment.read` |
| `POST` | `/api/v1/enrollments` | Enroll a student into a class | `enrollment.create` |
| `DELETE` | `/api/v1/enrollments/{id}` | Remove an enrollment (soft delete) | `enrollment.delete` |
| `GET` | `/api/v1/enrollments/{id}/grades` | List grades of an enrollment | `grade.read` |
| `GET` | `/api/v1/students/{studentId}/enrollments` | List enrollments of a student | `enrollment.read` |
| `GET` | `/api/v1/students/{studentId}/grades` | List all grades of a student | `grade.read` |

## Grades

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `POST` | `/api/v1/grades` | Record a grade — Score 0-100, one grade per enrollment + subject + term | `grade.create` |
| `DELETE` | `/api/v1/grades/{id}` | Delete a grade (soft delete) | `grade.delete` |
| `PUT` | `/api/v1/grades/{id}` | Update a grade score | `grade.update` |

## Devices

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `DELETE` | `/api/v1/devices` | Unregister a device — Stops push delivery to the given token | Authenticated |
| `GET` | `/api/v1/devices` | List my registered devices | Authenticated |
| `POST` | `/api/v1/devices` | Register this device for push — Stores the FCM registration token of the signed-in user's device. Call after login and whenever Firebase rotates the token. | Authenticated |

## Notifications

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/notifications` | My notifications — Paginated inbox; pass unreadOnly=true to filter | `notification.read` |
| `PUT` | `/api/v1/notifications/read-all` | Mark all my notifications as read | `notification.read` |
| `POST` | `/api/v1/notifications/send` | Send a push notification — Broadcast to every active user of a role (e.g. ROLE_STUDENT) or to an explicit list of userIds | `notification.send` |
| `GET` | `/api/v1/notifications/unread-count` | Unread notification count — For the app's badge counter | `notification.read` |
| `PUT` | `/api/v1/notifications/{id}/read` | Mark one notification as read | `notification.read` |

## Audit Log

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| `GET` | `/api/v1/audit-logs` | Search audit logs — Filter by username, action, entity type and date range | `audit.read` |

---

*Regenerating after API changes:* restart the app, then re-export
`curl -s http://localhost:30033/v3/api-docs | python3 -m json.tool > docs/api/openapi.json`
(and `.yaml` likewise). Swagger UI itself is always in sync with the code.
