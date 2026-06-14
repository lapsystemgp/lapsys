import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/biometric_service.dart';
import '../../../l10n/app_localizations.dart';

/// Wraps any widget requiring biometric unlock on cold start.
class BiometricGate extends ConsumerStatefulWidget {
  const BiometricGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends ConsumerState<BiometricGate> {
  bool _unlocked = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _attempt();
  }

  Future<void> _attempt() async {
    final service = ref.read(biometricServiceProvider);
    if (service == null) {
      // SharedPreferences not yet loaded — skip gate.
      setState(() {
        _unlocked = true;
        _checking = false;
      });
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final reason = l10n.authenticateToUnlock;
    final ok = await service.authenticate(reason);
    if (mounted) setState(() { _unlocked = ok; _checking = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_unlocked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 80),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _attempt,
                child: Text(AppLocalizations.of(context)!.authenticateButton),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
