<p align="center">
  <a href="https://github.com/mokinan/new_app"><img src="https://raw.githubusercontent.com/mokinan/new_app/main/docs/images/hero.png" alt="new_app — one Flutter app, five state-management architectures" width="100%"></a>
</p>

# new_app — Riverpod

[← All branches and comparison](https://github.com/mokinan/new_app) · [Screenshots](https://github.com/mokinan/new_app#see-it-run)

A production-ready Flutter starter: Clean Architecture, Dio with token refresh,
secure storage, responsive layouts, Arabic RTL and a full test suite.
**This branch implements the state layer with Riverpod.**

The same app exists in one branch per state-management approach. Everything
outside the state layer is identical, so the branches double as a side-by-side
comparison.

| Branch | Approach | Stack |
|---|---|---|
| [`new_app_getx`](https://github.com/mokinan/new_app/tree/new_app_getx) | GetX | `get` — controllers, bindings, `Obx`, GetX routing |
| [`new_app_provider`](https://github.com/mokinan/new_app/tree/new_app_provider) | Provider | `provider` — `ChangeNotifier`, `context.watch`, go_router |
| **[`new_app_riverpod`](https://github.com/mokinan/new_app/tree/new_app_riverpod)** | Riverpod | `flutter_riverpod` 3 — `Notifier`s, `ref.watch`, go_router |
| [`new_app_bloc`](https://github.com/mokinan/new_app/tree/new_app_bloc) | Bloc | `flutter_bloc` — events → states, `BlocBuilder`, go_router |
| [`new_app_cubit`](https://github.com/mokinan/new_app/tree/new_app_cubit) | Cubit | `flutter_bloc` (Cubit) — methods → states, `BlocBuilder`, go_router |

## Run it

```bash
flutter pub get
flutter run                                  # ENV=mock: built-in fake backend, works offline
flutter run --dart-define=ENV=development    # dev / staging / production → AppConfig.baseUrl
```

Demo account (mock backend): **`demo@app.com`** / **`Password1`**

## How state flows here

View (`ref.watch`) → Notifier (immutable state) → Repository (provider)

```
lib/
├── main.dart                 ProviderScope(overrides: storage/prefs) → runApp
├── app/
│   ├── app.dart              MaterialApp.router (theme, locale from providers)
│   ├── providers.dart        core providers: config, prefs, storage, Dio, repositories
│   └── router.dart           go_router provider; redirect reads sessionProvider
└── features/
    ├── session/              SessionNotifier — signed-in user, logout, expiry
    ├── settings/             SettingsNotifier — theme and language (persisted)
    ├── splash/               startDestinationProvider (FutureProvider) + page
    ├── welcome/              WelcomeNotifier + page
    ├── login/                LoginNotifier + page
    ├── register/             RegisterNotifier + page
    └── home/                 page
```

- **Providers are the DI container.** Everything is a provider; tests swap implementations with `overrides`, no service locator.
- **Immutable state classes** with `copyWith`; notifiers replace `state`, never mutate it.
- **Auto-dispose for screens** (`NotifierProvider.autoDispose`): page state is discarded when the page closes.
- **Riverpod's automatic retry is disabled** in `ProviderScope` so failures surface to the UI instead of retrying silently.
- **`ref.listen`** handles one-off effects (navigation after splash and onboarding) without rebuilding; login needs none — the router redirect reacts to `sessionProvider`.

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

1. Create `lib/features/<name>/` with `<name>_notifier.dart` and `<name>_page.dart`.
2. Write an immutable state class and a `Notifier<State>`; expose it with `NotifierProvider.autoDispose`.
3. Read repositories with `ref.read(xRepositoryProvider)` inside the notifier.
4. Make the page a `ConsumerWidget` / `ConsumerStatefulWidget`; add a `GoRoute`.

## Tests

```bash
flutter test                                       # 65 tests
flutter test integration_test -d <device-id>       # full journey on a simulator/device
```

- `test/core`, `test/data` — shared core: validators, error mapping, single-flight refresh, repositories, startup routing.
- `test/app/app_flow_test.dart` — the **same user journeys in every branch**: start-up routing, onboarding, login (validation, wrong password, success), register (strength, mismatch, taken email, success), logout, dark mode, session expiry, deep-link guard.
- State-layer unit tests specific to Riverpod.

## Start a new project from this branch

```bash
git clone --branch new_app_riverpod --single-branch https://github.com/mokinan/new_app.git my_app
cd my_app && rm -rf .git && git init
# rename: `name:` in pubspec.yaml, package imports, Android applicationId, iOS bundle id
```

Then point `AppConfig.baseUrl` at your API, keep `ENV=mock` for UI work, and
replace `MockBackend` routes as real endpoints become available.
