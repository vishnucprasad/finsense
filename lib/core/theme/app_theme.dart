import 'package:flutter/material.dart';
import 'dart:ui';

class AppTheme {
  static const deepNavy = Color(0xFF0A0E21);
  static const emerald = Color(0xFF10b981);
  static const cyan = Color(0xFF06b6d4);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepNavy,
    primaryColor: emerald,
    colorScheme: const ColorScheme.dark(
      primary: emerald,
      secondary: cyan,
      surface: Color(0xFF111827),
    ),
    useMaterial3: true,
  );
}

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double width;
  final double height;
  
  const GlassmorphismContainer({
    super.key, 
    required this.child, 
    this.padding, 
    this.borderRadius = 16.0,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width == double.infinity ? null : width,
          height: height == double.infinity ? null : height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
