import 'package:flutter/material.dart';

class UcademyStyles {
  TextStyle stylePrimary({
    double size = 10,
    Color color = Colors.black,
    FontWeight fontWeight = FontWeight.normal,
    double? heightText,
    TextDecoration? textDecoration,
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: fontWeight,
      height: heightText,
      decoration: textDecoration
    );
  }
}
