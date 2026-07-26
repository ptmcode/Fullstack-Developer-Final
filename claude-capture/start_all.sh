#!/bin/bash
# One-shot launcher for screenshot capture — Claude will take over once the emulator is up.
set -u
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CAP="$PROJECT_DIR/claude-capture"
mkdir -p "$CAP"
log(){ echo ""; echo "==== $* ===="; }

log "1/4 Starting Docker + PostgreSQL"
if ! docker info >/dev/null 2>&1; then
  open -a Docker || true
  echo "Waiting for Docker Desktop..."
  for i in $(seq 1 60); do docker info >/dev/null 2>&1 && break; sleep 2; done
fi
( cd "$PROJECT_DIR/springboot-jwt-api/postgres" && docker compose up -d )

log "2/4 Starting Spring Boot backend (log: claude-capture/backend.log)"
if curl -s -o /dev/null http://localhost:30033/; then
  echo "Backend already running on :30033"
else
  ( cd "$PROJECT_DIR/springboot-jwt-api" && nohup ./gradlew bootRun > "$CAP/backend.log" 2>&1 & )
  echo "Waiting for backend on http://localhost:30033 (first build can take a few minutes)..."
  for i in $(seq 1 180); do
    curl -s -o /dev/null http://localhost:30033/ && { echo "Backend is UP"; break; }
    sleep 3
  done
fi

log "3/4 Starting Android emulator"
SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="$SDK/platform-tools/adb"
if "$ADB" devices | grep -q "emulator-.*device"; then
  echo "Emulator already running"
else
  AVD=$("$SDK/emulator/emulator" -list-avds | head -1)
  echo "Launching AVD: $AVD"
  nohup "$SDK/emulator/emulator" -avd "$AVD" > "$CAP/emulator.log" 2>&1 &
fi
"$ADB" wait-for-device
echo "Waiting for Android to finish booting..."
until [ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 3; done
echo "Emulator booted."

log "4/4 Building + launching the Flutter app (release build, takes a few minutes)"
cd "$PROJECT_DIR/school_management_app"
flutter build apk --release || { echo "BUILD FAILED - see output above"; exit 1; }
"$ADB" install -r build/app/outputs/flutter-apk/app-release.apk
PKG=$("$SDK/build-tools"/*/aapt dump badging build/app/outputs/flutter-apk/app-release.apk 2>/dev/null | awk -F"'" '/package: name=/{print $2; exit}')
[ -z "${PKG:-}" ] && PKG="com.example.school_management_app"
"$ADB" shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
echo ""
echo "==================================================================="
echo " ALL READY — the app should now be open in the emulator."
echo " Please leave the emulator window visible and tell Claude 'ready'."
echo "==================================================================="
