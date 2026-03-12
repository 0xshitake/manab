import 'package:flutter/material.dart';

/// Dialog for creating or renaming a binder.
class BinderCreateDialog extends StatefulWidget {
  const BinderCreateDialog({
    super.key,
    this.initialName,
    this.title = 'New Binder',
    this.confirmLabel = 'Create',
  });

  final String? initialName;
  final String title;
  final String confirmLabel;

  /// Shows the dialog and returns the entered name, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    String? initialName,
    String title = 'New Binder',
    String confirmLabel = 'Create',
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => BinderCreateDialog(
        initialName: initialName,
        title: title,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  State<BinderCreateDialog> createState() => _BinderCreateDialogState();
}

class _BinderCreateDialogState extends State<BinderCreateDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Binder name',
          hintText: 'e.g. Main Collection',
        ),
        textCapitalization: TextCapitalization.words,
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(_controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  void _submit(String value) {
    final name = value.trim();
    if (name.isNotEmpty) {
      Navigator.of(context).pop(name);
    }
  }
}
