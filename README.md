<p align="center">
  <a href="https://github.com/mokinan/new_app"><img src="https://raw.githubusercontent.com/mokinan/new_app/main/docs/images/hero.png" alt="new_app — one Flutter app, five state-management architectures" width="100%"></a>
</p>

# new_app — Cubit

[← All branches and comparison](https://github.com/mokinan/new_app) · [Screenshots](https://github.com/mokinan/new_app#see-it-run)

A production-ready Flutter starter: Clean Architecture, Dio with token refresh,
secure storage, responsive layouts, Arabic RTL and a full test suite.
**This branch implements the state layer with Cubit.**

The same app exists in one branch per state-management approach. Everything
outside the state layer is identical, so the branches double as a side-by-side
comparison.

| Branch | Approach | Stack |
|---|---|---|
| [`new_app_getx`](https://github.com/mokinan/new_app/tree/new_app_getx) | GetX | `get` — controllers, bindings, `Obx`, GetX routing |
| [`new_app_provider`](https://github.com/mokinan/new_app/tree/new_app_provider) | Provider | `provider` — `ChangeNotifier`, `context.watch`, go_router |
| [`new_app_riverpod`](https://github.com/mokinan/new_app/tree/new_app_riverpod) | Riverpod | `flutter_riverpod` 3 — `Notifier`s, `ref.watch`, go_router |
| [`new_app_bloc`](https://github.com/mokinan/new_app/tree/new_app_bloc) | Bloc | `flutter_bloc` — events → states, `BlocBuilder`, go_router |
| **[`new_app_cubit`](https://github.com/mokinan/new_app/tree/new_app_cubit)** | Cubit | `flutter_bloc` (Cubit) — methods → states, `BlocBuilder`, go_router |

## Run it

```bash
flutter pub get
flutter run                                  # ENV=mock: built-in fake backend, works offline
flutter run --dart-define=ENV=development    # dev / staging / production → AppConfig.baseUrl
```

Demo account (mock backend): **`demo@app.com`** / **`Password1`**

## How state flows here

View → method call → Cubit → State → View (`BlocBuilder` / `BlocListener`)

```
lib/
├── main.dart                 AppDependencies.create() → runApp
├── app/
│   ├── app.dart              MultiRepositoryProvider + MultiBlocProvider + MaterialApp.router
│   ├── dependencies.dart     composition root: builds config, storage, Dio, repositories
│   └── router.dart           go_router; redirect driven by SessionCubit
└── features/
    ├── session/              SessionCubit — signed-in user, logout, expiry
    ├── settings/             SettingsCubit — theme, language, onboarding flag
    ├── splash/               SplashCubit + page
    ├── welcome/              WelcomeCubit + page
    ├── login/                LoginCubit + page
    ├── register/             RegisterCubit + page
    └── home/                 page
```

- **Bloc without events**: public methods emit new states. Less ceremony than Bloc, same widgets and testing tools.
- **Immutable states** with `copyWith` (`equatable` for value equality, so identical states don't rebuild).
- **Side effects in `BlocListener`** (navigation, snackbars); rendering in `BlocBuilder` with `buildWhen`.
- **Guard double submits** inside the method (`if (state.isLoading) return;`).
- **When to switch to the Bloc branch**: when you need event transformers (debounce, restartable, droppable) or a full event log.

## Shared core (identical in every branch)

```
lib/core/
├── config/        AppConfig — environment, base URLs, flags, splash delay (no framework)
├── network/       DioClient · AuthInterceptor (single-flight refresh) · ErrorInterceptor → ApiException
│   └── mock/      MockBackend — fake API at the adapter level; interceptors run for real
├── services/      StorageService (Keychain/Keystore + prefs) · PreferencesService
├── startup/       decideStart() — the splash routing rule
├── theme/         colors, dimensions, text styles, light/dark themes
├── utils/         Validators (pure functions) · DeviceType
└── widgets/       AppTextField · AuthLayout · ErrorBanner · LoadingButton · onboarding widgets
lib/data/
├── datasources/   AuthApi · OnboardingApi (Dio → models, throw ApiException)
├── models/        UserModel · AuthResponseModel · OnboardingSlideModel
└── repositories/  AuthRepository (login/register/restore/logout) · OnboardingRepository (with fallback)
```

- **Errors are data, not UI.** `ErrorInterceptor` converts every failure into a typed `ApiException` with an Arabic message; each branch decides how to show it.
- **Token refresh is single-flight**: concurrent 401s share one refresh, then replay. A rejected refresh token ends the session; a network blip does not.
- **No global singletons.** `Dio`, storage and repositories are built once in the composition root and injected, so tests construct their own.

## Add a feature

1. Create `lib/features/<name>/` with `<name>_state.dart`, `<name>_cubit.dart`, `<name>_page.dart`.
2. Give the cubit repository dependencies through its constructor; emit `state.copyWith(...)`.
3. Provide it at the page with `BlocProvider(create: ...)`; add a `GoRoute`.
4. Test with `blocTest(build:, act: (c) => c.method(), expect:)`.

## Tests

```bash
flutter test                                       # 65 tests
flutter test integration_test -d <device-id>       # full journey on a simulator/device
```

- `test/core`, `test/data` — shared core: validators, error mapping, single-flight refresh, repositories, startup routing.
- `test/app/app_flow_test.dart` — the **same user journeys in every branch**: start-up routing, onboarding, login (validation, wrong password, success), register (strength, mismatch, taken email, success), logout, dark mode, session expiry, deep-link guard.
- State-layer unit tests specific to Cubit.

## Start a new project from this branch

```bash
git clone --branch new_app_cubit --single-branch https://github.com/mokinan/new_app.git my_app
cd my_app && rm -rf .git && git init
# rename: `name:` in pubspec.yaml, package imports, Android applicationId, iOS bundle id
```

Then point `AppConfig.baseUrl` at your API, keep `ENV=mock` for UI work, and
replace `MockBackend` routes as real endpoints become available.
