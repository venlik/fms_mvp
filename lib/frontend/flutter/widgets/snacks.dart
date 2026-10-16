import 'package:flutter/material.dart';

/// Shows a success-style message at the bottom of the screen.
void showSuccessSnack(BuildContext context, String message) {
  _show(context, message, icon: Icons.check_circle_outline);
}

/// Shows an error-style message. Prefers the exception's `toString`,
/// which for our `DomainError` subclasses is `TypeName: message`.
void showErrorSnack(BuildContext context, Object error) {
  _show(
    context,
    error.toString(),
    icon: Icons.error_outline,
    color: Colors.red.shade700,
  );
}

void _show(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? color,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
      ),
    );
}