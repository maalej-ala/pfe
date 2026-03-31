// header_band.dart
import 'package:flutter/material.dart';

class HeaderBand extends StatelessWidget {
  final double height;
  const HeaderBand({this.height = 220, super.key});

  @override
  Widget build(BuildContext context) {
    // In light mode → navy primary; in dark mode → dark surface card color
    final color = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
    );
  }
}