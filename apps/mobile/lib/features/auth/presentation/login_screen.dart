import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../application/session_notifier.dart';
import 'widgets/pre_login_settings_row.dart';
import '../../../shared/widgets/animations.dart';
import '../../../l10n/app_localizations.dart';

enum _RoleChoice { patient, lab }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  _RoleChoice _role = _RoleChoice.patient;
  bool _obscurePass = true;
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });
    try {
      await ref.read(sessionNotifierProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
            selectedRole: _role == _RoleChoice.patient ? 'patient' : 'lab',
          );
    } catch (e) {
      if (mounted) {
        setState(() => _errorMsg = e.toString().replaceFirst('ApiException', '').trim());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PreLoginSettingsRow(),
                const SizedBox(height: 16),
                FadeSlideIn(
                  index: 0,
                  child: Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.brand,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    l10n.login,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Role toggle
                FadeSlideIn(
                  index: 2,
                  child: SegmentedButton<_RoleChoice>(
                  segments: [
                    ButtonSegment(
                      value: _RoleChoice.patient,
                      label: Text(l10n.rolePatient),
                      icon: const Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: _RoleChoice.lab,
                      label: Text(l10n.roleLab),
                      icon: const Icon(Icons.science_outlined),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) =>
                      setState(() => _role = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.brand,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
                ),
                const SizedBox(height: 24),

                // Email
                FadeSlideIn(
                  index: 3,
                  child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.validationRequired;
                    if (!v.contains('@')) return l10n.validationEmail;
                    return null;
                  },
                ),
                ),
                const SizedBox(height: 16),

                // Password
                FadeSlideIn(
                  index: 4,
                  child: TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.validationRequired;
                    if (v.length < 8) return l10n.validationPasswordLength;
                    return null;
                  },
                ),
                ),
                const SizedBox(height: 8),

                if (_errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMsg!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.destructive),
                  ),
                ],

                const SizedBox(height: 24),

                FadeSlideIn(
                  index: 5,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.login),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.noAccount),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => context.push(
                        _role == _RoleChoice.patient
                            ? Routes.registerPatient
                            : Routes.registerLab,
                      ),
                      child: Text(l10n.register),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
