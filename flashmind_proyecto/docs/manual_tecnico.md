# Manual Técnico — FlashMind

## Descripción general

FlashMind es una aplicación móvil de microaprendizaje construida con Flutter. Permite a los usuarios completar sesiones de estudio de 7 minutos con preguntas de opción múltiple organizadas en categorías y temas. Incluye autenticación con Firebase, almacenamiento local con Hive y seguimiento de progreso del usuario.

---

## Contenido

1. [Stack tecnológico](#1-stack-tecnológico)
2. [Arquitectura](#2-arquitectura)
3. [Estructura del proyecto](#3-estructura-del-proyecto)
4. [Configuración del entorno](#4-configuración-del-entorno)
5. [Dependencias](#5-dependencias)
6. [Flujo de navegación](#6-flujo-de-navegación)
7. [Módulos principales](#7-módulos-principales)
8. [Sistema de temas (light/dark)](#8-sistema-de-temas-lightdark)
9. [Gestión de preguntas](#9-gestión-de-preguntas)
10. [Autenticación](#10-autenticación)
11. [Inyección de dependencias](#11-inyección-de-dependencias)
12. [Pruebas unitarias](#12-pruebas-unitarias)
13. [Cómo agregar contenido](#13-cómo-agregar-contenido)

---

## 1. Stack tecnológico

| Tecnología | Versión | Uso |
|---|---|---|
| Flutter | SDK ^3.11.0 | Framework principal |
| Dart | ^3.11.0 | Lenguaje |
| Firebase Auth | ^5.5.2 | Autenticación |
| Hive Flutter | ^1.1.0 | Almacenamiento local |
| flutter_bloc | ^9.0.0 | Gestión de estado |
| go_router | ^14.6.3 | Navegación declarativa |
| get_it | ^8.0.3 | Inyección de dependencias |
| google_sign_in | ^6.2.2 | Autenticación con Google |
| google_fonts | ^6.2.1 | Tipografías (Sora + Manrope) |
| mocktail | ^1.0.4 | Mocking en tests |

---

## 2. Arquitectura

El proyecto sigue **Clean Architecture** dividida en tres capas por cada feature:

```
Feature
├── data/           ← Implementaciones concretas
│   ├── datasources/    ← Firebase, Hive, JSON local
│   ├── models/         ← Modelos serializables (Hive adapters)
│   └── repositories/   ← Implementación de los contratos
│
├── domain/         ← Lógica de negocio pura (sin Flutter)
│   ├── entities/       ← Objetos de dominio (Equatable)
│   ├── repositories/   ← Contratos (abstract interface)
│   └── usecases/       ← Casos de uso (1 clase = 1 acción)
│
└── presentation/   ← UI y gestión de estado
    ├── cubit/          ← Estado + transiciones (BLoC/Cubit)
    ├── pages/          ← Pantallas
    └── widgets/        ← Componentes reutilizables de la feature
```

### Patrón de estado

Se usa `flutter_bloc` con `Cubit` (variante simplificada de BLoC). Cada Cubit:
- Extiende `Cubit<SomeState>`
- Los estados usan `sealed class` + `Equatable`
- Las dependencias se inyectan por constructor

### Patrón Either

La capa de dominio usa un tipo `Either<Failure, T>` propio para representar resultados:

```dart
// lib/core/utils/either.dart
sealed class Either<L, R> { ... }
class Left<L, R> extends Either<L, R> { final L value; }   // Error
class Right<L, R> extends Either<L, R> { final R value; }  // Éxito
```

Los `Failure` están definidos en `lib/core/errors/failures.dart`:
- `CacheFailure` — errores de almacenamiento local
- `ValidationFailure` — errores de validación
- `NotFoundFailure` — elemento no encontrado
- `UnknownFailure` — error genérico

---

## 3. Estructura del proyecto

```
flashmind_proyecto/
├── lib/
│   ├── app.dart                    ← MaterialApp + ThemeCubit
│   ├── injection.dart              ← Registro de dependencias (GetIt)
│   ├── main.dart                   ← Entrada, Firebase init
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart     ← Colores + extensión AppColorsTheme
│   │   │   ├── app_durations.dart  ← Constantes de tiempo
│   │   │   ├── app_strings.dart    ← Textos constantes
│   │   │   └── app_text_styles.dart← Estilos tipográficos
│   │   ├── errors/
│   │   │   └── failures.dart       ← Clases Failure
│   │   ├── router/
│   │   │   ├── app_router.dart     ← GoRouter + setCurrentUser()
│   │   │   └── route_names.dart    ← Constantes de rutas
│   │   ├── theme/
│   │   │   ├── app_gradients.dart  ← Gradientes + CategoryGradientType enum
│   │   │   ├── app_theme.dart      ← ThemeData light/dark
│   │   │   └── theme_cubit.dart    ← Toggle light/dark
│   │   ├── utils/
│   │   │   ├── either.dart         ← Either<L, R>
│   │   │   ├── no_params.dart      ← NoParams para use cases sin parámetros
│   │   │   └── use_case.dart       ← Interfaz UseCase<T, Params>
│   │   └── widgets/                ← Widgets reutilizables globales
│   │       ├── app_button.dart
│   │       ├── app_loading_indicator.dart
│   │       ├── app_snack_bar.dart
│   │       ├── app_text_field.dart
│   │       ├── shimmer_loader.dart
│   │       └── stat_card.dart
│   │
│   ├── features/
│   │   ├── auth/                   ← Autenticación
│   │   ├── home/                   ← Pantalla principal y progreso
│   │   ├── session/                ← Sesión de preguntas y selección de tema
│   │   └── results/                ← Resultados y logros
│   │
│   └── splash/
│       └── splash_page.dart        ← Pantalla de carga inicial
│
├── assets/
│   └── data/
│       └── questions.json          ← Base de datos de preguntas
│
├── test/
│   ├── helpers/
│   │   ├── fixtures.dart           ← Datos de prueba compartidos
│   │   └── mocks.dart              ← Clases Mock (mocktail)
│   └── features/                   ← Tests unitarios por feature
│       ├── auth/
│       ├── home/
│       ├── session/
│       └── results/
│
└── docs/
    ├── manual_usuario.md
    └── manual_tecnico.md
```

---

## 4. Configuración del entorno

### Requisitos previos

- Flutter SDK **3.11.0** o superior
- Dart **3.11.0** o superior
- Android Studio / VS Code con extensiones Flutter
- Cuenta Firebase con proyecto configurado

### Instalación

```bash
# Clonar el repositorio
git clone <url-repositorio>
cd flashmind_proyecto

# Instalar dependencias
flutter pub get

# Generar adaptadores Hive
dart run build_runner build --delete-conflicting-outputs

# Ejecutar la app
flutter run
```

### Configuración Firebase

1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com).
2. Agregar las apps Android e iOS al proyecto.
3. Descargar `google-services.json` → colocar en `android/app/`.
4. Descargar `GoogleService-Info.plist` → colocar en `ios/Runner/`.
5. En Firebase Console → Authentication → Sign-in methods:
   - Habilitar **Email/Password**
   - Habilitar **Google**
6. Para Android con Google Sign-In: agregar el **SHA-1 fingerprint** del keystore en Firebase Console.

### Variables de configuración web

En `web/index.html` está configurado el `clientId` de Google OAuth para la versión web:

```html
<meta name="google-signin-client_id"
      content="259868031727-u4q43o984t4snu1hbda5cgnjnft77l6b.apps.googleusercontent.com">
```

---

## 5. Dependencias

### Producción

| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_bloc` | ^9.0.0 | Cubit/BLoC state management |
| `equatable` | ^2.0.7 | Igualdad de objetos en estados |
| `go_router` | ^14.6.3 | Navegación declarativa con rutas nombradas |
| `get_it` | ^8.0.3 | Service locator para DI |
| `hive_flutter` | ^1.1.0 | Base de datos clave-valor local |
| `firebase_core` | ^3.13.0 | Inicialización Firebase |
| `firebase_auth` | ^5.5.2 | Autenticación |
| `google_sign_in` | ^6.2.2 | OAuth2 con Google |
| `google_fonts` | ^6.2.1 | Sora (títulos) y Manrope (cuerpo) |
| `flutter_animate` | ^4.5.0 | Animaciones declarativas |
| `percent_indicator` | ^4.2.4 | Anillo de precisión en resultados |
| `uuid` | ^4.5.1 | Generación de IDs únicos |

### Desarrollo y Testing

| Paquete | Versión | Propósito |
|---|---|---|
| `flutter_test` | SDK | Framework de testing |
| `mocktail` | ^1.0.4 | Mocking de dependencias |
| `hive_generator` | ^2.0.1 | Generación de adaptadores Hive |
| `build_runner` | ^2.4.13 | Generador de código |
| `flutter_lints` | ^6.0.0 | Reglas de linting |

---

## 6. Flujo de navegación

```
/splash
  └── (autenticado) → /home
  └── (no autenticado) → /auth
       └── (login/register exitoso) → /home

/home
  ├── Tab Inicio → categorías → /home/topics
  │                               └── tema → /home/topics/session
  │                                             └── (fin sesión) → /home/topics/session/results
  │                                                                   └── "Inicio" → /home
  ├── Tab Perfil
  └── Tab Ajustes → "Cerrar sesión" → /auth
```

GoRouter está configurado en `lib/core/router/app_router.dart`. Los parámetros entre pantallas se pasan mediante `extra`:

```dart
// Navegar a selección de tema
context.push(RouteNames.topicSelection, extra: {
  'categoryId': category.id,
  'categoryName': category.name,
  'gradientType': category.gradientType,
});

// Navegar a sesión
context.push(RouteNames.session, extra: {
  'topicId': topic.id,
  'categoryId': categoryId,
});
```

---

## 7. Módulos principales

### Auth

| Archivo | Responsabilidad |
|---|---|
| `AuthCubit` | Maneja login, register, Google Sign-In, logout |
| `AuthState` | `AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthFailure` |
| `FirebaseAuthDataSourceImpl` | Llama a Firebase Auth; en web usa `signInWithPopup` |
| `LoginUser`, `RegisterUser`, `LogoutUser` | Use cases de autenticación |

**Diferencia web/móvil en Google Sign-In:**

```dart
// En web (kIsWeb = true)
await _auth.signInWithPopup(GoogleAuthProvider());

// En móvil
final account = await _googleSignIn.signIn();
final credential = GoogleAuthProvider.credential(idToken: ...);
await _auth.signInWithCredential(credential);
```

### Home

| Archivo | Responsabilidad |
|---|---|
| `HomeCubit` | Carga categorías y progreso del usuario |
| `HomeLocalDataSource` | Retorna las 9 categorías hardcodeadas |
| `ProgressLocalDataSource` | Lee/escribe el progreso en Hive |
| `GetCategories` | Obtiene lista de `CategoryEntity` |
| `GetUserProgress` | Obtiene `UserProgressEntity` por userId |

### Session

| Archivo | Responsabilidad |
|---|---|
| `TopicSelectionCubit` | Carga temas de una categoría |
| `SessionCubit` | Maneja el flujo de la sesión: timer, respuestas, puntos |
| `QuestionsLocalDataSource` | Lee preguntas del JSON con caché en memoria |
| `GetQuestionsForTopic` | Filtra preguntas por `topicId` |
| `SaveSessionResult` | Guarda el resultado en Hive |

**Flujo interno de `SessionCubit`:**

```
startSession(topicId, categoryId)
  → emit(SessionLoading)
  → getQuestionsForTopic(topicId)
  → emit(SessionInProgress) + startTimer()

selectOption(index)
  → verifica respuesta
  → emit(SessionInProgress con isAnswerRevealed=true)

nextQuestion()
  → si es última: _finishSession() → emit(SessionComplete)
  → si no: emit(SessionInProgress con currentIndex+1)

_onTimerTick() (cada 1 segundo)
  → si secondsRemaining ≤ 1: _finishSession()
  → si no: emit(SessionInProgress con secondsRemaining-1)
```

### Results

| Archivo | Responsabilidad |
|---|---|
| `ResultsCubit` | Carga logros según el resultado de la sesión |
| `ResultsLocalDataSourceImpl` | Evalúa condiciones y retorna `AchievementEntity[]` |
| `ScoreRing` | Widget del anillo circular de precisión |

---

## 8. Sistema de temas (light/dark)

### ThemeCubit

```dart
// lib/core/theme/theme_cubit.dart
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);
  void toggleTheme() => emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
```

Registrado en `app.dart` como `BlocProvider<ThemeCubit>` que envuelve `MaterialApp.router`.

### Colores adaptativos

Todos los widgets usan la extensión `AppColorsTheme` en lugar de colores hardcodeados:

```dart
// lib/core/constants/app_colors.dart
extension AppColorsTheme on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get acBg      => _isDark ? Color(0xFF07131F) : Color(0xFFF0F7FF);
  Color get acSurface => _isDark ? AppColors.surface  : Colors.white;
  Color get acText    => _isDark ? AppColors.textPrimary : Color(0xFF0D2137);
  Color get acTextSub => _isDark ? AppColors.textSecondary : Color(0xFF4A6D8C);
  // ... etc
}
```

**Uso en widgets:**
```dart
Container(
  color: context.acSurface,
  child: Text('Hola', style: TextStyle(color: context.acText)),
)
```

### TextTheme adaptativo

`AppTextStyles` define estilos sin color (heredan del tema). Los colores se asignan en `AppTheme.lightTheme` y `AppTheme.darkTheme` via `textTheme.copyWith(...)`.

---

## 9. Gestión de preguntas

Las preguntas se cargan desde `assets/data/questions.json` con caché en memoria para evitar lecturas repetidas:

```dart
// lib/features/session/data/datasources/questions_local_data_source.dart
Map<String, dynamic>? _cache;

Future<Map<String, dynamic>> _loadData() async {
  _cache ??= jsonDecode(await rootBundle.loadString('assets/data/questions.json'));
  return _cache!;
}
```

### Estructura del JSON

```json
{
  "topics": [
    {
      "id": "historia_rev_francesa",
      "categoryId": "historia",
      "title": "La Revolución Francesa",
      "description": "Causas y consecuencias",
      "questionCount": 5,
      "difficulty": "easy"
    }
  ],
  "questions": [
    {
      "id": "hist_rev_q1",
      "topicId": "historia_rev_francesa",
      "questionText": "¿En qué año inició la Revolución Francesa?",
      "options": ["1789", "1804", "1776", "1815"],
      "correctOptionIndex": 0,
      "explanation": "La Revolución Francesa comenzó en 1789.",
      "pointValue": 10
    }
  ]
}
```

### Categorías disponibles (IDs en JSON)

| ID en JSON | Categoría |
|---|---|
| `historia` | Historia |
| `ciencia` | Ciencia |
| `idiomas` | Idiomas |
| `tecnologia` | Tecnología |
| `matematicas` | Matemáticas |
| `arte` | Arte y Cultura |
| `geografia` | Geografía |
| `filosofia` | Filosofía |
| `economia` | Economía |

---

## 10. Autenticación

### Flujo de inicio

`SplashPage` llama a `AuthRepository.getCurrentUser()`:
- Si retorna un usuario → navega a `/home` y llama `setCurrentUser(id, username)`
- Si retorna null → navega a `/auth`

### `setCurrentUser`

Función global en `app_router.dart` que guarda el `userId` y `username` actuales para que `GoRouter` pueda acceder a ellos al construir la ruta `/home`:

```dart
String _currentUserId = '';
String _currentUsername = '';

void setCurrentUser(String id, String username) {
  _currentUserId = id;
  _currentUsername = username;
}
```

### Modelos de usuario

`UserModel` (Hive) almacena la sesión localmente. `UserEntity` (domain) es el objeto puro sin dependencias de infraestructura.

---

## 11. Inyección de dependencias

`GetIt` actúa como service locator. Todo se registra en `lib/injection.dart` con `setupDependencies()` que se llama antes de `runApp()`.

```dart
// Orden de registro en injection.dart
1. Hive boxes (local storage)
2. DataSources (Firebase, Hive, JSON)
3. Repositories (implementaciones)
4. Use Cases
5. Cubits
6. ThemeCubit
```

**Singleton vs Factory:**
- `registerLazySingleton` → `DataSources`, `Repositories`, `UseCases`, `ThemeCubit`
- `registerFactory` → `Cubits` (nueva instancia por pantalla)

**Uso:**
```dart
// En widgets y páginas
context.read<HomeCubit>()  // BLoC/Cubit vía Provider

// Fuera del árbol de widgets
sl<LogoutUser>()           // GetIt directamente
```

---

## 12. Pruebas unitarias

El proyecto cuenta con **72 tests unitarios** organizados en dos capas: Cubits y Use Cases.

### Ejecutar tests

```bash
# Todos los tests
flutter test

# Con reporte detallado
flutter test --reporter=expanded

# Un archivo específico
flutter test test/features/auth/cubit/auth_cubit_test.dart

# Una feature completa
flutter test test/features/session/
```

### Cobertura de tests

| Módulo | Tests | Descripción |
|---|---|---|
| `AuthCubit` | 15 | login, register, Google, logout, toggleForm, checkCurrentUser |
| `HomeCubit` | 5 | loadHome éxito, fallo categorías, fallo progreso |
| `SessionCubit` | 14 | startSession, selectOption, nextQuestion, SessionComplete |
| `TopicSelectionCubit` | 5 | loadTopics éxito, fallo, vacío |
| `ResultsCubit` | 4 | loadResults, excepción |
| Use cases Auth | 9 | LoginUser, RegisterUser, LogoutUser |
| Use cases Home | 7 | GetCategories, GetUserProgress |
| Use cases Session | 10 | GetQuestionsForTopic, GetTopicsByCategory, SaveSessionResult |
| **Total** | **72** | |

### Estructura de un test de Cubit

```dart
test('login exitoso emite [AuthLoading, AuthSuccess]', () async {
  // Arrange: stub del mock
  when(() => mockLoginUser(any())).thenAnswer((_) async => Right(tUser));

  // Escuchar estados ANTES de actuar
  final future = cubit.stream.take(2).toList();

  // Act
  await cubit.login('test@test.com', 'password123');

  // Assert: verificar la secuencia de estados
  expect(await future, [const AuthLoading(), AuthSuccess(tUser)]);
});
```

> **Nota técnica:** `flutter_bloc` usa `StreamController.broadcast()` con entrega asíncrona. Se usa `stream.take(n).toList()` para capturar estados antes de llamar al Cubit, y `cubit.state` para verificar el estado final.

### Archivos de soporte

| Archivo | Contenido |
|---|---|
| `test/helpers/fixtures.dart` | Instancias de entidades para tests (`tUser`, `tCategory`, `tQuestion`, etc.) |
| `test/helpers/mocks.dart` | Clases Mock generadas con `mocktail` para todos los repositorios y use cases |

---

## 13. Cómo agregar contenido

### Agregar preguntas a un tema existente

1. Abrir `assets/data/questions.json`.
2. Agregar objetos al array `"questions"` con el `topicId` correspondiente.
3. Actualizar `questionCount` en el objeto del topic si es necesario.

### Agregar un nuevo tema

1. En `questions.json`, agregar un objeto al array `"topics"`:
```json
{
  "id": "historia_napoleon",
  "categoryId": "historia",
  "title": "El Imperio Napoleónico",
  "description": "Expansión y caída de Napoleón",
  "questionCount": 5,
  "difficulty": "medium"
}
```
2. Agregar las preguntas correspondientes al array `"questions"`.

### Agregar una nueva categoría

1. **`app_colors.dart`** — agregar colores de la nueva categoría:
```dart
static const Color nuevaCatStart = Color(0xFF...);
static const Color nuevaCatEnd = Color(0xFF...);
```

2. **`app_gradients.dart`** — agregar al enum y los switch:
```dart
enum CategoryGradientType {
  history, science, ..., nuevaCategoria // ← agregar
}
// Actualizar forCategory() y shadowColorForCategory()
```

3. **`home_local_data_source.dart`** — agregar la `CategoryEntity`:
```dart
CategoryEntity(
  id: 'nueva_categoria',
  name: 'Nueva Categoría',
  gradientType: CategoryGradientType.nuevaCategoria,
  // ...
)
```

4. **`category_card.dart`** — agregar el case al switch de `startColor`.

5. **`questions.json`** — agregar topics y preguntas con el nuevo `categoryId`.

### Modificar la duración de la sesión

En `lib/core/constants/app_durations.dart`:
```dart
static const sessionDuration = Duration(minutes: 7); // cambiar aquí
```

---

## Decisiones de diseño notables

| Decisión | Razón |
|---|---|
| `sealed class` para estados | Garantiza exhaustividad en los switch (el compilador avisa si falta un caso) |
| Caché en memoria para el JSON | Evita I/O repetida; las preguntas no cambian en runtime |
| `StatefulWidget` para `FlashMindApp` | Evita que `GoRouter` se recree en cada rebuild del `ThemeCubit`, lo que causaría reset de navegación |
| `kIsWeb` para Google Sign-In | `google_sign_in_web` v0.12 solo retorna `access_token`, no `idToken`; Firebase necesita `idToken`, por lo que en web se usa `signInWithPopup` directamente |
| `AppColorsTheme` como extensión de `BuildContext` | Permite usar `context.acSurface` en lugar de lógica condicional en cada widget |
| Tests sin `bloc_test` | Conflicto de versiones entre `flutter_bloc ^9.0.0` y `bloc_test`; se usa `stream.take(n).toList()` como alternativa limpia |

---

*FlashMind — Proyecto Móvil 2 | Flutter + Firebase + Clean Architecture*
