import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/lab_workspace_provider.dart';
import '../data/lab_repository.dart';
import '../data/lab_workspace_models.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceAsync = ref.watch(labWorkspaceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: workspaceAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labWorkspaceProvider),
        ),
        data: (workspace) => _DashboardBody(workspace: workspace),
      ),
    );
  }
}

class _DashboardBody extends ConsumerStatefulWidget {
  const _DashboardBody({required this.workspace});
  final LabWorkspaceResponse workspace;

  @override
  ConsumerState<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends ConsumerState<_DashboardBody> {
  bool _homeCollection = false;
  bool _homeTestKit = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _homeCollection = widget.workspace.lab.homeCollection;
    _homeTestKit = widget.workspace.lab.homeTestKit;
  }

  Future<void> _saveCapabilities() async {
    setState(() => _saving = true);
    try {
      await ref.read(labRepositoryProvider).updateProfile(
            homeCollection: _homeCollection,
            homeTestKit: _homeTestKit,
          );
      ref.invalidate(labWorkspaceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Capabilities updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lab = widget.workspace.lab;
    final analytics = widget.workspace.analytics;
    final pending = widget.workspace.bookings.where((b) => b.status.name == 'pending').length;
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(labWorkspaceProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Lab header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(Icons.science, color: scheme.onPrimaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lab.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                            Text(lab.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                label: 'Total Bookings',
                value: '${analytics.totalBookings}',
                icon: Icons.event_note,
                color: Colors.blue,
              ),
              _StatCard(
                label: 'Completed',
                value: '${analytics.completedBookings}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _StatCard(
                label: 'Pending Results',
                value: '${analytics.pendingResults}',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              _StatCard(
                label: 'Revenue',
                value: 'EGP ${analytics.revenueEstimateEgp}',
                icon: Icons.payments,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Capacity usage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Slot Capacity Used',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text('${analytics.capacityUsagePercent.toStringAsFixed(1)}%',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: scheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: analytics.capacityUsagePercent / 100,
                      minHeight: 8,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pending bookings alert
          if (pending > 0)
            Card(
              color: scheme.errorContainer,
              child: ListTile(
                leading: Icon(Icons.notifications_active,
                    color: scheme.onErrorContainer),
                title: Text(
                  '$pending booking${pending > 1 ? 's' : ''} awaiting confirmation',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
                trailing: Icon(Icons.chevron_right,
                    color: scheme.onErrorContainer),
              ),
            ),
          const SizedBox(height: 16),

          // Lab capabilities
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Capabilities',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Home Collection'),
                    subtitle: const Text('Lab staff collect samples at patient\'s home'),
                    value: _homeCollection,
                    onChanged: (v) => setState(() => _homeCollection = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Home Test Kit'),
                    subtitle: const Text('Ship kit to patient\'s address'),
                    value: _homeTestKit,
                    onChanged: (v) => setState(() => _homeTestKit = v),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _saveCapabilities,
                      child: _saving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Capabilities'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
