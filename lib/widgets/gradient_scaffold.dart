import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const GradientScaffold({super.key, required this.body, this.appBar});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF020617),
                    const Color(0xFF0F172A),
                    const Color(0xFF1E1B4B),
                    const Color(0xFF312E81),
                  ]
                : [
                    const Color(0xFFF8FAFC), // Slate 50
                    const Color(0xFFF1F5F9), // Slate 100
                    const Color(0xFFF1F5F9), // Slate 100
                    const Color(0xFFF8FAFC), // Slate 50
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            // Extra light overlay in light mode improves contrast consistency.
            color: isDark ? Colors.transparent : Colors.white.withValues(alpha: 0.18),
          ),
          child: body,
        ),
      ),
    );
  }
}
