import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../application/session_notifier.dart';
import '../../../l10n/app_localizations.dart';

class LabPendingScreen extends ConsumerWidget {
  const LabPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 80,
                color: AppColors.warning,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.labPendingTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.labPendingBody,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                onPressed: () =>
                    ref.read(sessionNotifierProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
