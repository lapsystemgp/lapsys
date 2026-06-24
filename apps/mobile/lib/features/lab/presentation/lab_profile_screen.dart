import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/lab_workspace_provider.dart';
import '../../auth/application/session_notifier.dart';
import '../../auth/application/biometric_service.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../l10n/app_localizations.dart';

class LabProfileScreen extends ConsumerWidget {
  const LabProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(sessionNotifierProvider);
    final labAsync = ref.watch(labInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: labAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labWorkspaceProvider),
        ),
        data: (lab) => _LabProfileBody(
          email: session.user?.email ?? '',
          labName: lab.name,
          address: lab.address,
        ),
      ),
    );
  }
}

class _LabProfileBody extends ConsumerStatefulWidget {
  final String email;
  final String labName;
  final String address;

  const _LabProfileBody({
    required this.email,
    required this.labName,
    required this.address,
  });

  @override
  ConsumerState<_LabProfileBody> createState() => _LabProfileBodyState();
}

class _LabProfileBodyState extends ConsumerState<_LabProfileBody> {
  bool _signingOut = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    final service = ref.read(biometricServiceProvider);
    if (service == null) return;
    final available = await service.isAvailable();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = service.isEnabled;
      });
    }
  }

  Future<void> _setBiometric(bool value) async {
    await ref.read(biometricServiceProvider)?.setEnabled(value);
    if (mounted) setState(() => _biometricEnabled = value);
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    try {
      await ref.read(sessionNotifierProvider.notifier).logout();
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: l10n.account,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.email),
                subtitle: Text(widget.email),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.science_outlined),
                title: Text(l10n.labName),
                subtitle: Text(widget.labName),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on_outlined),
                title: Text(l10n.address),
                subtitle: Text(widget.address),
              ),
            ],
          ),
        ),

        if (_biometricAvailable) ...[
          const SizedBox(height: 16),
          _Section(
            title: l10n.security,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.biometricUnlock),
              subtitle: Text(l10n.biometricUnlockSubtitle),
              value: _biometricEnabled,
              onChanged: _setBiometric,
            ),
          ),
        ],

        const SizedBox(height: 16),
        _Section(
          title: l10n.language,
          child: _LanguageSelector(),
        ),

        const SizedBox(height: 16),
        _Section(
          title: l10n.theme,
          child: _ThemeSelector(),
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 8),

        _signingOut
            ? const Center(child: CircularProgressIndicator())
            : TextButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(l10n.signOut,
                    style: const TextStyle(color: Colors.red)),
              ),
      ],
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(localeControllerProvider)?.languageCode;

    void choose(String? code) {
      ref.read(localeControllerProvider.notifier).setLocale(
            code == null ? null : Locale(code),
          );
    }

    return RadioGroup<String?>(
      groupValue: selected,
      onChanged: choose,
      child: Column(
        children: [
          RadioListTile<String?>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.languageSystem),
            value: null,
          ),
          RadioListTile<String?>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.languageEnglish),
            value: 'en',
          ),
          RadioListTile<String?>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.languageArabic),
            value: 'ar',
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(themeControllerProvider);

    void choose(ThemeMode? value) {
      if (value != null) {
        ref.read(themeControllerProvider.notifier).setMode(value);
      }
    }

    return RadioGroup<ThemeMode>(
      groupValue: mode,
      onChanged: choose,
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.themeSystem),
            value: ThemeMode.system,
          ),
          RadioListTile<ThemeMode>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.themeLight),
            value: ThemeMode.light,
          ),
          RadioListTile<ThemeMode>(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.themeDark),
            value: ThemeMode.dark,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
