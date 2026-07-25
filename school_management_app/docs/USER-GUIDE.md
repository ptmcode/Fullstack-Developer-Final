# User Guide — School Management System

Step-by-step instructions for every role. The same app adapts to who signs
in: buttons and menu entries appear only when your role has the matching
permission, and the backend enforces the same rules.

## 0. Before you start

1. Start the backend (port 30033):
   `/opt/homebrew/opt/openjdk@21/bin/java -jar build/libs/school-management-system-0.0.1-SNAPSHOT.jar`
   (run inside `springboot-jwt-api/`; PostgreSQL must be running in Docker).
2. Run the Flutter app: `flutter run` (pick your emulator/simulator).
3. Demo accounts:

| Username | Password | Role |
|---|---|---|
| `admin` | `admin@123` | Administrator — everything |
| `teacher1` | `teacher@123` | Teacher — read master data, manage enrollments & grades |
| `student1` | `student@123` | Student — read-only |

## 1. Signing in

1. On the login screen enter a username (or email) and password, then tap
   **Sign in**. "Remember me" stores the username for next time.
2. Wrong password → red error toast. Success → Home dashboard.
3. **Forgot password?** → enter your email → the server generates a
   single-use reset token (in this demo it is printed in the backend log,
   not emailed) → tap "I already have a token" → paste the token + new
   password → sign in again.

## 2. Finding your way around

- **Phone**: bottom bar with up to five tabs — Home, Students, Classes,
  Enrollments, Profile (tabs your role can't use are hidden). Sections not
  in the bar (Teachers, Subjects, Users, Roles, Audit Logs) open from the
  **quick-link chips on Home**.
- **Tablet / desktop / web**: left sidebar with every permitted section.
- Top-right: **moon/sun** toggles dark mode (remembered), **avatar** opens
  My Profile / Sign out.
- Every list supports **search** (type — it filters after a pause),
  **pagination** (arrows at the bottom) and **pull-to-refresh**.
- Colored tiles on Home are **tappable** and jump to that section; tiles
  outside your role show a notice instead.

---

## 3. Administrator (`admin`) — full control

### 3.1 Dashboard
Home shows live counters (students, teachers, subjects, classes,
enrollments, users), the latest enrollments and the audit trail's most
recent actions. Everything updates on pull-to-refresh.

### 3.2 Manage students
1. Tap the **Students** tab (or tile).
2. **Add**: *New student* → fill code (unique, e.g. S022), names, gender,
   date of birth (must be in the past), email, phone, address → **Create**.
   Validation problems appear inline; server rejections (duplicate code)
   appear as a toast and the dialog stays open.
3. **Edit**: row menu ⋯ → *Edit* → change fields → *Save changes*.
4. **Delete**: row menu ⋯ → *Delete* → confirm. Deletes are **soft** — the
   student disappears from lists but their enrollment/grade history stays.
5. **Detail page**: tap a row → profile card, Enrollments card and Grades
   card:
   - *Enroll* → pick a class → **Enroll** (duplicates and full classes are
     rejected by the server).
   - *Record grade* → pick enrollment (class), subject, score 0–100, term
     (Semester 1/2) → **Record**. One grade per enrollment+subject+term.
   - Edit ✏️ / delete 🗑 next to each grade. Letter badges: A ≥90, B ≥80,
     C ≥70, D ≥60, E ≥50, F below.

### 3.3 Manage teachers
**Teachers** (quick link on phone). Same add/edit/delete flow — code,
names, gender, email, phone, specialization.

### 3.4 Manage subjects
**Subjects** quick link. Code, name, credits (1–20), description.

### 3.5 Manage classes
1. Open **Classes**.
2. *New class* → code, name, academic year (format `2025-2026`), optional
   homeroom teacher (dropdown), capacity.
3. **Tap a class row** → roster dialog: everyone enrolled, *Enroll student*
   to add someone, ✕ to remove an enrollment.

### 3.6 Enrollments overview
**Enrollments** tab shows every student↔class link. Filter by student
and/or class with the dropdowns. Tap a row (or the ⭐ icon) to see the
grades recorded for that enrollment. 🗑 removes an enrollment (grades are
preserved).

### 3.7 Manage users & roles
1. **Users** quick link → create accounts (*New user*: username, email,
   password, roles via chips), edit (leave password blank to keep it),
   *Assign roles* to replace someone's role set, delete (soft; the user
   can no longer sign in). You cannot delete your own account.
2. **Roles** quick link → see the three roles and every permission each
   holds. *Edit permissions* opens a checkbox matrix grouped by resource
   (student, grade, user, …) with select-all per group → **Save**.
   ⚠️ Changes apply the next time users of the role sign in — this is how
   you'd let teachers create students, for example.

### 3.8 Audit logs
**Audit Logs** quick link — every sensitive action (logins, creates,
updates, deletes, password changes) with who/what/when/from-which-IP.
Filter by username, action, entity type and date range; *Clear* resets.

### 3.9 My Profile
Bottom-bar **Profile**: account details, roles, permission chips and
**Change password** (requires the current one; afterwards all sessions are
signed out and you log in with the new password).

---

## 4. Teacher (`teacher1`) — enrollments & grades

What you see: Home, Students, Classes, Enrollments, Profile in the bottom
bar; Teachers and Subjects via quick links. No Users / Roles / Audit.

You can:
1. **Browse** students, teachers, subjects and classes (read-only — no
   New/Edit/Delete buttons anywhere).
2. **Enroll students**: from Enrollments (*Enroll student*), a class
   roster, or a student's detail page.
3. **Remove enrollments** (✕ / 🗑 with confirmation).
4. **Manage grades**: student detail → *Record grade*, edit ✏️, delete 🗑.
   This is the teacher's main daily flow:
   `Students → tap student → Record grade → pick class & subject → score → term → Record`.
5. Change your own password in Profile.

If you try something outside the role (even by hand-crafting a request),
the server answers 403 and the app shows the error.

## 5. Student (`student1`) — read-only

What you see: Home, Classes, Enrollments, Profile in the bottom bar;
Subjects via quick link.

You can:
1. See the **dashboard** counters and recent activity.
2. Browse **subjects** and **classes** (tapping a class shows its roster,
   read-only).
3. Browse **enrollments** and tap one to **view grades**.
4. View **My Profile** and change your own password.

Tiles like *Students* or *Users* show "not available for your role" when
tapped; there are no create/edit/delete buttons anywhere.

---

## 6. Behind the scenes (nice to mention in the defense)

- **JWT lifecycle**: after login the app holds a short-lived access token
  (~15 min) and a refresh token (~24 h) in secure storage. When the access
  token expires the app refreshes it silently and retries — you never
  notice. If the refresh token is also dead (or revoked by logout /
  password change), you're returned to the login screen with a message.
- **Session restore**: reopening the app skips login while the refresh
  token is valid (Splash → `/users/me` → Home).
- **Soft deletes** keep history: deleted students/classes vanish from
  lists but their enrollments and grades remain queryable.
- **Audit**: every mutating action lands in Audit Logs automatically.
