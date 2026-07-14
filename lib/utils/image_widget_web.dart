import 'package:flutter/material.dart';

Widget imageWidgetFromPathImpl(
  String path, {
  double? height,
  double? width,
  BoxFit? fit,
}) {
  if (path.startsWith('http') ||
      path.startsWith('data:') ||
      path.startsWith('blob:')) {
    return Image.network(
      path,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }

  return Container(
    height: height,
    width: width,
    color: Colors.black12,
    alignment: Alignment.center,
    child: const Icon(
      Icons.image_not_supported,
      size: 48,
      color: Colors.black38,
    ),
  );
}
