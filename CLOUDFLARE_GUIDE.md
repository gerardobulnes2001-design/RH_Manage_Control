# Guía de Despliegue en Cloudflare Pages — La García Zapatería

Para visualizar la aplicación en **Cloudflare Pages**, tienes **dos métodos sencillos y directos**:

---

## Método 1: Despliegue Inmediato desde la Rama `gh-pages` (Recomendado — En 1 minuto)

Cada vez que haces un `git push` a la rama `main`, GitHub Actions compila automáticamente Flutter Web y guarda los archivos listos en la rama `gh-pages`.

### Pasos en Cloudflare:
1. Inicia sesión en tu cuenta de [Cloudflare Dashboard](https://dash.cloudflare.com/).
2. Ve al menú lateral: **Workers y Pages** > **Crear aplicación** > pestaña **Pages**.
3. Selecciona **Conectar a Git** y elige tu repositorio `RH_Manage_Control`.
4. En la configuración de compilación ajusta lo siguiente:
   - **Rama de producción (Production branch)**: `gh-pages`
   - **Preajuste de entorno (Framework preset)**: `Ninguno` (None)
   - **Comando de compilación (Build command)**: *(Dejar vacío)*
   - **Directorio de salida (Build output directory)**: `/` (o dejar vacío)
5. Haz clic en **Guardar e implementar**.
6. ¡Listo! Cloudflare Pages desplegará tu aplicación en segundos con una URL pública gratuita (ej. `rh-manage-control.pages.dev`).

---

## Método 2: Compilación Nativa en Cloudflare desde la Rama `main`

Si prefieres que Cloudflare compile Flutter directamente desde el código fuente de `main`:

### Pasos en Cloudflare:
1. En Cloudflare Pages, selecciona el repositorio `RH_Manage_Control` y rama `main`.
2. Configuración:
   - **Preajuste de entorno**: `Ninguno`
   - **Comando de compilación**:
     ```bash
     bash build.sh
     ```
   - **Directorio de salida de compilación**:
     ```
     build/web
     ```
3. Haz clic en **Guardar e implementar**.
4. Cloudflare descargará Flutter SDK y compilará la versión web automáticamente.
