import 'package:flutter/material.dart';

/// A button that disables itself while its async [onPressed] runs.
///
/// Usage:
/// ```dart
/// AsyncButton(
///   label: 'Save',
///   onPressed: () async {
///     await services.repos.customers.commit(draft);
///     if (context.mounted) Navigator.pop(context, true);
///   },
/// )
/// ```
///
/// If [onPressed] throws, the exception propagates after the button
/// re-enables. The caller is expected to catch it and show a snackbar —
/// see `showErrorSnack` in this folder.
class AsyncButton extends StatefulWidget {
  final String label;
  final Future<void> Function()? onPressed;
  final bool filled;
  final IconData? icon;

  const AsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.icon,
  });

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  Future<void> _handle() async {
    final fn = widget.onPressed;
    if (fn == null || _busy) return;
    setState(() => _busy = true);
    try {
      await fn();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPressed = widget.onPressed == null || _busy ? null : _handle;
    final child = _busy
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(widget.label, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    return widget.filled
        ? FilledButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);
  }
}
