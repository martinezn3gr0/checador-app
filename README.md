# Checador Express

Base Flutter para reconstruir las aplicaciones **Admin** y **Empleado** del PRD.
El proyecto está organizado como una app unificada por ahora, con separación por
rol y soporte para sabores vía `--dart-define=APP_FLAVOR=admin|employee|unified`.

## Estructura propuesta

```text
lib/
  core/
    config/      Variables de entorno y sabor de app
    providers/   Inyección Riverpod y estado de sesión
    routing/     Nombres de rutas
    theme/       Tema Material 3
  features/
    admin/       Dashboard, empleados y obras
    auth/        Startup + login por código/PIN
    employee/    Fichaje, historial y perfil
  models/        Contratos de sesión, empleado, obra y checadas
  services/      Supabase RPC, secure storage, ubicación y asistencia
  widgets/       Componentes comunes
```

## Funcionalidades base incluidas

- Login por empresa, código y PIN mediante RPC `auth_login_with_code_pin`.
- Persistencia segura de sesión con `flutter_secure_storage`.
- Dashboard admin con tarjetas clickeables para filtros operativos.
- Alta de empleado mediante RPC `admin_create_employee_with_credentials`.
- Regeneración de PIN mediante RPC `admin_regenerate_employee_pin`.
- Pantalla de obras preparada para mapa, lat/lng y radio predeterminado de 100m.
- Fichaje de empleado con ubicación foreground y RPC `employee_register_check`.
- Historial con RPC `employee_check_history`.
- Perfil separado entre **Puesto** y **Obra asignada**.

## Ejecución local

Requiere Flutter 3.27 o superior.

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu-anon-key \
  --dart-define=APP_FLAVOR=unified
```

## Mejoras recomendadas siguientes

1. Implementar las funciones RPC definitivas y políticas RLS:
   - `auth_login_with_code_pin`
   - `admin_create_employee_with_credentials`
   - `admin_regenerate_employee_pin`
   - `admin_dashboard_metrics`
   - `admin_list_employees`
   - `admin_upsert_obra`
   - `employee_register_check`
   - `employee_check_history`
2. Usar `pgcrypto`/bcrypt para PIN y guardar solo hashes.
3. Conectar Edge Function de correo con Resend o SendGrid.
4. Sustituir placeholders por Google Maps, cámara y biometría.
5. Crear sabores nativos Android:
   - `com.gis.checador_admin`
   - `com.gis.checador_empleado`
