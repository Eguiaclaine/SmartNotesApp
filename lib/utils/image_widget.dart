import 'package:flutter/material.dart';

import 'image_widget_io.dart' if (dart.library.html) 'image_widget_web.dart';

Widget imageWidgetFromPath(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
}) {
  return imageWidgetFromPathImpl(path, height: height, width: width, fit: fit);
}
