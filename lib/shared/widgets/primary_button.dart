// primary_button.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.enabled = true,
    this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        // ElevatedButton picks up elevatedButtonTheme from AppTheme
        // automatically. We only override the icon color here.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 18,
                // Gold accent when active, muted when disabled
                color: enabled
                    ? colorScheme.secondary
                    : Colors.white54,
              ),
            ],
          ],
        ),
      ),
    );
  }
}