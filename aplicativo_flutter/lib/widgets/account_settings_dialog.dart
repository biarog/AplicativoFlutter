import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

/// Dialog to edit account settings such as display name and (placeholder)
/// change-password action.
class AccountSettingsDialog extends ConsumerStatefulWidget {
  /// Optional dialog width in logical pixels. If null, a responsive
  /// width based on screen size will be used.
  final double? width;

  /// Optional maximum width for the dialog. Defaults to 600 if null.
  final double? maxWidth;

  const AccountSettingsDialog({super.key, this.width, this.maxWidth});

  @override
  ConsumerState<AccountSettingsDialog> createState() => _AccountSettingsDialogState();
}

class _AccountSettingsDialogState extends ConsumerState<AccountSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authStateChangesProvider);
    // Try to initialize name from current user if available
    authState.whenData((user) {
      final name = user?.displayName ?? '';
      _nameController.text = name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final newName = _nameController.text.trim();
    try {
      await ref.read(authRepositoryProvider).updateDisplayName(newName);
      // Refresh auth state provider so UI consumers (AppBar) pick up the
      // updated displayName immediately.
      try {
        // refresh returns a value; assign to unused variable to satisfy linter
        final _ = ref.refresh(authStateChangesProvider);
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.nameUpdated)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openChangePassword() {
    // Placeholder: open a simple dialog for now. You can replace this later
    // with a full password-change flow dialog/widget.
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.changePassword),
        content: Text(AppLocalizations.of(context)!.changePasswordNotImplemented),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(AppLocalizations.of(context)!.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine width: use explicit widget.width if provided,
    // otherwise use 85% of screen width as a sensible default.
    final double computedWidth = widget.width ?? MediaQuery.of(context).size.width * 0.85;
    final double computedMaxWidth = widget.maxWidth ?? 600;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.accountSettings),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: computedMaxWidth),
        child: SizedBox(
          width: computedWidth,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.displayName),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterDisplayName;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _openChangePassword,
                    child: Text(AppLocalizations.of(context)!.changePassword),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(AppLocalizations.of(context)!.save),
            ),
          ],
        )
      ],
    );
  }
}
