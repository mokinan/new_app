import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

/// Runs [listener] for side effects (navigation, snackbars) whenever the
/// provided [T] notifies — Provider's counterpart to `BlocListener`.
///
/// Side effects must never run inside `build`; this widget keeps them in a
/// listener registered once for its lifetime.
class NotifierListener<T extends ChangeNotifier> extends StatefulWidget {
  const NotifierListener({required this.listener, required this.child, super.key});

  final void Function(BuildContext context, T notifier) listener;
  final Widget child;

  @override
  State<NotifierListener<T>> createState() => _NotifierListenerState<T>();
}

class _NotifierListenerState<T extends ChangeNotifier> extends State<NotifierListener<T>> {
  late final T _notifier = context.read<T>();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) widget.listener(context, _notifier);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
