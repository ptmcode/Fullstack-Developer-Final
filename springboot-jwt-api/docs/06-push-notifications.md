# 6. Push Notifications (Firebase Cloud Messaging)

How the School Management System delivers push notifications to the Flutter app, and
exactly what credentials you need to switch delivery on.

## 6.1 Do I need a Firebase service account?

**Yes — for real delivery.** Two different credentials are involved, and they are not
interchangeable:

| Credential | Used by | Where it comes from | Needed for |
|-----------|---------|---------------------|-----------|
| **Service account JSON** (private key) | **Spring Boot backend** | Firebase Console → ⚙️ Project settings → **Service accounts** → *Generate new private key* | Authorising the server to *send* messages through FCM |
| `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) | **Flutter app** | Firebase Console → Project settings → *Your apps* → add an Android/iOS app | Letting the device *register* with FCM and receive messages |

**The backend runs fine without either.** With no service account present the app starts
normally and every notification is still created in the database and returned by the API —
only the delivery step is replaced by a log line:

```
WARN  FirebaseMessagingClient : Firebase service account not found — push notifications run in dry-run mode.
INFO  FirebaseMessagingClient : [PUSH dry-run] 1 device(s) | New grade recorded | You scored 88.25 in Physics (term S2) | data={type=GRADE, entityId=52}
```

This mirrors how `MailService` prints password-reset tokens instead of emailing them, so the
whole project remains runnable — and demonstrable — on any machine with no external accounts.

## 6.2 Enabling real delivery (backend)

> ⚠️ **Never commit the service account key.** This repository is public; a leaked private
> key lets anyone send notifications as your project and reach your Firebase resources.
> The key lives outside the project folder and `.gitignore` blocks
> `firebase-service-account*.json` as a second line of defence.

1. **Create a Firebase project** at https://console.firebase.google.com (free Spark plan is enough).
2. **Download the service account key**: ⚙️ Project settings → *Service accounts* →
   *Generate new private key* → a JSON file downloads.
3. **Store it in your home directory** — the location the app looks in by default:

   ```bash
   mkdir -p ~/.secrets && chmod 700 ~/.secrets
   mv ~/Downloads/<project>-firebase-adminsdk-*.json ~/.secrets/firebase-service-account.json
   chmod 600 ~/.secrets/firebase-service-account.json
   ```

4. **Run the app — no configuration needed.** `application.yml` resolves the key to
   `${user.home}/.secrets/firebase-service-account.json` by default:

   ```yaml
   app:
     firebase:
       enabled: true
       credentials-path: ${FIREBASE_CREDENTIALS:${user.home}/.secrets/firebase-service-account.json}
   ```

   To keep the key somewhere else, set the environment variable instead:

   ```bash
   export FIREBASE_CREDENTIALS=/path/to/service-account.json
   ```

   A `classpath:` location is also accepted (e.g. `classpath:firebase/key.json`) — only do this
   for a private repository.

5. **Confirm** on startup:

   ```
   INFO  FirebaseMessagingClient : Firebase Cloud Messaging initialised — push notifications are live
   ```

To force dry-run mode even when a key is present, set `app.firebase.enabled: false`.

**If a key is ever exposed** (committed, pasted into a chat, shared in a screenshot), revoke it:
Firebase Console → Project settings → Service accounts → *Manage service account keys* →
delete the key id, then generate a new one. Rotating costs nothing and is instant.

## 6.3 Enabling the Flutter client

1. In the Firebase Console add an **Android app** with the Flutter app's application id
   (e.g. `com.example.school_management_app`) and download `google-services.json` into
   `android/app/`. For iOS add an iOS app and put `GoogleService-Info.plist` in `ios/Runner/`.
2. Add the packages:

   ```bash
   flutter pub add firebase_core firebase_messaging flutter_local_notifications
   ```

3. Initialise Firebase in `main()`, request permission, then send the token to this API:

   ```dart
   await Firebase.initializeApp();
   await FirebaseMessaging.instance.requestPermission();          // iOS / Android 13+
   final token = await FirebaseMessaging.instance.getToken();

   // POST /api/v1/devices with the user's JWT
   await api.post('/devices', body: {
     'token': token,
     'deviceType': Platform.isAndroid ? 'ANDROID' : 'IOS',
     'deviceName': deviceModel,
   });

   // FCM rotates tokens — re-register when it does
   FirebaseMessaging.instance.onTokenRefresh.listen(registerDevice);
   ```

4. Handle incoming messages:

   ```dart
   FirebaseMessaging.onMessage.listen(showLocalNotification);      // app in foreground
   FirebaseMessaging.onMessageOpenedApp.listen(handleDeepLink);    // user tapped the push
   FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
   ```

   Every push carries a `data` map — `type` (`GRADE` / `ENROLLMENT` / `ANNOUNCEMENT`),
   `entityType` and `entityId` — so the app can open the right screen when tapped.

5. Call `POST /api/v1/auth/logout` on sign-out: the backend deactivates that user's device
   tokens so a signed-out phone stops receiving notifications.

## 6.4 What triggers a notification

| Event | Recipient | Title |
|-------|-----------|-------|
| Teacher/admin records a grade | The graded student | *New grade recorded* |
| A grade is updated | The graded student | *Grade updated* |
| A student is enrolled in a class | That student | *Class enrollment* |
| Admin/teacher posts an announcement (`POST /notifications/send`) | A whole role, or a chosen list of users | the given title |

A student only receives notifications if their `students` row is linked to a login account
(`students.user_id`). Migration `V5` links the demo account `student1` to student `S001`;
link others by setting that column.

Notifications never break the operation that triggered them: sending runs in its own
transaction and swallows failures, so a Firebase outage can never roll back a saved grade.

## 6.5 API

| Method & path | Purpose | Auth |
|---------------|---------|------|
| `POST /api/v1/devices` | Register this device's FCM token | Authenticated |
| `GET /api/v1/devices` | List my registered devices | Authenticated |
| `DELETE /api/v1/devices?token=…` | Unregister a device | Authenticated |
| `GET /api/v1/notifications` | My inbox (paginated, `unreadOnly=true` filter) | `notification.read` |
| `GET /api/v1/notifications/unread-count` | Badge counter | `notification.read` |
| `PUT /api/v1/notifications/{id}/read` | Mark one as read | `notification.read` |
| `PUT /api/v1/notifications/read-all` | Mark all as read | `notification.read` |
| `POST /api/v1/notifications/send` | Broadcast to a role or list of users | `notification.send` |

Seeded roles: ADMIN and TEACHER may send; all three roles may read their own inbox.

### Payload contract (for the Flutter client)

`POST /devices` — request, then response `data`:

```jsonc
// request
{ "token": "<fcm-token>", "deviceType": "ANDROID", "deviceName": "Pixel 7" }
// data
{ "id": 3, "token": "<fcm-token>", "deviceType": "ANDROID", "deviceName": "Pixel 7", "status": "ACT" }
```

`GET /notifications` — standard paged envelope; one item of `data.content`:

```jsonc
{
  "id": 5,
  "title": "New grade recorded",
  "body": "You scored 79.0 in English (term S2)",
  "type": "GRADE",            // GRADE | ENROLLMENT | ANNOUNCEMENT
  "entityType": "GRADE",
  "entityId": "55",           // string — use for deep-linking
  "read": false,              // note: JSON field is "read", column is is_read
  "sentStatus": "SENT",       // SENT | SKIPPED | DISABLED
  "createdAt": "2026-07-26T22:40:52.331435"
}
```

`GET /notifications/unread-count` → `"data": 2` (plain integer).

`PUT /notifications/{id}/read` → `data` is the updated notification object (same shape as above).
`PUT /notifications/read-all` → `data` is the number of rows updated.

`POST /notifications/send` — request, then response `data`:

```jsonc
// request: either "role" or "userIds"
{ "title": "School closed Friday", "body": "Public holiday.", "role": "ROLE_STUDENT" }
{ "title": "Reminder", "body": "Submit your assignment.", "userIds": [3] }
// data
{ "recipients": 1, "devicesReached": 0, "pushEnabled": true }
```

The FCM message itself carries `notification.title` / `notification.body` plus a `data` map of
`{type, entityType, entityId}` — all values are strings, as FCM requires.

## 6.6 Data model (migration V5)

```
device_tokens   id, user_id → users, token (unique), device_type, device_name, status
notifications   id, user_id → users, title, body, type, entity_type, entity_id,
                is_read (Y/N), sent_status (SENT|SKIPPED|DISABLED), created_at
students        + user_id → users (nullable, unique) — links a student to their account
```

`sent_status` records what happened at send time: `SENT` (handed to FCM), `SKIPPED` (user has
no registered device), `DISABLED` (dry-run — no service account configured).

Tokens FCM rejects as `UNREGISTERED` or `INVALID_ARGUMENT` (app uninstalled, token expired)
are automatically deactivated, so dead devices are not retried.

## 6.7 Testing without a phone

The API is fully testable with any HTTP client — device tokens are just strings until FCM is enabled:

```bash
# 1. Register a fake device for student1
curl -X POST http://localhost:30033/api/v1/devices \
  -H "Authorization: Bearer $STUDENT_TOKEN" -H 'Content-Type: application/json' \
  -d '{"token":"demo-fcm-token-abc123","deviceType":"ANDROID","deviceName":"Demo"}'

# 2. As teacher1, record a grade for that student -> notification is created + push logged
# 3. Read the inbox
curl http://localhost:30033/api/v1/notifications -H "Authorization: Bearer $STUDENT_TOKEN"
```

With a real service account and a real device token, step 2 makes the phone buzz — the
backend code path is identical.
