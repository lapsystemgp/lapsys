import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.cancelFailed(e.toString()))));
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentSuccessful)),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.paymentFailedMsg(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        appBar: AppBar(title: Text(l10n.bookingDetail)),
        body: const LoadingIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetail)),
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
                label: Text(l10n.cancelBooking),
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
                label: Text(l10n.retryPayment),
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
    final l10n = AppLocalizations.of(context)!;
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
                _statusBadge(context, booking.status, l10n),
              ],
            ),
            const SizedBox(height: 4),
            Text(booking.lab.name,
                style: Theme.of(context).textTheme.bodyMedium),
            Text(booking.lab.address,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline)),
            const Divider(height: 24),
            _row(context, l10n.date, date),
            _row(context, l10n.time, time),
            _row(context, l10n.typeLabel, _typeLabel(booking.bookingType, l10n)),
            if (booking.homeAddress != null)
              _row(context, l10n.address, booking.homeAddress!),
            _row(context, l10n.payment, _paymentLabel(booking.paymentMethod, l10n)),
            _row(context, l10n.payStatus, _payStatusLabel(booking.paymentStatus, l10n)),
            _row(context, l10n.total, '${booking.totalPriceEgp} EGP'),
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

  Widget _statusBadge(BuildContext context, BookingStatus status, AppLocalizations l10n) {
    final (label, color) = switch (status) {
      BookingStatus.pending => (l10n.statusPending, Colors.orange),
      BookingStatus.confirmed => (l10n.statusConfirmed, Colors.blue),
      BookingStatus.completed => (l10n.statusCompleted, Colors.green),
      BookingStatus.cancelled => (l10n.statusCancelled, Colors.grey),
      BookingStatus.rejected => (l10n.statusRejected, Colors.red),
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

  String _typeLabel(BookingType t, AppLocalizations l10n) {
    return switch (t) {
      BookingType.labVisit => l10n.labVisit,
      BookingType.homeCollection => l10n.homeCollection,
      BookingType.homeTestKit => l10n.homeTestKit,
    };
  }

  String _paymentLabel(PaymentMethod m, AppLocalizations l10n) {
    return switch (m) {
      PaymentMethod.online => l10n.paymentOnlineDemo,
      PaymentMethod.cashLabVisit => l10n.paymentCashAtLab,
      PaymentMethod.cashHomeCollection => l10n.paymentCashOnCollection,
      PaymentMethod.cashOnDelivery => l10n.paymentCashOnDelivery,
    };
  }

  String _payStatusLabel(PaymentStatus s, AppLocalizations l10n) {
    return switch (s) {
      PaymentStatus.pending => l10n.payStatusPending,
      PaymentStatus.paid => l10n.payStatusPaid,
      PaymentStatus.failed => l10n.payStatusFailed,
      PaymentStatus.refunded => l10n.payStatusRefunded,
    };
  }
}

class _KitTrackingCard extends StatelessWidget {
  final WorkspaceBooking booking;

  const _KitTrackingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      ('AwaitingShipment', l10n.awaitingShipment, KitStatus.awaitingShipment),
      ('Shipped', l10n.kitShipped, KitStatus.shipped),
      ('Delivered', l10n.kitDelivered, KitStatus.delivered),
      ('SampleReceived', l10n.sampleReceived, KitStatus.sampleReceived),
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
                Text(l10n.kitTracking,
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            if (booking.kitTrackingNumber != null) ...[
              const SizedBox(height: 4),
              Text(l10n.trackingNumber(booking.kitTrackingNumber!),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statusHistory,
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
