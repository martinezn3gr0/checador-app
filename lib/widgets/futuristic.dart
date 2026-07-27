import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated deep-space background with drifting neon aurora blobs + grid.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 14))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bg0, AppColors.bg1, AppColors.bg2],
            ),
          ),
          child: SizedBox.expand(),
        ),
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            return Stack(
              children: [
                _blob(Alignment(-0.9 + t * 0.3, -0.8), AppColors.violet, 320),
                _blob(Alignment(0.95 - t * 0.2, -0.5 + t * 0.2), AppColors.cyan, 300),
                _blob(Alignment(0.2 + t * 0.2, 0.9), AppColors.blue, 360),
              ],
            );
          },
        ),
        CustomPaint(painter: _GridPainter(), size: Size.infinite),
        widget.child,
      ],
    );
  }

  Widget _blob(Alignment align, Color color, double size) {
    return Align(
      alignment: align,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.45), color.withOpacity(0.0)],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Frosted-glass card with subtle gradient stroke and depth.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: glowColor != null
                ? [
                    BoxShadow(
                      color: glowColor!.withOpacity(0.22),
                      blurRadius: 28,
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(radius),
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glowing gradient action button.
class NeonButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Gradient gradient;
  final bool outlined;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppGradients.neon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: outlined ? AppColors.cyan : const Color(0xFF06121F), size: 22),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: TextStyle(
            color: outlined ? AppColors.textPrimary : const Color(0xFF06121F),
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: outlined ? null : gradient,
          borderRadius: BorderRadius.circular(18),
          border: outlined ? Border.all(color: AppColors.cyan.withOpacity(0.7), width: 1.4) : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: (gradient.colors.first).withOpacity(0.5),
                    blurRadius: 26,
                    spreadRadius: -4,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(child: content),
      ),
    );
  }
}

/// Neon-outlined text field used across auth forms.
class NeonField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;

  const NeonField({
    super.key,
    required this.label,
    required this.icon,
    this.initialValue,
    this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 6),
          child: Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.cyan),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cyan, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient-filled text (for brand/hero titles).
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(this.text,
      {super.key, required this.style, this.gradient = AppGradients.neon});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
