<p align="center">
  <img src="docs/images/hero.png" alt="new_app — one production-ready Flutter app, five state-management architectures" width="100%">
</p>

<p align="center">
  <a href="https://github.com/mokinan/new_app/actions/workflows/ci.yml"><img src="https://github.com/mokinan/new_app/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <img src="https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter" alt="Flutter 3.44">
  <img src="https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart" alt="Dart 3.12">
  <img src="https://img.shields.io/badge/branches-5_architectures-6366f1" alt="5 architectures">
  <img src="https://img.shields.io/badge/journey_tests-15_shared-22c55e" alt="15 shared journey tests">
  <img src="https://img.shields.io/badge/license-MIT-64748b" alt="MIT license">
</p>

# new_app — one Flutter app, five state-management architectures

A production-ready starter (splash → onboarding → login/register → home, with token refresh,
session expiry, dark mode and RTL Arabic UI), implemented **five times** — once per state-management
approach. Every branch ships the same features, passes the **same 15 user-journey tests** and the same
on-device integration test, so the branches differ only in how state is managed.

> قالب Flutter جاهز لبدء أي مشروع: نفس التطبيق ونفس الاختبارات مُنفّذ بخمس طرق لإدارة الحالة.
> اختر البرانش المناسب لمشروعك وابدأ منه مباشرة.

## See it run

<table>
  <tr>
    <td width="30%" align="center"><img src="docs/images/journey.gif" alt="Onboarding, login, a server field error, then home in light and dark mode" width="260"></td>
    <td>

**The journey every branch implements — and tests:**

1. Splash decides where to go: home (saved session), login, or onboarding.
2. Onboarding slides load from the API, with a built-in fallback.
3. Login and register with client validation, server errors under the right field and double-submit protection.
4. Home, with dark mode persisted across launches.
5. A revoked refresh token signs the user out — the router moves them to login.

Runs offline out of the box against the built-in mock backend.

</td>
  </tr>
</table>

<img src="docs/images/phones.png" alt="Onboarding, login, registration with a server field error, home, home in dark mode" width="100%">

<details>
<summary><b>Tablet layout</b> — split brand panel and form</summary>
<br>
<img src="docs/images/tablet.png" alt="Login and registration on iPad" width="100%">
</details>

## Pick a branch

| Branch | State management | Navigation | DI | Tests |
|---|---|---|---|---|
| [`new_app_getx`](https://github.com/mokinan/new_app/tree/new_app_getx) | GetX — controllers, bindings, `Obx` | GetX routes + `GetMiddleware` guard | `Get.put` | 54 |
| [`new_app_cubit`](https://github.com/mokinan/new_app/tree/new_app_cubit) | `flutter_bloc` Cubit — methods → states | go_router, redirect on `SessionCubit` | `RepositoryProvider` | 65 |
| [`new_app_bloc`](https://github.com/mokinan/new_app/tree/new_app_bloc) | `flutter_bloc` Bloc — sealed events → states, `droppable()` | go_router, redirect on `SessionBloc` | `RepositoryProvider` | 65 |
| [`new_app_provider`](https://github.com/mokinan/new_app/tree/new_app_provider) | `provider` — `ChangeNotifier`, `context.watch` | go_router, redirect on `SessionNotifier` | `Provider` | 66 |
| [`new_app_riverpod`](https://github.com/mokinan/new_app/tree/new_app_riverpod) | Riverpod 3 — `Notifier`, `autoDispose`, `ref.listen` | go_router provider, redirect on `sessionProvider` | providers + `overrides` | 65 |

```bash
git clone -b new_app_riverpod https://github.com/mokinan/new_app.git my_app
cd my_app && flutter pub get && flutter run          # ENV=mock by default
# demo account: demo@app.com / Password1
```

### Which one?

- **Riverpod** — default choice for new projects: compile-safe DI, trivial test overrides, no `BuildContext` needed for logic.
- **Bloc** — large teams and regulated domains (fintech, ERP): explicit events give an audit trail and concurrency control per event.
- **Cubit** — Bloc's tooling and testability with less ceremony; good for most mid-sized apps.
- **Provider** — small apps or teams new to Flutter; closest to plain Flutter.
- **GetX** — maintaining existing GetX codebases; all-in-one routing, DI and state.

## What every branch shares (this branch)

`main` holds only the framework-agnostic core that all five branches build on — no state-management package:

```
lib/
├── core/
│   ├── config/        AppConfig — environment (mock/dev/staging/prod) from --dart-define=ENV
│   ├── network/       Dio client, single-flight token refresh, error → ApiException (Arabic messages)
│   │   └── mock/      MockBackend — a full fake API as an HttpClientAdapter (runs offline)
│   ├── services/      PreferencesService, StorageService (secure tokens behind SecureStore)
│   ├── startup/       decideStart() — where the app opens (home / login / welcome)
│   ├── theme/         colors, dimensions, text styles, light & dark themes
│   ├── utils/         validators (email, phone, password strength), device type
│   └── widgets/       auth layout (mobile/tablet), form fields, banners, onboarding widgets
└── data/
    ├── datasources/   AuthApi, OnboardingApi
    ├── models/        UserModel, AuthResponseModel, OnboardingSlideModel
    └── repositories/  AuthRepository, OnboardingRepository
```

Engineering rules applied in every branch:

- **Clean layering** — UI → state holder → repository → API; widgets never touch Dio or storage.
- **Navigation follows state** — signing in/out or a rejected refresh token moves the user via the router, not via screens calling `go`.
- **Form objects live in the widget** (`TextEditingController`, `FocusNode`); state holders keep only app state.
- **Double-submit protection**, server field errors shown under their fields, mounted/closed checks after every `await`.
- **Tests run the real stack** — real Dio, interceptors and repositories against the instant mock backend; only leaves are swapped.

## Environments

| `--dart-define=ENV=` | Backend | Network logs |
|---|---|---|
| `mock` (default) | in-app `MockBackend` | on |
| `development` / `staging` | real API (`AppConfig.baseUrl`) | on |
| `production` | real API | off |

## Quality gates (CI on every branch)

`dart format` · `flutter analyze --fatal-infos` (strict lints) · `flutter test` · `flutter build apk`.
Integration test: `flutter test integration_test -d <device>`.

---

Built by [Mohamed Kinan](https://github.com/mokinan) — Senior Flutter Engineer.
