import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memories_web_admin/core/app_colors.dart';

class AppText extends StatelessWidget {
  const AppText({
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.color = AppColors.black,
    this.maxLines,
    this.textAlign,
    this.decoration,
    this.overflow,
    this.shadows,
    this.height,
    this.fontStyle,
    super.key,
  });

  final String text;

  final double fontSize;

  final FontWeight fontWeight;

  final Color color;

  final int? maxLines;

  final TextAlign? textAlign;

  final TextDecoration? decoration;

  final TextOverflow? overflow;

  final List<Shadow>? shadows;

  final double? height;

  final FontStyle? fontStyle;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        decoration: decoration,
        overflow: overflow,
        shadows: shadows,
        height: height,
        fontStyle: fontStyle,
      ),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }
}
