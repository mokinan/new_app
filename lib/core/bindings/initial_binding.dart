import 'package:get/get.dart';

/// Global dependencies registered here run after the ones in main.dart.
/// AppConfig and AuthService are already put in main.dart — add any
/// other app-wide services here (analytics, push notifications, etc.)
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Example: Get.put(AnalyticsService(), permanent: true);
  }
}
