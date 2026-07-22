# Checador Express

Flutter app (employee multi-company attendance system, intended to use Supabase). Entry point is `lib/main.dart`; core domain model is `lib/models/checada_model.dart`.

## Cursor Cloud specific instructions

### Environment
- Flutter **stable** (3.44.x) is installed at `~/flutter` and is on `PATH` via `~/.bashrc` (also exports `CHROME_EXECUTABLE`). It is baked into the VM snapshot — do NOT reinstall Flutter. The startup update script only runs `flutter pub get`.
- Linux desktop build deps (`ninja-build`, `libgtk-3-dev`, `mesa-utils`, `clang`, `cmake`, `pkg-config`) are installed, so `flutter build linux` works. Web is enabled (`flutter config --enable-web`).
- Android SDK is intentionally NOT installed (Android is optional here); `flutter doctor` will flag it — that is expected, not a problem.

### Commands (run from repo root)
- Install deps: `flutter pub get`
- Lint/analyze: `flutter analyze` (passes; there are 2 pre-existing `info`-level `use_super_parameters` hints in `lib/widgets/common/*` — non-blocking).
- Test: `flutter test`
- Build web: `flutter build web` (the "Wasm dry run findings" about `dart:html` in `flutter_secure_storage_web`/`geolocator_web` are informational — the default JS build still succeeds).

### Running the app
- This VM is headless, so `flutter run -d chrome` cannot auto-launch a GUI browser. Use the web-server device instead and open the URL in the Desktop pane's Chrome:
  `flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0`
- Then browse to `http://localhost:8080`. The home screen (`CheckInScreen`) registers Entrada/Salida attendance records.

### Notes
- `web/`, `lib/main.dart`, `analysis_options.yaml`, `.metadata`, and `.gitignore` were generated with `flutter create --platforms=web`; `lib/main.dart` was then replaced with a minimal attendance UI.
- `pubspec.yaml` pins `intl: ^0.20.2` because Flutter stable's `flutter_localizations` requires `intl 0.20.2`.
