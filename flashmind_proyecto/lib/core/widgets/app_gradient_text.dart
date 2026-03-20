import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final LinearGradient gradient;
  final TextAlign textAlign;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.gradient = AppGradients.accent,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
