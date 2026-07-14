import 'dart:io';

import 'package:flutter/material.dart';

Widget imageWidgetFromPathImpl(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
}) {
  return Image.file(File(path), height: height, width: width, fit: fit);
}
