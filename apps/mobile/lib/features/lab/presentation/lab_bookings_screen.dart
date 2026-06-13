import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../application/lab_workspace_provider.dart';
import '../data/lab_workspace_models.dart';
import '../../patient/booking/data/booking_models.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/empty_state.dart';

class LabBookingsScreen extends ConsumerStatefulWidget {
  const LabBookingsScreen({super.key});

  @override
  ConsumerState<LabBookingsScreen> createState() => _LabBookingsScreenState();
}

class _LabBookingsScreenState extends ConsumerState<LabBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceAsync = ref.watch(labWorkspaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: workspaceAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labWorkspaceProvider),
        ),
        data: (workspace) {
          final pending = workspace.bookings
              .where((b) => b.status == BookingStatus.pending)
              .toList();
          final confirmed = workspace.bookings
              .where((b) => b.status == BookingStatus.confirmed)
              .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(labWorkspaceProvider),
            child: TabBarView(
              controller: _tabs,
              children: [
                _BookingList(bookings: pending, emptyMessage: 'No pending bookings'),
                _BookingList(bookings: confirmed, emptyMessage: 'No confirmed bookings'),
                _BookingList(
                    bookings: workspace.bookings, emptyMessage: 'No bookings yet'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings, required this.emptyMessage});

  final List<LabBookingItem> bookings;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(icon: Icons.event_note, message: emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: bookings.length,
      itemBuilder: (context, i) => _BookingTile(booking: bookings[i]),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final LabBookingItem booking;

  @override
  Widget build(BuildContext context) {
    final scheduled = DateTime.tryParse(booking.scheduledAt);
    final dateStr = scheduled != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(scheduled.toLocal())
        : booking.scheduledAt;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: () => context.push(
          '/lab/bookings/${booking.id}',
          extra: booking,
        ),
        leading: CircleAvatar(
          backgroundColor: _statusColor(booking.status).withAlpha(30),
          child: Icon(_typeIcon(booking.bookingType),
              color: _statusColor(booking.status), size: 20),
        ),
        title: Text(booking.patient.fullName ?? 'Unknown Patient',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.test.name),
            Text(dateStr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusChip(status: booking.status),
            const SizedBox(height: 4),
            _TypeChip(type: booking.bookingType),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _statusColor(BookingStatus s) {
    switch (s) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Colors.red;
    }
  }

  IconData _typeIcon(BookingType t) {
    switch (t) {
      case BookingType.labVisit:
        return Icons.business;
      case BookingType.homeCollection:
        return Icons.home;
      case BookingType.homeTestKit:
        return Icons.local_shipping;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.pending => ('Pending', Colors.orange),
      BookingStatus.confirmed => ('Confirmed', Colors.blue),
      BookingStatus.completed => ('Completed', Colors.green),
      BookingStatus.cancelled => ('Cancelled', Colors.red),
      BookingStatus.rejected => ('Rejected', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final BookingType type;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      BookingType.labVisit => 'Lab Visit',
      BookingType.homeCollection => 'Home Collect',
      BookingType.homeTestKit => 'Test Kit',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}
