import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class VoxlyLogo extends StatefulWidget {
  final double size;
  final bool isAnimated;

  const VoxlyLogo({
    super.key,
    this.size = 100,
    this.isAnimated = true,
  });

  @override
  State<VoxlyLogo> createState() => _VoxlyLogoState();
}

class _VoxlyLogoState extends State<VoxlyLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> heights = [0.45, 0.65, 0.80, 0.30, 0.80, 0.65, 0.45];
  final List<Color> colors = [
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.primary,
    AppColors.primaryGlow,
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.primary,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isAnimated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 0.8),
          painter: _VoxlyLogoPainter(
            heights: heights,
            colors: colors,
            animationValue: _controller.value,
            isAnimated: widget.isAnimated,
          ),
        );
      },
    );
  }
}

class _VoxlyLogoPainter extends CustomPainter {
  final List<double> heights;
  final List<Color> colors;
  final double animationValue;
  final bool isAnimated;

  _VoxlyLogoPainter({
    required this.heights,
    required this.colors,
    required this.animationValue,
    required this.isAnimated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = heights.length;
    final barWidth = size.width / (barCount * 1.6);
    final spacing = barWidth * 0.6;
    final totalWidth = (barCount * barWidth) + ((barCount - 1) * spacing);
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < barCount; i++) {
        final x = startX + i * (barWidth + spacing);
        
        double currentHeightScale = heights[i];
        if (isAnimated) {
            final sinVal = math.sin(animationValue * 2 * math.pi + (i * 0.5));
            currentHeightScale = heights[i] * (0.7 + (sinVal * 0.3));
        }

        final height = size.height * currentHeightScale;
        final y = (size.height - height) / 2;

        final paint = Paint()
            ..color = colors[i]
            ..style = PaintingStyle.fill;
        
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, barWidth, height),
                Radius.circular(barWidth / 2),
            ),
            paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _VoxlyLogoPainter oldDelegate) => true;
}

// wait, the above extension is wrong. I should use dart:math.sin
