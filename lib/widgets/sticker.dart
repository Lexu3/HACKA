import 'package:flutter/material.dart';

class Sticker extends StatelessWidget {
  final Widget child;
  final double left;
  final double top;
  const Sticker({super.key, required this.child, this.left = 0, this.top = 0});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(angle: -0.08, child: child),
    );
  }
}
