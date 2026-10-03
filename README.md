# Flutter Boilerplate — Clean Architecture + GetX + Dio

قالب احترافي جاهز لأي تطبيق Flutter. يدعم الموبايل والتابليت والويب والماك والويندوز والتلفاز.

---

## هيكل المشروع

```
lib/
├── main.dart                          ← نقطة الدخول
├── app/
│   ├── app.dart                       ← GetMaterialApp + Themes + Responsive
│   └── routes/
│       ├── app_routes.dart            ← أسماء المسارات (String constants)
│       └── app_pages.dart             ← ربط كل route بـ View + Binding
│
├── core/
│   ├── config/
│   │   └── app_config.dart            ← إعدادات التطبيق (بيئة / ثيم / لغة / onboarding)
│   ├── theme/
│   │   ├── app_colors.dart            ← كل الألوان
│   │   ├── app_dimensions.dart        ← المسافات والأحجام و Breakpoints
│   │   ├── app_text_styles.dart       ← أنماط النصوص
│   │   └── app_theme.dart             ← Light Theme + Dark Theme
│   ├── network/
│   │   ├── dio_client.dart            ← Dio singleton جاهز للاستخدام
│   │   ├── api_endpoints.dart         ← ثوابت الـ endpoints
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart  ← إضافة Bearer token تلقائياً
│   │       └── error_interceptor.dart ← معالجة كل أكواد HTTP + Snackbar
│   ├── utils/
│   │   └── device_type.dart           ← كشف نوع الجهاز (Watch/Mobile/Tablet/Desktop/TV)
│   ├── widgets/
│   │   └── responsive_builder.dart    ← Widget يبني layout مختلف لكل شاشة
│   └── bindings/
│       └── initial_binding.dart       ← تسجيل الـ dependencies العامة
│
├── features/
│   ├── splash/                        ← شاشة التحميل → تنتقل تلقائياً
│   ├── welcome/                       ← شاشة الترحيب (3 صفحات + dots + زر)
│   └── home/                          ← Placeholder — استبدله بـ Home الفعلية
│
└── data/
    ├── models/                        ← نماذج البيانات
    ├── repositories/                  ← طبقة Repository (الـ Use Cases)
    └── providers/                     ← طبقة Provider (Dio calls مباشرة)

assets/
├── images/    ← صور التطبيق (.png / .jpg / .webp)
├── icons/     ← أيقونات SVG
└── animations/ ← ملفات Lottie (.json)
```

---

## عند البدء في تطبيق جديد

### 1. تغيير اسم التطبيق والـ tagline
```dart
// lib/core/config/app_config.dart
String appName = 'YourAppName';

// lib/features/splash/views/splash_view.dart
Text('YourAppName', ...)
Text('Your tagline here', ...)

// lib/app/app.dart
title: 'YourAppName',
```

### 2. تغيير الألوان الرئيسية
```dart
// lib/core/theme/app_colors.dart
static const Color primary   = Color(0xFFXXXXXX); // لونك الرئيسي
static const Color secondary = Color(0xFFXXXXXX); // اللون الثانوي
```

### 3. إضافة خط مخصص
1. أضف ملفات الخط في `assets/fonts/`
2. في `pubspec.yaml` أزل التعليق عن قسم `fonts`
3. في `lib/core/theme/app_text_styles.dart`:
```dart
static const String? _fontFamily = 'YourFontName'; // بدل null
```

### 4. ضبط بيئة API
```dart
// lib/main.dart
Get.put(AppConfig(environment: AppEnvironment.production), permanent: true);

// lib/core/config/app_config.dart
case AppEnvironment.production:
  return 'https://api.yourdomain.com/v1';
```

### 5. إضافة شاشة جديدة

أنشئ المجلد بنفس الهيكل:
```
lib/features/your_feature/
├── bindings/your_feature_binding.dart
├── controllers/your_feature_controller.dart
└── views/your_feature_view.dart
```

ثم سجّلها في `app_routes.dart` و `app_pages.dart`:
```dart
// app_routes.dart
static const yourFeature = '/your-feature';

// app_pages.dart
GetPage(
  name: AppRoutes.yourFeature,
  page: () => const YourFeatureView(),
  binding: YourFeatureBinding(),
),
```

