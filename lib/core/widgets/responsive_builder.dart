import 'package:flutter/material.dart';
import 'package:new_app/core/utils/device_type.dart';

/// Builds different layouts based on screen size.
/// Falls back to the next smaller layout if a specific one is not provided.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.mobile, this.watch, this.tablet, this.desktop, this.tv});

  final Widget Function(BuildContext, BoxConstraints) mobile;
  final Widget Function(BuildContext, BoxConstraints)? watch;
  final Widget Function(BuildContext, BoxConstraints)? tablet;
  final Widget Function(BuildContext, BoxConstraints)? desktop;
  final Widget Function(BuildContext, BoxConstraints)? tv;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final device = DeviceTypeHelper.fromWidth(constraints.maxWidth);
        return switch (device) {
          DeviceType.tv => (tv ?? desktop ?? tablet ?? mobile)(ctx, constraints),
          DeviceType.desktop => (desktop ?? tablet ?? mobile)(ctx, constraints),
          DeviceType.tablet => (tablet ?? mobile)(ctx, constraints),
          DeviceType.watch => (watch ?? mobile)(ctx, constraints),
          DeviceType.mobile => mobile(ctx, constraints),
        };
      },
    );
  }
}

/// Simple responsive value — returns different values per breakpoint.
class Responsive<T> {
  const Responsive({required this.mobile, this.watch, this.tablet, this.desktop, this.tv});

  final T mobile;
  final T? watch;
  final T? tablet;
  final T? desktop;
  final T? tv;

  T resolve(BuildContext context) {
    final device = DeviceTypeHelper.of(context);
    return switch (device) {
      DeviceType.tv => tv ?? desktop ?? tablet ?? mobile,
      DeviceType.desktop => desktop ?? tablet ?? mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.watch => watch ?? mobile,
      DeviceType.mobile => mobile,
    };
  }
}

/// Shorthand for getting the current [DeviceType] from context.
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => DeviceTypeHelper.of(this);
  bool get isMobile => deviceType.isMobile;
  bool get isTablet => deviceType.isTablet;
  bool get isDesktop => deviceType.isDesktop;
  bool get isTv => deviceType.isTv;
  bool get isCompact => deviceType.isCompact;
  bool get isExpanded => deviceType.isExpanded;
}
