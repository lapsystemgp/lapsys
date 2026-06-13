import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../workspace/application/workspace_provider.dart';
import '../../workspace/data/workspace_models.dart';
import '../../booking/data/booking_models.dart';
import '../../booking/data/booking_repository.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final WorkspaceBooking? initial;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    this.initial,
  });

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  WorkspaceBooking? _booking;
  bool _cancelling = false;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _booking = widget.initial;
    if (_booking == null) _loadFromWorkspace();
  }

  void _loadFromWorkspace() {
    final workspace = ref.read(workspaceProvider).valueOrNull;
    if (workspace != null) {
      _booking = [...workspace.bookings.upcoming, ...workspace.bookings.past]
          .cast<WorkspaceBooking?>()
          .firstWhere(
            (b) => b?.id == widget.bookingId,
            orElse: () => null,
          );
    }
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(widget.bookingId);
      ref.invalidate(workspaceProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Cancel failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _retryPayment() async {
    setState(() => _paying = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .demoPayment(widget.bookingId, 'success');
      ref.invalidate(workspaceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Try to find the latest version from workspace
    final workspace = ref.watch(workspaceProvider).valueOrNull;
    if (workspace != null) {
      final fresh = [
        ...workspace.bookings.upcoming,
        ...workspace.bookings.past
      ].cast<WorkspaceBooking?>().firstWhere(
            (b) => b?.id == widget.bookingId,
            orElse: () => null,
          );
      if (fresh != null) _booking = fresh;
    }

    final booking = _booking;

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Detail')),
        body: const LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(booking: booking),
          const SizedBox(height: 12),
          if (booking.kitStatus != null) ...[
            _KitTrackingCard(booking: booking),
            const SizedBox(height: 12),
          ],
          _TimelineCard(entries: booking.timeline),
          const SizedBox(height: 24),
          if (booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.confirmed) ...[
            if (_cancelling)
              const Center(child: CircularProgressIndicator())
            else
              OutlinedButton.icon(
                onPressed: _cancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Booking'),
              ),
          ],
          if (booking.paymentStatus == PaymentStatus.failed) ...[
            const SizedBox(height: 12),
            if (_paying)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: _retryPayment,
                icon: const Icon(Icons.payment),
                label: const Text('Retry Payment'),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final WorkspaceBooking booking;

  const _InfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, d MMMM yyyy')
        .format(DateTime.parse(booking.scheduledAt).toLocal());
    final time = DateFormat('h:mm a')
        .format(DateTime.parse(booking.scheduledAt).toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(booking.test.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                _statusBadge(context, booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(booking.lab.name,
                style: Theme.of(context).textTheme.bodyMedium),
            Text(booking.lab.address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline)),
            const Divider(height: 24),
            _row(context, 'Date', date),
            _row(context, 'Time', time),
            _row(context, 'Type', _typeLabel(booking.bookingType)),
            if (booking.homeAddress != null)
              _row(context, 'Address', booking.homeAddress!),
            _row(context, 'Payment', _paymentLabel(booking.paymentMethod)),
            _row(context, 'Pay status', _payStatusLabel(booking.paymentStatus)),
            _row(context, 'Total', '${booking.totalPriceEgp} EGP'),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext ctx, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: Theme.of(ctx)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Theme.of(ctx).colorScheme.outline)),
          ),
          Expanded(child: Text(value, style: Theme.of(ctx).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context, BookingStatus status) {
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
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  String _typeLabel(BookingType t) {
    return switch (t) {
      BookingType.labVisit => 'Lab Visit',
      BookingType.homeCollection => 'Home Collection',
      BookingType.homeTestKit => 'Home Test Kit',
    };
  }

  String _paymentLabel(PaymentMethod m) {
    return switch (m) {
      PaymentMethod.online => 'Online',
      PaymentMethod.cashLabVisit => 'Cash at lab',
      PaymentMethod.cashHomeCollection => 'Cash on collection',
      PaymentMethod.cashOnDelivery => 'Cash on delivery',
    };
  }

  String _payStatusLabel(PaymentStatus s) {
    return switch (s) {
      PaymentStatus.pending => 'Pending',
      PaymentStatus.paid => 'Paid',
      PaymentStatus.failed => 'Failed',
      PaymentStatus.refunded => 'Refunded',
    };
  }
}

class _KitTrackingCard extends StatelessWidget {
  final WorkspaceBooking booking;

  const _KitTrackingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('AwaitingShipment', 'Awaiting shipment', KitStatus.awaitingShipment),
      ('Shipped', 'Kit shipped', KitStatus.shipped),
      ('Delivered', 'Kit delivered', KitStatus.delivered),
      ('SampleReceived', 'Sample received', KitStatus.sampleReceived),
    ];

    final currentIndex = steps.indexWhere((s) => s.$3 == booking.kitStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined),
                const SizedBox(width: 8),
                Text('Kit Tracking',
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            if (booking.kitTrackingNumber != null) ...[
              const SizedBox(height: 4),
              Text('Tracking #${booking.kitTrackingNumber}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.outline)),
            ],
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final i = entry.key;
              final (_, label, _) = entry.value;
              final isCompleted = i <= currentIndex;
              return Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: isCompleted
                        ? Colors.green
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      style: TextStyle(
                        color: isCompleted
                            ? null
                            : Theme.of(context).colorScheme.outline,
                      )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final List<WorkspaceTimelineEntry> entries;

  const _TimelineCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status History',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            ...entries.reversed.map((e) {
              final dt = DateTime.tryParse(e.createdAt);
              final formatted = dt != null
                  ? DateFormat('d MMM · h:mm a').format(dt.toLocal())
                  : e.createdAt;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.status,
                              style: Theme.of(context).textTheme.labelMedium),
                          if (e.note != null)
                            Text(e.note!,
                                style: Theme.of(context).textTheme.bodySmall),
                          Text(formatted,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
