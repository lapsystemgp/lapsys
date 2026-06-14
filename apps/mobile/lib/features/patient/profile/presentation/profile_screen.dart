import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../workspace/application/workspace_provider.dart';
import '../../workspace/data/workspace_models.dart';
import '../../workspace/data/patient_repository.dart';
import '../../../auth/application/session_notifier.dart';
import '../../../auth/application/biometric_service.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(workspaceProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(workspaceProvider),
        ),
        data: (profile) => _ProfileForm(profile: profile),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  final WorkspaceProfile profile;

  const _ProfileForm({required this.profile});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late LabHistorySharing _sharing;
  bool _saving = false;
  bool _signingOut = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.fullName);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _addressCtrl = TextEditingController(text: widget.profile.address);
    _sharing = widget.profile.labHistorySharing;
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref.read(patientRepositoryProvider).updateProfile(
            fullName: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            labHistorySharing: _sharing,
          );
      ref.invalidate(workspaceProvider);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveFailed(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Email (read-only)
          _Section(
            title: l10n.account,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.email),
              subtitle: Text(widget.profile.email),
            ),
          ),

          const SizedBox(height: 16),

          // Editable fields
          _Section(
            title: l10n.personalInfo,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.nameRequired
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.address,
                    prefixIcon: const Icon(Icons.home_outlined),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Privacy toggle
          _Section(
            title: l10n.privacy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.shareHistoryAcrossLabs),
                  subtitle: Text(
                    l10n.enableCrossLabTrends,
                  ),
                  value: _sharing == LabHistorySharing.fullHistoryAuthorized,
                  onChanged: (v) => setState(() => _sharing = v
                      ? LabHistorySharing.fullHistoryAuthorized
                      : LabHistorySharing.sameLabOnly),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    _sharing == LabHistorySharing.fullHistoryAuthorized
                        ? l10n.allLabsSeeHistory
                        : l10n.onlyTestingLabSeesResult,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
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

          const SizedBox(height: 24),

          _saving
              ? const Center(child: CircularProgressIndicator())
              : FilledButton(
                  onPressed: _save,
                  child: Text(l10n.saveChanges),
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
        Text(title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
