import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  const PremiumBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background color
        Positioned.fill(
          child: Container(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        
        // Subtle color spots
        Positioned(
          top: -100,
          right: -50,
          child: _BlurSpot(
            color: const Color(0xFF00F2FE).withValues(alpha: 0.2),
            size: 400,
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: _BlurSpot(
            color: const Color(0xFFF7127C).withValues(alpha: 0.15),
            size: 500,
          ),
        ),
        Positioned(
          top: 200,
          left: -50,
          child: _BlurSpot(
            color: const Color(0xFF4FACFE).withValues(alpha: 0.1),
            size: 300,
          ),
        ),

        // Main content
        child,
      ],
    );
  }
}

class _BlurSpot extends StatelessWidget {
  const _BlurSpot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
