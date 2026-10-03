import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that ignores `notifyListeners` after `dispose`.
///
/// Page notifiers await network calls; if the user leaves the page first,
/// the provider disposes the notifier and a late `notifyListeners` would
/// throw. Every notifier in this branch extends this class.
class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
