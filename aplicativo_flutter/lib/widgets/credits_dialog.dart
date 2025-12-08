import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class CreditsDialog extends StatelessWidget {
  const CreditsDialog({super.key});

  void _copyToClipboard(BuildContext context, String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(
        l10n.credits,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.developedBy,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            
            // Developer 1
            _buildDeveloperCard(
              context,
              name: 'Beatriz Rogers Tripoli Barbosa',
              githubUrl: 'https://github.com/biarog',
              l10n: l10n,
            ),
            const SizedBox(height: 12),
            
            // Developer 2
            _buildDeveloperCard(
              context,
              name: 'Matteo Cileneo Savan',
              githubUrl: 'https://github.com/matteosavan',
              l10n: l10n,
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              l10n.thankYouMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.fitnessGoalsMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(
    BuildContext context, {
    required String name,
    required String githubUrl,
    required AppLocalizations l10n,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _copyToClipboard(context, githubUrl, l10n.copyToClipboard),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withAlpha(77),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.githubUrl,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.copy,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
