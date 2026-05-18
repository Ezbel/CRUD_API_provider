import 'package:flutter/material.dart';

Widget fileImageWidget(
  String path, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  return errorWidget ?? const SizedBox.shrink();
}