### 6. استدعاء API
```dart
// lib/data/providers/your_provider.dart
class YourProvider {
  final _dio = DioClient.instance;

  Future<Response> getItems() => _dio.get(ApiEndpoints.items);
}

// lib/data/repositories/your_repository.dart
class YourRepository {
  final _provider = YourProvider();

  Future<List<YourModel>> getItems() async {
    final res = await _provider.getItems();
    return (res.data as List).map((e) => YourModel.fromJson(e)).toList();
  }
}

// lib/features/your_feature/controllers/your_controller.dart
class YourController extends GetxController {
  final _repo = YourRepository();
  final items      = <YourModel>[].obs;
  final isLoading  = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading.value = true;
    try {
      items.value = await _repo.getItems();
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## Responsive Design

```dart
// Layout مختلف لكل شاشة
ResponsiveBuilder(
  mobile:  (ctx, _) => MobileLayout(),   // < 600px  — إلزامي
  tablet:  (ctx, _) => TabletLayout(),   // 600–899px
  desktop: (ctx, _) => DesktopLayout(),  // 900–1199px
  tv:      (ctx, _) => TvLayout(),       // 1920px+
)

// قيم مختلفة حسب الشاشة
final padding = Responsive(
  mobile:  16.0,
  tablet:  24.0,
  desktop: 32.0,
).resolve(context);

// Extension على BuildContext
if (context.isMobile)  { /* موبايل   */ }
if (context.isTablet)  { /* تابليت   */ }
if (context.isDesktop) { /* ديسكتوب  */ }
if (context.isTv)      { /* تلفاز    */ }
```

---

## معالجة أخطاء API (ErrorInterceptor)

الـ interceptor يعالج تلقائياً كل أكواد HTTP ويعرض Snackbar ملوّن بأيقونة مناسبة:

| الكود | النوع | الرسالة الافتراضية |
|-------|-------|--------------------|
| `0` | No Connection | No internet connection |
| `400` | Bad Request | Invalid request. Please check your input |
| `401` | Unauthorized | Session expired. Please log in again |
| `403` | Forbidden | You don't have permission to do this |
| `404` | Not Found | The requested resource was not found |
| `408/504` | Timeout | Request timed out |
| `409` | Conflict | A conflict occurred. Please try again |
| `422` | Validation | Validation failed. Check your data |
| `429` | Rate Limited | Too many requests. Please slow down |
| `500` | Server Error | Server error. We're working on it |
| `503` | Unavailable | Service is temporarily unavailable |

إذا أرسل الـ backend رسالة في `response.data['message']` فستُعرض بدل الرسالة الافتراضية.

لإضافة كود خاص:
```dart
// في error_interceptor.dart — داخل دالة _parseHttpStatus()
418 => ('Custom message here', ApiErrorType.unknown),
```

---

## AppConfig — الإعدادات الـ Reactive

```dart
final config = AppConfig.to;

// قراءة (reactive — يمكن استخدامها داخل Obx)
config.isDarkMode    // bool
config.locale        // 'en' | 'ar' | ...
config.isOnboarded   // bool — هل أكمل المستخدم الـ onboarding؟
config.baseUrl       // URL يتغير حسب AppEnvironment
config.appVersion    // '1.0.0'
config.showDebugBanner // true في dev فقط

// تغيير (يحفظ في SharedPreferences ويُحدّث الـ UI فوراً)
await config.setDarkMode(true);   // تفعيل الثيم الداكن
await config.setLocale('ar');     // تغيير اللغة
await config.setOnboarded(true);  // إنهاء الـ onboarding
```

---

## الحزم المستخدمة

| الحزمة | الغرض |
|--------|--------|
| `get` | State management + Navigation + DI |
| `dio` | HTTP client |
| `shared_preferences` | تخزين الإعدادات |
| `flutter_secure_storage` | تخزين التوكن بأمان |
| `responsive_framework` | Responsive breakpoints |
| `flutter_screenutil` | تحجيم عناصر الـ UI |
| `flutter_svg` | أيقونات SVG |
| `cached_network_image` | تحميل الصور مع cache |
| `lottie` | أنيميشن Lottie |
| `shimmer` | Loading skeleton |
| `connectivity_plus` | كشف حالة الاتصال |
| `package_info_plus` | معلومات التطبيق (version, name) |
| `logger` | تسجيل منسّق في الـ console |

---

## ملاحظات

- **Apple Watch**: Flutter لا يدعم watchOS رسمياً. عند توفر الدعم، أضف `watch` layout في `ResponsiveBuilder`.
- **TV**: مدعوم عبر Android TV. أضف `tv` layout في `ResponsiveBuilder` للشاشات ≥ 1920px.
- **الخطوط**: معطّل افتراضياً. أضف ملفاتك في `assets/fonts/` وفعّل القسم في `pubspec.yaml`.
- **Debug banner**: يظهر في `development` ويختفي تلقائياً في `production`.
- **Home route**: `features/home/` هو placeholder — استبدل `HomeView` بالـ layout الفعلي لتطبيقك.
