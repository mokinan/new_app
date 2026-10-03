import 'package:flutter_test/flutter_test.dart';
import 'package:new_app/core/theme/app_dimensions.dart';
import 'package:new_app/core/utils/device_type.dart';

void main() {
  group('DeviceTypeHelper.fromWidth', () {
    test('below watchBreakpoint → watch', () {
      expect(DeviceTypeHelper.fromWidth(AppDimensions.watchBreakpoint - 1), DeviceType.watch);
    });

    test('at mobileBreakpoint boundary → mobile', () {
      expect(DeviceTypeHelper.fromWidth(AppDimensions.watchBreakpoint), DeviceType.mobile);
      expect(DeviceTypeHelper.fromWidth(AppDimensions.mobileBreakpoint - 1), DeviceType.mobile);
    });

    test('at tabletBreakpoint boundary → tablet', () {
      expect(DeviceTypeHelper.fromWidth(AppDimensions.mobileBreakpoint), DeviceType.tablet);
      expect(DeviceTypeHelper.fromWidth(AppDimensions.tabletBreakpoint - 1), DeviceType.tablet);
    });

    test('desktop range → desktop', () {
      expect(DeviceTypeHelper.fromWidth(AppDimensions.tabletBreakpoint), DeviceType.desktop);
      expect(DeviceTypeHelper.fromWidth(AppDimensions.tvBreakpoint - 1), DeviceType.desktop);
    });

    test('at tvBreakpoint and above → tv', () {
      expect(DeviceTypeHelper.fromWidth(AppDimensions.tvBreakpoint), DeviceType.tv);
      expect(DeviceTypeHelper.fromWidth(3840), DeviceType.tv);
    });
  });

  group('DeviceTypeX extensions', () {
    test('mobile.isCompact is true', () {
      expect(DeviceType.mobile.isCompact, isTrue);
      expect(DeviceType.watch.isCompact, isTrue);
    });

    test('tablet.isExpanded is true', () {
      expect(DeviceType.tablet.isExpanded, isTrue);
      expect(DeviceType.desktop.isExpanded, isTrue);
      expect(DeviceType.tv.isExpanded, isTrue);
    });

    test('mobile.isExpanded is false', () {
      expect(DeviceType.mobile.isExpanded, isFalse);
    });

    test('isMobile / isTablet / isDesktop / isTv flags', () {
      expect(DeviceType.mobile.isMobile, isTrue);
      expect(DeviceType.tablet.isTablet, isTrue);
      expect(DeviceType.desktop.isDesktop, isTrue);
      expect(DeviceType.tv.isTv, isTrue);
    });
  });
}
