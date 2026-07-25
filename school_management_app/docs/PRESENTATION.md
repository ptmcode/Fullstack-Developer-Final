# Presentation guide

Suggested storyline for the final-assignment defense (10–15 minutes).

## 1. The system in one slide
- Fullstack: **Spring Boot + PostgreSQL + JWT** backend ⇄ **Flutter** client.
- One API collection (Postman), **every endpoint has a screen** — see
  `docs/API-MAPPING.md`.
- Three demo roles: admin (full), teacher1 (enrollments + grades),
  student1 (read-only) — same UI, permission-gated.

## 2. Required techniques and where to point at code
| Requirement | Where to show it |
|---|---|
| GetX pattern | `modules/*` (controller + view per feature), `bindings/app_bindings.dart`, `routes/app_pages.dart` |
| http | `core/network/api_client.dart` — one client, ~180 lines |
| flutter_secure_storage | `core/services/token_storage_service.dart` (tokens only) |
| get_storage | `core/services/preferences_service.dart` (theme, username, profile cache) |
| JWT authentication | login flow + **auto-refresh on 401** in `ApiClient._refreshAccessToken` (single-flight) |
| Clean Code architecture | `docs/ARCHITECTURE.md` diagram: core / data / modules layers |

## 3. Live demo script
1. **Login** as `admin` — point out remembered username + demo accounts card.
2. **Dashboard** — live counters, recent enrollments, recent audit activity.
3. **Students** — search debounce, pagination; create a student (validation!),
   edit it, open detail.
4. **Student detail** — enroll into a class, record a grade (letter badge),
   grades list.
5. **Classes** — tap a class → roster dialog → enroll/remove from there too.
6. **Roles** — open permission matrix, tick/untick, save (`PUT /roles/{id}/permissions`).
7. **Audit Logs** — filter by action = CREATE; show the trail of the demo so far.
8. **Theme toggle** — dark mode, persisted via GetStorage (restart still dark).
9. **Sign out → login as `student1`** — menu shrinks to 5 read-only sections,
   no create/edit buttons anywhere. Backend still enforces 403 — UI gating is
   convenience, not security.
10. (Optional) **Token demo** — wait for access-token expiry (~15 min) or kill
    the backend to show the friendly network error + retry.

## 4. Engineering talking points (likely Q&A)
- **Why one ApiClient?** Single choke point for auth, refresh, errors —
  controllers never see JSON or status codes.
- **Refresh race:** concurrent 401s share one refresh future
  (`_refreshInFlight`), retried exactly once; failure ends the session cleanly.
- **Why PagedListController\<T\>?** Eight list screens, one tested
  implementation of search/pagination/error/reload semantics.
- **Secure vs. convenience storage:** tokens in Keychain/Keystore,
  preferences in GetStorage — different sensitivity, different stores.
- **Testing:** 25 tests — model parsing (incl. backend quirk: `entityId`
  arrives as a string), full ApiClient refresh flow with a mock HTTP client,
  and widget tests; `flutter analyze` is clean.
- **Real bugs found by testing against the live API** (good war stories):
  1. splash controller was lazy-loaded but never referenced → eager `Get.put`;
  2. `Get.back()` after a snackbar closed the snackbar, not the dialog →
     `Navigator.pop` with `mounted` guards;
  3. audit `entityId` string/number mismatch → lenient parsing + regression test.
