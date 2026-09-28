# Guía de Conexión con Firebase — La García Zapatería

Esta aplicación está desarrollada con una **arquitectura desacoplada por repositorios (Repository Pattern)**. Actualmente opera en modo local con persistencia offline completa vía JSON y `SharedPreferences`, permitiendo su uso inmediato y continuo sin necesidad de servidor externo.

En cuanto tengas tu proyecto de Firebase creado, la transición se realiza en minutos siguiendo estos pasos:

---

## 1. Crear el Proyecto en Firebase Console
1. Entra a [Firebase Console](https://console.firebase.google.com/).
2. Crea un proyecto nuevo con el nombre (ej. `la-garcia-rh`).
3. Agrega la aplicación Android con el Package Name:
   ```
   com.lagarcia.rh_manage_control
   ```
4. Descarga el archivo `google-services.json` y colócalo en:
   ```
   RH_Manage_Control/android/app/google-services.json
   ```

---

## 2. Agregar dependencias en `pubspec.yaml`
Descomenta o agrega las librerías oficiales de Firebase:
```yaml
dependencies:
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4
  firebase_auth: ^5.3.1
```

Y ejecuta:
```bash
flutter pub get
```

---

## 3. Inicializar Firebase en `lib/main.dart`
En `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'repositories/firebase_database_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // <--- Inicializar Firebase

  // Cambiar el repositorio local por el de Firebase:
  final DatabaseRepository databaseRepository = FirebaseDatabaseRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseRepository>.value(value: databaseRepository),
        ChangeNotifierProvider(create: (_) => AuthProvider(databaseRepository)),
        ChangeNotifierProvider(create: (_) => AdminProvider(databaseRepository)),
        ChangeNotifierProvider(create: (_) => VisitProvider(databaseRepository)),
      ],
      child: const LaGarciaRHApp(),
    ),
  );
}
```

---

## 4. Estructura de Colecciones en Cloud Firestore

### Colección `users`
- `id` (String): ID único del usuario
- `name` (String): Nombre completo (ej. "Lic. Fernando García")
- `email` (String): Correo institucional
- `role` (String): `"admin"` | `"rh"`
- `branchName` (String): Nombre de sucursal asignada
- `isActive` (bool): Estado activo/inactivo

### Colección `branches`
- `id` (String): ID de sucursal
- `code` (String): Clave (ej. `"SUC-01"`)
- `name` (String): `"Sucursal Centro Histórico"`
- `address` (String): Dirección de la tienda
- `city` (String): `"Villahermosa, Tabasco"`
- `managerName` (String): Nombre del encargado(a)
- `phone` (String): Teléfono
- `isActive` (bool): `true`

### Colección `collaborators`
- `id` (String): ID del colaborador
- `code` (String): Clave en piso (ej. `"V1"`, `"V2"`, `"V3"`)
- `fullName` (String): Nombre del colaborador (ej. "Carlos Mendoza")
- `branchId` (String): ID de la sucursal asignada
- `branchName` (String): Nombre de sucursal
- `position` (String): `"Asesor Especialista Damas"`
- `isActive` (bool): `true`

### Colección `stages`
- `id` (String): ID de la etapa
- `category` (String): `"dobleG"` | `"embudo"`
- `title` (String): Nombre (ej. `"10s Reconocimiento"`, `"Compra"`, etc.)
- `description` (String): Conducta clave observable
- `orderIndex` (int): Posición (1 a 7)
- `isKeyConversion` (bool): `true` para la etapa de Compra
- `targetSeconds` (int, opcional): Meta de tiempo (ej. 10 para reconocimiento)

### Colección `visits`
- `id` (String): ID de la visita
- `folio` (String): Folio institucional (ej. `"LGZ-VIS-20260927-4821"`)
- `branchId` (String): ID de la sucursal
- `branchName` (String): Nombre de sucursal
- `auditorId` (String): ID del auditor RH
- `auditorName` (String): Nombre del auditor RH
- `branchManagerName` (String): Encargado(a) en turno
- `startTime` (Timestamp)
- `endTime` (Timestamp)
- `isCompleted` (bool)
- `generalNotes` (String): Observaciones y recomendaciones de RH
- `groups` (Array of Maps):
  - `id`: ID del grupo
  - `groupLetter`: `"A"`, `"B"`, `"C"`
  - `groupNumber`: `1`, `2`, `3`
  - `arrivalTime`: Timestamp
  - `firstAttentionTime`: Timestamp
  - `peopleCount`: `1`, `2` o `3`
  - `collaboratorId`: ID del asesor asignado
  - `collaboratorCode`: `"V1"`
  - `collaboratorName`: `"Carlos Mendoza"`
  - `segment`: `"Damas"` | `"Caballeros"` | `"Niños"` | `"Deportivo"` | `"Confort"`
  - `zone`: `"A"` | `"B"` | `"C"`
  - `stageResults` (Map): `{ "stage_id": "yes" | "no" | "unobserved" }`
  - `isCompleted`: `true`
  - `hasIncident`: `bool`
  - `incidentNote`: String opcional

---

## 5. Reglas de Seguridad en Cloud Firestore (firestore.rules)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```
