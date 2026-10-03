import 'package:new_app/app/safe_change_notifier.dart';
import 'package:new_app/core/network/api_exception.dart';
import 'package:new_app/core/utils/validators.dart';
import 'package:new_app/data/repositories/auth_repository.dart';
import 'package:new_app/features/session/session_notifier.dart';

class RegisterNotifier extends SafeChangeNotifier {
  RegisterNotifier(this._auth, this._session);

  final AuthRepository _auth;
  final SessionNotifier _session;

  bool isLoading = false;
  String? error;

  /// Server-side field errors (e.g. email already taken), keyed by field.
  Map<String, String> fieldErrors = const {};
  int passwordStrength = 0;

  void passwordChanged(String password) {
    final strength = Validators.passwordStrength(password);
    if (strength == passwordStrength) return;
    passwordStrength = strength;
    notifyListeners();
  }

  void emailChanged() {
    if (!fieldErrors.containsKey('email')) return;
    fieldErrors = {...fieldErrors}..remove('email');
    notifyListeners();
  }

  Future<void> submit({
    required String businessName,
    required String ownerName,
    required String email,
    required String password,
    String? phone,
  }) async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    fieldErrors = const {};
    notifyListeners();
    try {
      final user = await _auth.register(
        name: ownerName,
        email: email,
        password: password,
        phone: (phone?.trim().isEmpty ?? true) ? null : phone,
        businessName: businessName,
      );
      _session.signedIn(user);
    } on ApiException catch (e) {
      error = e.message;
      fieldErrors = {for (final MapEntry(:key, :value) in e.fieldErrors.entries) key: value.first};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
