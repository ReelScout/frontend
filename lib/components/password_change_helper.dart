import 'package:flutter/material.dart';
import 'package:frontend/components/password_change_dialog.dart';

/// Helper class to show the password change dialog
class PasswordChangeHelper {
  /// Shows the password change dialog and returns true if password was changed successfully
  static Future<bool?> showPasswordChangeDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return const PasswordChangeDialog();
      },
    );
  }
}