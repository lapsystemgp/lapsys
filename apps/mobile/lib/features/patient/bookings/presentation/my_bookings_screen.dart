import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../workspace/application/workspace_provider.dart';
import '../../workspace/data/workspace_models.dart';
import '../../booking/data/booking_models.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Upcoming')),
                ButtonSegment(value: 1, label: Text('Past')),
              ],
              selected: {_selectedIndex},
              onSelectionChanged: (s) => setState(() => _selectedIndex = s.first),
            ),
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? _BookingsList(
              source: ref.watch(upcomingBookingsProvider),
              emptyMessage: 'No upcoming bookings',
              onRefresh: () => ref.invalidate(workspaceProvider),
            )
          : _BookingsList(
              source: ref.watch(pastBookingsProvider),
              emptyMessage: 'No past bookings',
              onRefresh: () => ref.invalidate(workspaceProvider),
            ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final AsyncValue<List<WorkspaceBooking>> source;
  final String emptyMessage;
  final VoidCallback onRefresh;

  const _BookingsList({
    required this.source,
    required this.emptyMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return source.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(error: e, onRetry: onRefresh),
      data: (bookings) {
        if (bookings.isEmpty) {
          return EmptyState(
            icon: Icons.calendar_today_outlined,
            message: emptyMessage,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: bookings.length,
            itemBuilder: (context, i) =>
                _BookingCard(booking: bookings[i]),
          ),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final WorkspaceBooking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('d MMM yyyy · h:mm a')
        .format(DateTime.parse(booking.scheduledAt).toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/patient/bookings/${booking.id}', extra: booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(booking.test.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(booking.lab.name,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14),
                  const SizedBox(width: 4),
                  Text(date, style: theme.textTheme.bodySmall),
                  const Spacer(),
                  Text('${booking.totalPriceEgp} EGP',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      BookingStatus.pending => ('Pending', Colors.orange),
      BookingStatus.confirmed => ('Confirmed', Colors.blue),
      BookingStatus.completed => ('Completed', Colors.green),
      BookingStatus.cancelled => ('Cancelled', Colors.grey),
      BookingStatus.rejected => ('Rejected', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
