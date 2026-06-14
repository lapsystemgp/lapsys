import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/router/app_router.dart';
import '../../../features/notifications/application/notification_service.dart';
import '../../../l10n/app_localizations.dart';

const _kNotifPromptShownKey = 'notif_permission_prompted';

class PatientShell extends ConsumerStatefulWidget {
  const PatientShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends ConsumerState<PatientShell> {
  static final _tabs = [
    Routes.patientShell,
    '${Routes.patientShell}/bookings',
    '${Routes.patientShell}/results',
    '${Routes.patientShell}/trends',
    '${Routes.patientShell}/profile',
  ];

  int _locationToIndex(String location) {
    for (var i = _tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptPermission());
  }

  Future<void> _maybePromptPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kNotifPromptShownKey) == true) return;
    if (!mounted) return;

    final status = await ref
        .read(notificationServiceProvider)
        .getPermissionStatus();
    if (!mounted) return;

    // Only show the rationale bottom sheet if permission is not yet determined.
    if (status == AuthorizationStatus.notDetermined ||
        status == AuthorizationStatus.denied) {
      await prefs.setBool(_kNotifPromptShownKey, true);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _NotificationPermissionSheet(
          onEnable: () {
            Navigator.pop(context);
            ref.read(notificationServiceProvider).requestPermission();
          },
          onSkip: () => Navigator.pop(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i]),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.science_outlined),
            activeIcon: const Icon(Icons.science),
            label: l10n.patientTabLabs,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: l10n.patientTabBookings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_outlined),
            activeIcon: const Icon(Icons.folder),
            label: l10n.patientTabResults,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart_outlined),
            activeIcon: const Icon(Icons.show_chart),
            label: l10n.patientTabTrends,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.patientTabProfile,
          ),
        ],
      ),
    );
  }
}

class _NotificationPermissionSheet extends StatelessWidget {
  const _NotificationPermissionSheet({
    required this.onEnable,
    required this.onSkip,
  });

  final VoidCallback onEnable;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.notifications_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.stayUpToDate,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationPermissionBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onEnable,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.enableNotifications),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onSkip,
              child: Text(l10n.notNow),
            ),
          ],
        ),
      ),
    );
  }
}
