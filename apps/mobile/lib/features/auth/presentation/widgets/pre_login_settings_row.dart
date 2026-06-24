import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../l10n/app_localizations.dart';

class PreLoginSettingsRow extends ConsumerWidget {
  const PreLoginSettingsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);

    IconData themeIcon;
    switch (themeMode) {
      case ThemeMode.light:
        themeIcon = Icons.light_mode_outlined;
      case ThemeMode.dark:
        themeIcon = Icons.dark_mode_outlined;
      case ThemeMode.system:
        themeIcon = Icons.brightness_auto_outlined;
    }

    final langLabel = switch (locale?.languageCode) {
      'en' => 'EN',
      'ar' => 'AR',
      _ => 'AUTO',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Language selector
        PopupMenuButton<String?>(
          tooltip: l10n.language,
          icon: Text(
            langLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.brand,
                  fontWeight: FontWeight.w700,
                ),
          ),
          onSelected: (code) {
            ref.read(localeControllerProvider.notifier).setLocale(
                  code == null ? null : Locale(code),
                );
          },
          itemBuilder: (_) => [
            PopupMenuItem<String?>(
              value: null,
              child: Text(l10n.languageSystem),
            ),
            PopupMenuItem<String?>(
              value: 'en',
              child: Text(l10n.languageEnglish),
            ),
            PopupMenuItem<String?>(
              value: 'ar',
              child: Text(l10n.languageArabic),
            ),
          ],
        ),

        // Theme selector
        PopupMenuButton<ThemeMode>(
          tooltip: l10n.theme,
          icon: Icon(themeIcon, color: AppColors.brand),
          onSelected: (mode) {
            ref.read(themeControllerProvider.notifier).setMode(mode);
          },
          itemBuilder: (_) => [
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.system,
              child: Row(children: [
                const Icon(Icons.brightness_auto_outlined, size: 18),
                const SizedBox(width: 8),
                Text(l10n.themeSystem),
              ]),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(children: [
                const Icon(Icons.light_mode_outlined, size: 18),
                const SizedBox(width: 8),
                Text(l10n.themeLight),
              ]),
            ),
            PopupMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(children: [
                const Icon(Icons.dark_mode_outlined, size: 18),
                const SizedBox(width: 8),
                Text(l10n.themeDark),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}
