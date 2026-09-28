# Guía de Conexión Supabase — La García Zapatería

La aplicación ya está configurada con el cliente oficial de **Supabase** (`supabase_flutter`) y utiliza `SupabaseDatabaseRepository` como base de datos principal, reemplazando la versión puramente local.

---

## 1. Crear las Tablas en Supabase (1 Clic)

1. Entra a tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard).
2. En el menú lateral izquierdo, haz clic en **SQL Editor**.
3. Abre el archivo [`supabase/schema.sql`](supabase/schema.sql) de este repositorio, copia todo su contenido y pégalo en el editor SQL de Supabase.
4. Presiona el botón verde **Run**.
5. ¡Listo! Se habrán creado las 5 tablas con sus políticas RLS y los datos demo iniciales:
   - `users` (Usuarios con roles Admin y RH)
   - `branches` (Sucursales de La García Zapatería)
   - `collaborators` (Asesores en piso: V1, V2, V3...)
   - `stages` (Etapas de la metodología Doble G & Embudo)
   - `visits` (Auditorías de piso, grupos y tiempos de atención)

---

## 2. Obtener tus Credenciales de Supabase

En tu panel de Supabase:
1. Ve a **Project Settings** (ícono de engrane abajo a la izquierda) > **API**.
2. Copia los siguientes dos valores:
   - **Project URL**: `https://xxxxxxxxxxxxxxxxxxxx.supabase.co`
   - **Project API Keys** (anon / public): `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

---

## 3. Conectar la App a tu Supabase

Tienes dos formas muy sencillas de conectar la app:

### Opción A (Directamente desde la pantalla de la App):
1. Abre la aplicación (en web, móvil o escritorio).
2. En la pantalla de inicio de sesión, haz clic en el botón verde:  
   **"Configurar Base de Datos Supabase"** (o en el ícono de base de datos en el panel de Administrador).
3. Pega tu **Project URL** y tu **Anon Key**.
4. Presiona **Guardar y Conectar**.
5. Las credenciales se guardan y la app se conecta inmediatamente a tu base de datos en Supabase.

### Opción B (Mediante variables de entorno al compilar):
```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```
O al compilar para la web:
```bash
flutter build web --release --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co --dart-define=SUPABASE_ANON_KEY=tu-anon-key
```
