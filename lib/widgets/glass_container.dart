import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BoxBorder? border;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final List<BoxShadow>? boxShadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
    this.color,
    this.border,
    this.width,
    this.height,
    this.alignment,
    this.boxShadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor = _resolveBackgroundColor(isDark);
    final resolvedBorder = _resolveBorder(isDark);
    final resolvedShadows = _resolveShadows(isDark);

    return Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: resolvedBorder,
        boxShadow: resolvedShadows,
      ),
      child: child,
    );
  }

  Color _resolveBackgroundColor(bool isDark) {
    if (isDark) {
      if (color != null) {
        return color!.withValues(alpha: 0.16);
      }
      return Colors.white.withValues(alpha: 0.07);
    }

    // In light mode, use a clean white base or a very subtle tinted white
    if (color != null) {
      return Color.alphaBlend(
        color!.withValues(alpha: 0.08),
        Colors.white,
      );
    }
    return Colors.white;
  }

  BoxBorder _resolveBorder(bool isDark) {
    if (border != null) return border!;

    if (isDark) {
      return Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1);
    }

    // Modern thin border with slight slate tint
    return Border.all(
      color: const Color(0xFFE2E8F0), // Slate 200
      width: 1.0,
    );
  }

  List<BoxShadow>? _resolveShadows(bool isDark) {
    if (boxShadows != null) return boxShadows;

    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
    }

    // Soft, natural shadow for light mode
    return [
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
        blurRadius: 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 1),
      ),
    ];
  }
}
