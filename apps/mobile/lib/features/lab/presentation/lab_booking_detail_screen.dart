import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../application/lab_workspace_provider.dart';
import '../data/lab_repository.dart';
import '../data/lab_workspace_models.dart';
import '../../patient/booking/data/booking_models.dart';

class LabBookingDetailScreen extends ConsumerStatefulWidget {
  const LabBookingDetailScreen({
    super.key,
    required this.bookingId,
    this.initial,
  });

  final String bookingId;
  final LabBookingItem? initial;

  @override
  ConsumerState<LabBookingDetailScreen> createState() =>
      _LabBookingDetailScreenState();
}

class _LabBookingDetailScreenState
    extends ConsumerState<LabBookingDetailScreen> {
  bool _loading = false;

  LabBookingItem? get _booking {
    final workspace = ref.watch(labWorkspaceProvider).valueOrNull;
    if (workspace != null) {
      try {
        return workspace.bookings
            .firstWhere((b) => b.id == widget.bookingId);
      } catch (_) {}
    }
    return widget.initial;
  }

  Future<void> _setStatus(BookingStatus status) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(labRepositoryProvider)
          .setBookingStatus(widget.bookingId, status);
      ref.invalidate(labWorkspaceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Booking ${status == BookingStatus.confirmed ? 'confirmed' : 'rejected'}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _advanceKitStatus(KitStatus current) async {
    final next = _nextKitStatus(current);
    if (next == null) return;

    String? trackingNumber;
    if (next == KitStatus.shipped) {
      trackingNumber = await _promptTracking();
      if (trackingNumber == null) return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(labRepositoryProvider).updateKitStatus(
            widget.bookingId,
            next,
            trackingNumber: trackingNumber,
          );
      ref.invalidate(labWorkspaceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kit status updated to ${_kitLabel(next)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markResultDelivered() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(labRepositoryProvider)
          .setResultStatus(widget.bookingId, 'Delivered');
      ref.invalidate(labWorkspaceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result marked as delivered')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _promptTracking() async {
    String? value;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Tracking Number'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter tracking number (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                value = controller.text.trim().isNotEmpty
                    ? controller.text.trim()
                    : null;
                Navigator.pop(ctx);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return value ?? '';
  }

  KitStatus? _nextKitStatus(KitStatus current) {
    const order = [
      KitStatus.awaitingShipment,
      KitStatus.shipped,
      KitStatus.delivered,
      KitStatus.sampleReceived,
    ];
    final idx = order.indexOf(current);
    if (idx < 0 || idx >= order.length - 1) return null;
    return order[idx + 1];
  }

  String _kitLabel(KitStatus s) {
    switch (s) {
      case KitStatus.awaitingShipment:
        return 'Awaiting Shipment';
      case KitStatus.shipped:
        return 'Shipped';
      case KitStatus.delivered:
        return 'Delivered';
      case KitStatus.sampleReceived:
        return 'Sample Received';
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final scheduled = DateTime.tryParse(booking.scheduledAt);
    final dateStr = scheduled != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(scheduled.toLocal())
        : booking.scheduledAt;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Patient card
          _SectionCard(
            title: 'Patient',
            children: [
              _InfoRow(label: 'Name', value: booking.patient.fullName ?? '—'),
              _InfoRow(label: 'Phone', value: booking.patient.phone ?? '—'),
            ],
          ),
          const SizedBox(height: 12),

          // Booking details
          _SectionCard(
            title: 'Booking',
            children: [
              _InfoRow(label: 'Test', value: booking.test.name),
              _InfoRow(label: 'Scheduled', value: dateStr),
              _InfoRow(label: 'Type', value: _typeLabel(booking.bookingType)),
              _InfoRow(label: 'Status', value: booking.status.name.toUpperCase()),
              _InfoRow(
                  label: 'Amount', value: 'EGP ${booking.totalPriceEgp}'),
              _InfoRow(
                  label: 'Payment',
                  value: _paymentLabel(booking.paymentMethod)),
              _InfoRow(
                  label: 'Payment Status',
                  value: booking.paymentStatus.name.toUpperCase()),
              if (booking.homeAddress != null)
                _InfoRow(label: 'Address', value: booking.homeAddress!),
            ],
          ),
          const SizedBox(height: 12),

          // Kit status (HomeTestKit only)
          if (booking.bookingType == BookingType.homeTestKit) ...[
            _SectionCard(
              title: 'Kit Status',
              children: [
                _InfoRow(
                    label: 'Status',
                    value: _kitLabel(
                        booking.kitStatus ?? KitStatus.awaitingShipment)),
                if (booking.kitTrackingNumber != null)
                  _InfoRow(
                      label: 'Tracking', value: booking.kitTrackingNumber!),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Timeline
          if (booking.timeline.isNotEmpty) ...[
            _SectionCard(
              title: 'Timeline',
              children: booking.timeline
                  .map((e) => _TimelineRow(entry: e))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Actions
          _ActionsCard(
            booking: booking,
            loading: _loading,
            onConfirm: () => _setStatus(BookingStatus.confirmed),
            onReject: () => _setStatus(BookingStatus.rejected),
            onAdvanceKit: () => _advanceKitStatus(
                booking.kitStatus ?? KitStatus.awaitingShipment),
            onMarkDelivered: _markResultDelivered,
            nextKitStatus: booking.kitStatus != null
                ? _nextKitStatus(booking.kitStatus!)
                : null,
            kitLabel: _kitLabel,
          ),
        ],
      ),
    );
  }

  String _typeLabel(BookingType t) {
    switch (t) {
      case BookingType.labVisit:
        return 'Lab Visit';
      case BookingType.homeCollection:
        return 'Home Collection';
      case BookingType.homeTestKit:
        return 'Home Test Kit';
    }
  }

  String _paymentLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.cashLabVisit:
        return 'Cash (Lab Visit)';
      case PaymentMethod.cashHomeCollection:
        return 'Cash (Home Collection)';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.booking,
    required this.loading,
    required this.onConfirm,
    required this.onReject,
    required this.onAdvanceKit,
    required this.onMarkDelivered,
    required this.nextKitStatus,
    required this.kitLabel,
  });

  final LabBookingItem booking;
  final bool loading;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onAdvanceKit;
  final VoidCallback onMarkDelivered;
  final KitStatus? nextKitStatus;
  final String Function(KitStatus) kitLabel;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (booking.status == BookingStatus.pending) {
      actions.add(FilledButton.icon(
        onPressed: loading ? null : onConfirm,
        icon: const Icon(Icons.check),
        label: const Text('Confirm'),
      ));
      actions.add(const SizedBox(height: 8));
      actions.add(OutlinedButton.icon(
        onPressed: loading ? null : onReject,
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        icon: const Icon(Icons.close),
        label: const Text('Reject'),
      ));
    }

    if (booking.bookingType == BookingType.homeTestKit &&
        nextKitStatus != null &&
        booking.status == BookingStatus.confirmed) {
      actions.add(const SizedBox(height: 8));
      actions.add(FilledButton.icon(
        onPressed: loading ? null : onAdvanceKit,
        icon: const Icon(Icons.local_shipping),
        label: Text('Mark as ${kitLabel(nextKitStatus!)}'),
      ));
    }

    if (booking.status == BookingStatus.confirmed &&
        booking.bookingType != BookingType.homeTestKit) {
      actions.add(const SizedBox(height: 8));
      actions.add(OutlinedButton.icon(
        onPressed: loading ? null : onMarkDelivered,
        icon: const Icon(Icons.assignment_turned_in),
        label: const Text('Mark Result Delivered'),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Actions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              ...actions,
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry});
  final LabBookingTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final ts = DateTime.tryParse(entry.createdAt);
    final dateStr = ts != null
        ? DateFormat('dd MMM, HH:mm').format(ts.toLocal())
        : entry.createdAt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.status.name.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12)),
                if (entry.note != null)
                  Text(entry.note!,
                      style: Theme.of(context).textTheme.bodySmall),
                Text(dateStr,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
