import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

enum DeviceType { watch, mobile, tablet, desktop, tv }

class DeviceTypeHelper {
  static DeviceType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return fromWidth(width);
  }

  static DeviceType fromWidth(double width) {
    if (width < AppDimensions.watchBreakpoint)   return DeviceType.watch;
    if (width < AppDimensions.mobileBreakpoint)  return DeviceType.mobile;
    if (width < AppDimensions.tabletBreakpoint)  return DeviceType.tablet;
    if (width < AppDimensions.tvBreakpoint)      return DeviceType.desktop;
    return DeviceType.tv;
  }
}

extension DeviceTypeX on DeviceType {
  bool get isWatch   => this == DeviceType.watch;
  bool get isMobile  => this == DeviceType.mobile;
  bool get isTablet  => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop;
  bool get isTv      => this == DeviceType.tv;
  bool get isCompact => isMobile || isWatch;
  bool get isExpanded => isTablet || isDesktop || isTv;
}
