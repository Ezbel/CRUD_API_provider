import 'dart:io';
import 'package:flutter/material.dart';

Widget fileImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox.shrink(),
  );
}
