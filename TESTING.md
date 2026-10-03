# دليل التيست الشامل

---

## فهرس المحتويات

1. [هيكل مجلدات التيست](#هيكل-مجلدات-التيست)
2. [أوامر التشغيل](#أوامر-التشغيل)
3. [أنواع التيستات](#أنواع-التيستات)
4. [الـ Helpers المشتركة](#الـ-helpers-المشتركة)
5. [كيف تكتب تيست لـ Controller جديد](#كيف-تكتب-تيست-لـ-controller-جديد)
6. [كيف تكتب تيست لـ Repository جديد](#كيف-تكتب-تيست-لـ-repository-جديد)
7. [كيف تكتب Widget Test](#كيف-تكتب-widget-test)
8. [الـ Fixtures](#الـ-fixtures)
9. [قواعد مهمة مكتسبة](#قواعد-مهمة-مكتسبة)
10. [Coverage](#coverage)

---

## هيكل مجلدات التيست

```
test/
│
├── helpers/                         ← أدوات مشتركة بين كل التيستات
│   ├── test_helpers.dart            ← setupGetX + pumpApp + testableWidget
│   ├── mock_app_config.dart         ← MockAppConfig + FakeAppConfig
│   └── mock_repository_template.dart← نموذج لعمل Mock لأي Repository جديد
│
├── fixtures/
│   └── fixtures.dart                ← بيانات JSON ثابتة للتيستات
│
├── core/
│   ├── config/
│   │   └── app_config_test.dart     ← تيست AppConfig (URLs, flags, defaults)
│   ├── network/
│   │   └── error_interceptor_test.dart ← تيست كل أكواد HTTP
│   └── utils/
│       └── device_type_test.dart    ← تيست Breakpoints والـ DeviceType
│
├── features/
│   ├── splash/
│   │   └── splash_controller_test.dart ← تيست منطق الـ navigation
│   └── welcome/
│       └── welcome_controller_test.dart← تيست الـ Onboarding state
│
└── widget_tests/
    ├── splash_view_test.dart        ← تيست UI الـ Splash
    └── welcome_view_test.dart       ← تيست UI الـ Welcome + التفاعل

integration_test/
└── app_flow_test.dart               ← تيست تدفق التطبيق الكامل على جهاز حقيقي
```

---

## أوامر التشغيل

```bash
# ─── كل التيستات دفعة واحدة ──────────────────────────────────
flutter test

# ─── مجلد محدد ───────────────────────────────────────────────
flutter test test/core/
flutter test test/features/
flutter test test/widget_tests/

# ─── ملف واحد ────────────────────────────────────────────────
flutter test test/core/network/error_interceptor_test.dart

# ─── تيست واحد بالاسم ────────────────────────────────────────
flutter test --name "AppConfig — baseUrl per environment"

# ─── مع تقرير مفصّل ──────────────────────────────────────────
flutter test --reporter=expanded

# ─── مع Coverage (يُنتج lcov.info) ────────────────────────────
flutter test --coverage

# ─── فتح تقرير Coverage في المتصفح (يحتاج lcov مُثبَّت) ─────
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# ─── Integration tests (يحتاج جهاز أو محاكي) ────────────────
flutter test integration_test/ -d emulator-5554
flutter test integration_test/ -d chrome        # ويب
flutter test integration_test/ -d macos         # ماك
```

---

## أنواع التيستات

### Unit Tests — `test()`
تختبر وحدة منفردة (function, class) بمعزل تام عن الـ UI والأجهزة.

```dart
test('وصف التيست', () {
  // Arrange
  final config = AppConfig(environment: AppEnvironment.production);

  // Act + Assert
  expect(config.enableAnalytics, isTrue);
});
```

**متى تستخدمها:** Controllers، Repositories، Models، Utils، Interceptors.

---

### Widget Tests — `testWidgets()`
تختبر شاشة أو Widget داخل بيئة Flutter افتراضية (لا جهاز حقيقي).

```dart
testWidgets('وصف التيست', (tester) async {
  await pumpApp(tester, const MyView());

  expect(find.text('Hello'), findsOneWidget);
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  expect(find.text('Done'), findsOneWidget);
});
```

**متى تستخدمها:** Views، Widgets المخصصة، التفاعل (tap, scroll, input).

---

### Integration Tests — في `integration_test/`
تختبر التدفق الكامل للتطبيق على جهاز حقيقي أو محاكي.

```dart
testWidgets('splash → welcome', (tester) async {
  await tester.pumpWidget(const App());
  expect(find.text('AppName'), findsOneWidget);
  await tester.pump(const Duration(seconds: 3));
  expect(find.text('Continue'), findsOneWidget);
});
```

**متى تستخدمها:** تدفقات المستخدم الكاملة، اختبار الـ navigation، التأكد من أن الشاشات تتكامل صح.

---

## الـ Helpers المشتركة

```dart
import 'package:your_package/test/helpers/test_helpers.dart';
```

### `setupGetX()`
يجب استدعاؤه في `setUp()` في **كل** ملف تيست.
- يعيد ضبط GetX state بين التيستات
- يُهيّئ SharedPreferences بقيم فارغة (منع `MissingPluginException`)

```dart
setUp(() {
  setupGetX();             // إلزامي دائماً
  setupAppConfig();        // أضفه إذا احتجت AppConfig
});
```

---

### `setupAppConfig({environment})`
يسجّل `AppConfig` في GetX ويعيده لاستخدامه مباشرة.

```dart
final config = setupAppConfig(environment: AppEnvironment.production);
expect(config.enableAnalytics, isTrue);
```

---

### `pumpApp(tester, widget, {pump, screenSize})`

```dart
// افتراضي: mobile size (390×844) + pumpAndSettle
await pumpApp(tester, const MyView());

// لـ Views تحتوي CircularProgressIndicator (infinite animation)
await pumpApp(tester, const SplashView(), pump: Duration(milliseconds: 100));

// لاختبار Tablet layout
await pumpApp(tester, const MyView(), screenSize: Size(768, 1024));

// لاختبار Desktop layout
await pumpApp(tester, const MyView(), screenSize: Size(1440, 900));
```

> **لماذا mobile size افتراضياً؟**
> بيئة التيست تستخدم 800×600 بشكل افتراضي، وهذا يُفعّل Tablet layout في `ResponsiveBuilder`.
> وضعنا 390×844 (iPhone 14 Pro) كافتراضي حتى تعمل التيستات على Mobile layout دائماً ما لم تحدد غير ذلك.

---

### `testableWidget(widget)`
يُغلّف الـ widget في `GetMaterialApp` مع الـ theme بدون حجم محدد.

```dart
await tester.pumpWidget(testableWidget(const MySplashView()));
await tester.pump(); // frame واحد فقط — لا pumpAndSettle
```

---

## كيف تكتب تيست لـ Controller جديد

**مثال: `ProfileController`**

```dart
// test/features/profile/profile_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:new_app/data/repositories/profile_repository.dart';
import 'package:new_app/features/profile/controllers/profile_controller.dart';
import '../../helpers/test_helpers.dart';
import '../../fixtures/fixtures.dart';

// 1. أنشئ Mock للـ Repository
class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ProfileController controller;
  late MockProfileRepository mockRepo;

  setUp(() {
    setupGetX();           // إلزامي
    setupAppConfig();      // إذا كان Controller يقرأ AppConfig

    mockRepo = MockProfileRepository();
    Get.put<ProfileRepository>(mockRepo);  // سجّل الـ mock في GetX
    controller = Get.put(ProfileController());
  });

  group('ProfileController — fetchProfile', () {
    test('sets user data on success', () async {
      // Arrange: حدّد ما يعيده الـ mock
      when(() => mockRepo.getProfile()).thenAnswer(
        (_) async => UserModel.fromJson(Fixtures.userProfile),
      );

      // Act
      await controller.fetchProfile();

      // Assert
      expect(controller.user.value?.name, equals('John Doe'));
      expect(controller.isLoading.value, isFalse);
      verify(() => mockRepo.getProfile()).called(1);
    });

    test('shows error state on failure', () async {
      when(() => mockRepo.getProfile()).thenThrow(Exception('Network error'));

      await controller.fetchProfile();

      expect(controller.user.value, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    test('isLoading is true during fetch', () async {
      when(() => mockRepo.getProfile()).thenAnswer(
        (_) async {
          // تحقق من isLoading داخل العملية نفسها
          expect(controller.isLoading.value, isTrue);
          return UserModel.fromJson(Fixtures.userProfile);
        },
      );

      await controller.fetchProfile();
    });
  });
}
```

---

## كيف تكتب تيست لـ Repository جديد

```dart
// test/data/repositories/profile_repository_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:new_app/core/network/api_endpoints.dart';
import 'package:new_app/data/providers/profile_provider.dart';
import 'package:new_app/data/repositories/profile_repository.dart';
import '../../helpers/test_helpers.dart';
import '../../fixtures/fixtures.dart';

class MockProfileProvider extends Mock implements ProfileProvider {}

void main() {
  late ProfileRepository repo;
  late MockProfileProvider mockProvider;

  setUp(() {
    setupGetX();
    mockProvider = MockProfileProvider();
    repo = ProfileRepository(provider: mockProvider);
  });

  group('ProfileRepository — getProfile', () {
    test('returns UserModel on 200', () async {
      when(() => mockProvider.getProfile()).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.profile),
          statusCode: 200,
          data: Fixtures.userProfile,
        ),
      );

      final result = await repo.getProfile();
      expect(result.email, equals('john@example.com'));
    });

    test('propagates exception on network error', () async {
      when(() => mockProvider.getProfile()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.profile),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(() => repo.getProfile(), throwsA(isA<DioException>()));
    });
  });
}
```

---

## كيف تكتب Widget Test

```dart
// test/widget_tests/profile_view_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_app/features/profile/bindings/profile_binding.dart';
import 'package:new_app/features/profile/views/profile_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUp(() {
    setupGetX();
    setupAppConfig();
    ProfileBinding().dependencies();
  });

  group('ProfileView — rendering', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      // pump(duration) بدل pumpAndSettle إذا في infinite animation
      await pumpApp(tester, const ProfileView(), pump: Duration(milliseconds: 100));
      // أو pumpAndSettle إذا كل الـ animations تنتهي
      await pumpApp(tester, const ProfileView());
    });

    testWidgets('shows user name after load', (tester) async {
      // اضبط state مسبقاً
      final ctrl = Get.find<ProfileController>();
      ctrl.user.value = UserModel(name: 'John', email: 'j@j.com');

      await pumpApp(tester, const ProfileView());
      expect(find.text('John'), findsOneWidget);
    });
  });

  group('ProfileView — Tablet layout', () {
    testWidgets('shows two-column layout on tablet', (tester) async {
      await pumpApp(
        tester,
        const ProfileView(),
        screenSize: const Size(768, 1024), // ← Tablet size
      );
      expect(find.byType(Row), findsWidgets);
    });
  });
}
```

---

## الـ Fixtures

ملف واحد مركزي لكل بيانات التيست.

```dart
// test/fixtures/fixtures.dart

// استخدام جاهز:
Fixtures.userProfile        // Map<String, dynamic>
Fixtures.userList           // List<Map<String, dynamic>>
Fixtures.loginSuccess       // { access_token, refresh_token, expires_in }
Fixtures.loginError400      // { message, code }
Fixtures.serverError('msg') // { message, code }
Fixtures.validationError({'email': ['required']})
Fixtures.paginatedResponse(data: [...], page: 1, total: 50)
```

### إضافة Fixture جديد
```dart
// في test/fixtures/fixtures.dart أضف getter جديد:

static Map<String, dynamic> get productItem => {
  'id': '1',
  'name': 'iPhone 15',
  'price': 999.0,
  'in_stock': true,
};

static List<Map<String, dynamic>> get productList => [
  productItem,
  {'id': '2', 'name': 'MacBook Pro', 'price': 2499.0, 'in_stock': false},
];
```

---

## قواعد مهمة مكتسبة

### 1. `CircularProgressIndicator` يوقف `pumpAndSettle`
```dart
// ❌ يتجمّد لأن CircularProgressIndicator لانهائي
await pumpApp(tester, const SplashView());

// ✅ استخدم pump بمدة محددة
await pumpApp(tester, const SplashView(), pump: Duration(milliseconds: 100));
```

### 2. `PageView.nextPage()` لا يعمل بشكل موثوق في التيستات
```dart
// ❌ PageView scroll physics لا تنطلق في headless environment
await tester.tap(find.text('Continue'));
await tester.pumpAndSettle(); // قد يفشل

// ✅ ادفع الـ controller مباشرة لاختبار الـ reactive state
final ctrl = Get.find<WelcomeController>();
ctrl.onPageChanged(2); // آخر صفحة مباشرة
await tester.pump();
expect(find.text('Get Started'), findsOneWidget);
```

### 3. `Get.context` في unit tests يرمي Exception
```dart
// ❌ هذا يرمي "Binding has not yet been initialized"
if (Get.context == null) return;

// ✅ استخدم try-catch
try {
  if (Get.context == null) return;
  Get.snackbar(...);
} catch (_) {
  // no UI binding in unit tests
}
```

### 4. `SharedPreferences` يحتاج mock في التيستات
```dart
// ❌ بدون mock → MissingPluginException
setUp(() { setupGetX(); });

// ✅ setupGetX يستدعي setMockInitialValues تلقائياً
setUp(() { setupGetX(); }); // يتضمن SharedPreferences.setMockInitialValues({})
```

### 5. `ResponsiveBuilder` يختار Tablet في التيستات بالحجم الافتراضي
```dart
// ❌ بيئة التيست: 800×600 → Tablet layout
await pumpApp(tester, const WelcomeView());

// ✅ pumpApp يضبط 390×844 افتراضياً → Mobile layout
await pumpApp(tester, const WelcomeView());

// ✅ أو صرّح بالحجم الذي تريده
await pumpApp(tester, const WelcomeView(), screenSize: Size(768, 1024));
```

### 6. `Get.reset()` إلزامي بين التيستات
```dart
// بدونه تتسرب الـ dependencies بين التيستات
setUp(() {
  setupGetX(); // يستدعي Get.reset() داخلياً
});
```

---

## Coverage

```bash
# 1. شغّل التيستات مع Coverage
flutter test --coverage

# 2. افتح التقرير
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### أهداف Coverage الموصى بها

| الطبقة | الحد الأدنى |
|--------|-------------|
| Core (config, network, utils) | 90% |
| Controllers | 80% |
| Repositories | 85% |
| Views (widget tests) | 70% |
| Models | 95% |

### استثناء ملفات من Coverage
```yaml
# pubspec.yaml — أضف في قسم flutter
# أو أنشئ ملف coverage/.coveragerc
```

أو أضف في رأس أي ملف:
```dart
// coverage:ignore-file     ← استثن الملف كله
// coverage:ignore-line     ← استثن السطر التالي
// coverage:ignore-start    ← ابدأ استثناء
// coverage:ignore-end      ← أنهِ الاستثناء
```

---

## خلاصة — قائمة تحقق عند إضافة Feature جديدة

```
□ أنشأت test/features/<feature>/controller_test.dart
□ أنشأت test/data/repositories/<feature>_repository_test.dart  (إذا وجد)
□ أنشأت test/widget_tests/<feature>_view_test.dart
□ أضفت fixtures جديدة في test/fixtures/fixtures.dart
□ أنشأت test/helpers/mock_<feature>_repository.dart
□ كل تيست يبدأ بـ setUp(() { setupGetX(); })
□ استخدمت pumpApp مع pump: Duration إذا في infinite animation
□ شغّلت flutter test وكلها خضراء
```
