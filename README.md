# Checador Express

Sistema de **asistencia laboral multi-empresa** (Flutter + Supabase).

## Propósito

Permitir que empleados registren **entrada/salida** con geocerca en la obra, y que administradores vean dashboard, checadas y faltas del día — segregado por empresa.

## Apps

| App | Entry | Android flavor |
| --- | --- | --- |
| Empleado | `lib/main_empleado.dart` | `empleado` |
| Admin | `lib/main_admin.dart` | `admin` |
| Web / preview | `lib/main.dart` | — |

## Credenciales demo

| Rol | Empresa | Usuario/código | PIN |
| --- | --- | --- | --- |
| Empleado | `INST01` | `INST001` | `1212` |
| Admin | `INST01` | `admin` | `1212` |

## Configurar Supabase

Proyecto canónico: **`checador-express`** (`https://welyvwhjtwsvzyobewzx.supabase.co`).

La app ya incluye defaults para ese proyecto. Opcionalmente puedes sobreescribir:

```bash
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0 \
  --dart-define=SUPABASE_URL=https://welyvwhjtwsvzyobewzx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Si `SUPABASE_URL` del entorno apunta a otro proyecto, se ignora y se usan los defaults.

Migraciones: `supabase/migrations/`.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter build web
flutter build apk --flavor empleado -t lib/main_empleado.dart
flutter build apk --flavor admin -t lib/main_admin.dart
```

Ver también `AGENTS.md` para el entorno Cloud Agent.
