import 'package:flutter/material.dart';

class VerificationRequestDialog extends StatefulWidget {
  const VerificationRequestDialog({super.key});

  @override
  State<VerificationRequestDialog> createState() => _VerificationRequestDialogState();
}

class _VerificationRequestDialogState extends State<VerificationRequestDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request verification'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Optional message for moderators'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Add a message (optional)'
            ),
            enabled: !_submitting,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop<String?>(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting
              ? null
              : () async {
                  setState(() => _submitting = true);
                  // Return the message string (can be empty)
                  Navigator.of(context).pop<String?>(_controller.text.trim());
                },
          child: _submitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Submit'),
        ),
      ],
    );
  }
}

