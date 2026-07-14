import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded, large }

class Breakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;
}

ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < Breakpoints.compact) return ScreenSize.compact;
  if (width < Breakpoints.medium) return ScreenSize.medium;
  if (width < Breakpoints.expanded) return ScreenSize.expanded;
  return ScreenSize.large;
}

bool isCompact(BuildContext context) => screenSizeOf(context) == ScreenSize.compact;

bool isWide(BuildContext context) => screenSizeOf(context) != ScreenSize.compact;

int gridColumnCount(BuildContext context) {
  return switch (screenSizeOf(context)) {
    ScreenSize.compact => 1,
    ScreenSize.medium => 2,
    ScreenSize.expanded => 3,
    ScreenSize.large => 4,
  };
}

double maxContentWidth(BuildContext context) {
  return switch (screenSizeOf(context)) {
    ScreenSize.compact => double.infinity,
    ScreenSize.medium => 720,
    ScreenSize.expanded => 960,
    ScreenSize.large => 1200,
  };
}

EdgeInsets pagePadding(BuildContext context) {
  final size = screenSizeOf(context);
  final horizontal = switch (size) {
    ScreenSize.compact => 16.0,
    ScreenSize.medium => 24.0,
    ScreenSize.expanded => 32.0,
    ScreenSize.large => 40.0,
  };
  return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
}

double gridAspectRatio(BuildContext context) {
  return switch (screenSizeOf(context)) {
    ScreenSize.compact => 1.35,
    ScreenSize.medium => 1.5,
    ScreenSize.expanded => 1.55,
    ScreenSize.large => 1.6,
  };
}

String formatEntryDate(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = date.toLocal();
  return '${weekdays[local.weekday - 1]}, ${months[local.month - 1]} ${local.day}';
}
