# API ↔ Screen coverage matrix

Every request of `SchoolManagementSystem.postman_collection.json` and where
the Flutter app calls it. Base URL: `http://localhost:30033/api/v1`.

## Auth
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/auth/login` | POST | Login screen |
| `/auth/refresh` | POST | `ApiClient` — automatic on any 401 |
| `/auth/logout` | POST | Account menu → Sign out |
| `/auth/forgot-password` | POST | Forgot-password screen |
| `/auth/reset-password` | POST | Reset-password screen |

## Users
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/users?search&page…` | GET | Users list (search + pagination) |
| `/users/{id}` | GET | Users → edit dialog prefill *(list payload)* |
| `/users` | POST | Users → New user |
| `/users/{id}` | PUT | Users → Edit |
| `/users/{id}` | DELETE | Users → Delete (soft) |
| `/users/{id}/roles` | PUT | Users → Assign roles |
| `/users/me` | GET | Splash (session restore) + My Profile |
| `/users/me/password` | PUT | My Profile → Change password |

## Roles & permissions
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/roles` | GET | Roles screen + role pickers in Users |
| `/permissions` | GET | Roles → Edit permissions dialog |
| `/roles/{id}/permissions` | PUT | Roles → Edit permissions → Save |

## Dashboard
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/dashboard/summary` | GET | Dashboard (counters, recent enrollments, activity) |

## Students
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/students?search&page…` | GET | Students list |
| `/students/{id}` | GET | Student detail (profile refresh) |
| `/students` | POST | Students → New student |
| `/students/{id}` | PUT | Students → Edit |
| `/students/{id}` | DELETE | Students → Delete (soft) |
| `/students/{id}/enrollments` | GET | Student detail → Enrollments card |
| `/students/{id}/grades` | GET | Student detail → Grades card |

## Teachers
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/teachers?search&page…` | GET | Teachers list (also class-form dropdown) |
| `/teachers/{id}` | GET | *(covered by list payload)* |
| `/teachers` | POST | Teachers → New teacher |
| `/teachers/{id}` | PUT | Teachers → Edit |
| `/teachers/{id}` | DELETE | Teachers → Delete (soft) |

## Subjects
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/subjects?search&page…` | GET | Subjects list (also grade-form dropdown) |
| `/subjects/{id}` | GET | *(covered by list payload)* |
| `/subjects` | POST | Subjects → New subject |
| `/subjects/{id}` | PUT | Subjects → Edit |
| `/subjects/{id}` | DELETE | Subjects → Delete (soft) |

## Classes
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/classes?search&page…` | GET | Classes list (also filters/dropdowns) |
| `/classes/{id}` | GET | *(covered by list payload)* |
| `/classes` | POST | Classes → New class |
| `/classes/{id}` | PUT | Classes → Edit |
| `/classes/{id}` | DELETE | Classes → Delete (soft) |
| `/classes/{id}/enrollments` | GET | Classes → tap row → Roster dialog |

## Enrollments
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/enrollments?page&studentId&classId` | GET | Enrollments list + filters |
| `/enrollments` | POST | Enroll dialogs (Enrollments, Student detail, Class roster) |
| `/enrollments/{id}` | DELETE | Remove enrollment (all three places) |
| `/enrollments/{id}/grades` | GET | Enrollments → row → Grades dialog |

## Grades
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/grades` | POST | Student detail → Record grade |
| `/grades/{id}` | PUT | Student detail → Edit grade |
| `/grades/{id}` | DELETE | Student detail → Delete grade |

## Audit
| Endpoint | Method | Screen / trigger |
|---|---|---|
| `/audit-logs?username&action&entityType&from&to&page…` | GET | Audit Logs screen (all filters) |
