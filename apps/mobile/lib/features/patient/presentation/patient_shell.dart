import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';

class PatientShell extends StatelessWidget {
  const PatientShell({super.key, required this.child});

  final Widget child;

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
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
