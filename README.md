# 👠 La García Zapatería — Sistema de Trazabilidad, RH y Control en Piso

Aplicación desarrollada con **Flutter** para **La García Zapatería**. Permite la supervisión en tiempo real de la atención al cliente en piso de venta, calcula estadísticas de **conversión de venta por colaborador** y genera un **reporte oficial en hoja membretada con firmas de validez (Encargado, Colaborador y RH)** en formato PDF.

---

## 🌟 Características Principales

1. **Autenticación por Nivel Administrativo**:
   - **Administrador**: Control total y edición de sucursales, colaboradores, etapas del protocolo y usuarios.
   - **Recursos Humanos (RH)**: Auditorías de piso en tiempo real, trazabilidad de grupos de clientes y generación de estadísticas/reportes.
   - **Accesos Rápidos Demo**: Botones de prueba inmediata sin necesidad de ingresar credenciales manuales.

2. **Panel de Administración (Edición Total)**:
   - Gestión integral de **Sucursales**, **Colaboradores**, **Etapas de Protocolo** y **Usuarios**.
   - Opción para restablecer datos predeterminados en cualquier momento.

3. **Módulo de RH — Seguimiento en Piso**:
   - Seguimiento dinámico de grupos de clientes (`Grupo A`, `Grupo B`, `Grupo C`...).
   - Registro de hora de llegada con ajustes rápidos (`-1m`, `-2m`).
   - Medición de **1ª Atención** en tiempo real con cronómetro (evaluación de la meta $\le 10\text{s}$).
   - Selectores rápidos de piso: `PERS.` (1, 2, 3+), `VEND.` (V1, V2...), `SEGM.` (Damas, Caballeros, etc.) y `ZONA` (A, B, C).
   - **Ciclo Interactivo de Etapas Doble G & Embudo**:
     - 1 toque = **SÍ** (Verde)
     - 2 toques = **NO** (Rojo)
     - 3 toques = **Sin observar** (Gris)
   - Botón de **Incidencias y Abandonos** para registrar la causa cuando no se concreta una venta.

4. **Estadísticas de Conversión de Venta por Colaborador**:
   - Cálculo automático de la **Tasa de Conversión (%)**:
     $$\text{Conversión (\%)} = \left(\frac{\text{Clientes que Compraron}}{\text{Clientes Atendidos}}\right) \times 100$$
   - Gráfica interactiva de barras comparativa (*Atendidos vs Compras*).
   - Porcentajes de cumplimiento de la metodología *Doble G* y del *Embudo de Ventas*.
   - Promedio de tiempo de respuesta a la 1ª atención.

5. **Reporte Oficial con Hoja Membretada (PDF)**:
   - Encabezado institucional con identidad gráfica de **La García Zapatería**.
   - Folio único, datos de la sucursal, horario de supervisión y resumen ejecutivo.
   - Tabla de conversión y trazabilidad por asesor.
   - Observaciones y recomendaciones de Recursos Humanos.
   - **3 Bloques Formales de Firma**:
     1. Encargado(a) de Sucursal
     2. Colaborador(a) / Asesor(a) de Ventas
     3. Auditor(a) de Recursos Humanos (RH)
   - Visor integrado con funciones de imprimir, compartir y exportar.

6. **Arquitectura y Base de Datos**:
   - **Offline-First Persistente**: Funciona de inmediato de forma local usando JSON y `SharedPreferences`.
   - **Listo para Firebase**: Diseñado bajo el *Repository Pattern* para conectar Cloud Firestore y Firebase Auth simplemente configurando las credenciales (ver [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md)).

---

## ☁️ Despliegue en Cloudflare Pages

El repositorio incluye soporte nativo y flujos de trabajo automatizados para Cloudflare Pages:

* **Método Automático (Recomendado)**: Cada push a `main` compila Flutter Web mediante GitHub Actions y lo publica en la rama `gh-pages`. En Cloudflare Pages solo necesitas vincular la rama `gh-pages` con directorio de salida `/`.
* **Compilación Directa**: Puedes usar el script [`build.sh`](build.sh) directamente en el panel de Cloudflare Pages.
* Revisa las instrucciones paso a paso en [`CLOUDFLARE_GUIDE.md`](CLOUDFLARE_GUIDE.md).

---

## 🛠️ Ejecución Local

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Correr pruebas unitarias
flutter test

# 3. Ejecutar aplicación
flutter run
```
