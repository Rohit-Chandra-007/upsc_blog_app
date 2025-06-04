import 'package:flutter/material.dart';

class AnimatedSizeAndFade extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  final Duration duration;

  const AnimatedSizeAndFade({
    super.key,
    required this.child,
    required this.isVisible,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: duration,
        child: isVisible ? child : Container(height: 0),
      ),
    );
  }
}