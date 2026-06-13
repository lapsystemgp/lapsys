import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../application/session_notifier.dart';
import '../../../l10n/app_localizations.dart';

class AdminUnsupportedScreen extends ConsumerWidget {
  const AdminUnsupportedScreen({super.key});

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
                Icons.computer_outlined,
                size: 80,
                color: AppColors.brand,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.adminMobileUnsupported,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
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
