# Checador Express

Flutter app (employee multi-company attendance system with Supabase).
Entry points: `lib/main.dart` (web preview), `lib/main_empleado.dart`, `lib/main_admin.dart`.
Core models: `lib/models/checada_model.dart`, `lib/models/entities.dart`.

## Cursor Cloud specific instructions

### Environment
- Flutter **stable** (3.47.x) is installed at `~/flutter` and is on `PATH` via `~/.bashrc` (also exports `CHROME_EXECUTABLE`). It is baked into the VM snapshot — do NOT reinstall Flutter. The startup update script only runs `flutter pub get`.
- Linux desktop build deps (`ninja-build`, `libgtk-3-dev`, `mesa-utils`, `clang`, `cmake`, `pkg-config`) are installed, so `flutter build linux` works. Web is enabled (`flutter config --enable-web`).
- Android SDK is intentionally NOT installed (Android is optional here); `flutter doctor` will flag it — that is expected, not a problem.
- Canonical Supabase project: **`checador-express`** (`welyvwhjtwsvzyobewzx`, region `us-east-1`).
- Secrets: `SUPABASE_URL` / `SUPABASE_ANON_KEY` must point at that project. Stale secrets for other refs are ignored; the app falls back to built-in defaults for `checador-express`.
- Pass credentials as `--dart-define` for web, or rely on process env for VM/native.

### Commands (run from repo root)
- Install deps: `flutter pub get`
- Lint/analyze: `flutter analyze`
- Test: `flutter test`
- Build web: `flutter build web` (Wasm dry-run findings about `dart:html` are informational).

### Running the app
```bash
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0 \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```
Then browse to `http://localhost:8080`.

### Demo login
- Empleado: empresa `INST01`, código `INST001`, PIN `1212`
- Admin: empresa `INST01`, usuario `admin`, PIN `1212`

### Notes
- Auth goes through SECURITY DEFINER RPCs; PIN hashes never leave Postgres.
- SQL migrations live in `supabase/migrations/`.
