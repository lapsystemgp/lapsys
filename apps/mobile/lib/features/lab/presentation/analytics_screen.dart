import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/lab_workspace_provider.dart';
import '../data/lab_workspace_models.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../l10n/app_localizations.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final analyticsAsync = ref.watch(labAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.labTabAnalytics)),
      body: analyticsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labWorkspaceProvider),
        ),
        data: (analytics) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(labWorkspaceProvider),
          child: _AnalyticsBody(analytics: analytics),
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.analytics});
  final LabAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _MetricCard(
              label: l10n.totalBookings,
              value: '${analytics.totalBookings}',
              icon: Icons.event_note_outlined,
              color: Colors.blue,
            ),
            _MetricCard(
              label: l10n.statusCompleted,
              value: '${analytics.completedBookings}',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _MetricCard(
              label: l10n.pendingResults,
              value: '${analytics.pendingResults}',
              icon: Icons.pending_actions_outlined,
              color: Colors.orange,
            ),
            _MetricCard(
              label: l10n.revenue,
              value: 'EGP ${_formatRevenue(analytics.revenueEstimateEgp)}',
              icon: Icons.payments_outlined,
              color: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Capacity usage
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.slotCapacityUsage,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: analytics.capacityUsagePercent / 100,
                          minHeight: 12,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${analytics.capacityUsagePercent.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.capacityUsageSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Completion rate
        if (analytics.totalBookings > 0) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.completionRate,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: analytics.completedBookings /
                                analytics.totalBookings,
                            minHeight: 12,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            valueColor: const AlwaysStoppedAnimation(Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${((analytics.completedBookings / analytics.totalBookings) * 100).toStringAsFixed(1)}%',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Top tests
        if (analytics.topTests.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.mostBookedTests,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 12),
                  ...analytics.topTests.asMap().entries.map(
                        (e) => _TopTestRow(
                          rank: e.key + 1,
                          test: e.value,
                          maxCount: analytics.topTests.first.count,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatRevenue(int egp) {
    if (egp >= 1000) {
      return '${(egp / 1000).toStringAsFixed(1)}k';
    }
    return '$egp';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTestRow extends StatelessWidget {
  const _TopTestRow({
    required this.rank,
    required this.test,
    required this.maxCount,
  });

  final int rank;
  final LabTopTest test;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount > 0 ? test.count / maxCount : 0.0;
    final colors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.brown.shade300,
      Colors.blue,
      Colors.teal,
    ];
    final color = rank <= colors.length ? colors[rank - 1] : Colors.blue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(test.testName,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    Text('${test.count}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            )),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
