import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/auth_repository.dart';
import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';

enum RegisterMode { patient, lab }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.mode});

  final RegisterMode mode;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMsg = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      if (widget.mode == RegisterMode.patient) {
        await repo.registerPatient(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );
      } else {
        await repo.registerLab(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          labName: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text.trim() : null,
        );
      }
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _errorMsg = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPatient = widget.mode == RegisterMode.patient;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPatient ? l10n.registerPatient : l10n.registerLab),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.email),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.validationRequired;
                    if (!v.contains('@')) return l10n.validationEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: isPatient ? l10n.fullName : l10n.labName,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(labelText: l10n.address),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    hintText: isPatient ? null : '(optional)',
                  ),
                  validator: isPatient
                      ? (v) => (v == null || v.trim().isEmpty)
                          ? l10n.validationRequired
                          : null
                      : null,
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMsg!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.destructive),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isPatient ? l10n.registerPatient : l10n.registerLab),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.alreadyHaveAccount),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.login),
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
