import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bookingMarkedAs(
                status == BookingStatus.confirmed
                    ? l10n.statusConfirmed
                    : l10n.statusRejected)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedWithError(e.toString()))));
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.kitStatusUpdatedTo(_kitLabel(next, l10n)))),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedWithError(e.toString()))));
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.resultMarkedDelivered)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.failedWithError(e.toString()))));
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
        final l10n = AppLocalizations.of(context)!;
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(l10n.trackingNumberLabel),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.enterTrackingNumberOptional,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                value = controller.text.trim().isNotEmpty
                    ? controller.text.trim()
                    : null;
                Navigator.pop(ctx);
              },
              child: Text(l10n.confirm),
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

  String _kitLabel(KitStatus s, AppLocalizations l10n) {
    switch (s) {
      case KitStatus.awaitingShipment:
        return l10n.awaitingShipment;
      case KitStatus.shipped:
        return l10n.kitShipped;
      case KitStatus.delivered:
        return l10n.kitDelivered;
      case KitStatus.sampleReceived:
        return l10n.sampleReceived;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final booking = _booking;
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.bookingDetail)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final scheduled = DateTime.tryParse(booking.scheduledAt);
    final dateStr = scheduled != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(scheduled.toLocal())
        : booking.scheduledAt;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetail)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Patient card
          _SectionCard(
            title: l10n.rolePatient,
            children: [
              _InfoRow(label: l10n.fullName, value: booking.patient.fullName ?? '—'),
              _InfoRow(label: l10n.phone, value: booking.patient.phone ?? '—'),
            ],
          ),
          const SizedBox(height: 12),

          // Booking details
          _SectionCard(
            title: l10n.bookingDetail,
            children: [
              _InfoRow(label: l10n.typeLabel, value: booking.test.name),
              _InfoRow(label: l10n.date, value: dateStr),
              _InfoRow(label: l10n.typeLabel, value: _typeLabel(booking.bookingType, l10n)),
              _InfoRow(label: l10n.statusPending, value: booking.status.name.toUpperCase()),
              _InfoRow(
                  label: l10n.total, value: 'EGP ${booking.totalPriceEgp}'),
              _InfoRow(
                  label: l10n.payment,
                  value: _paymentLabel(booking.paymentMethod, l10n)),
              _InfoRow(
                  label: l10n.payStatus,
                  value: booking.paymentStatus.name.toUpperCase()),
              if (booking.homeAddress != null)
                _InfoRow(label: l10n.address, value: booking.homeAddress!),
            ],
          ),
          const SizedBox(height: 12),

          // Kit status (HomeTestKit only)
          if (booking.bookingType == BookingType.homeTestKit) ...[
            _SectionCard(
              title: l10n.kitTracking,
              children: [
                _InfoRow(
                    label: l10n.statusPending,
                    value: _kitLabel(
                        booking.kitStatus ?? KitStatus.awaitingShipment, l10n)),
                if (booking.kitTrackingNumber != null)
                  _InfoRow(
                      label: l10n.trackingNumber(booking.kitTrackingNumber!), value: booking.kitTrackingNumber!),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Timeline
          if (booking.timeline.isNotEmpty) ...[
            _SectionCard(
              title: l10n.statusHistory,
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

  String _typeLabel(BookingType t, AppLocalizations l10n) {
    switch (t) {
      case BookingType.labVisit:
        return l10n.labVisit;
      case BookingType.homeCollection:
        return l10n.homeCollection;
      case BookingType.homeTestKit:
        return l10n.homeTestKit;
    }
  }

  String _paymentLabel(PaymentMethod m, AppLocalizations l10n) {
    switch (m) {
      case PaymentMethod.online:
        return l10n.paymentOnlineDemo;
      case PaymentMethod.cashLabVisit:
        return l10n.paymentCashAtLab;
      case PaymentMethod.cashHomeCollection:
        return l10n.paymentCashOnCollection;
      case PaymentMethod.cashOnDelivery:
        return l10n.paymentCashOnDelivery;
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
  final String Function(KitStatus, AppLocalizations) kitLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[];

    if (booking.status == BookingStatus.pending) {
      actions.add(FilledButton.icon(
        onPressed: loading ? null : onConfirm,
        icon: const Icon(Icons.check),
        label: Text(l10n.statusConfirmed),
      ));
      actions.add(const SizedBox(height: 8));
      actions.add(OutlinedButton.icon(
        onPressed: loading ? null : onReject,
        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        icon: const Icon(Icons.close),
        label: Text(l10n.statusRejected),
      ));
    }

    if (booking.bookingType == BookingType.homeTestKit &&
        nextKitStatus != null &&
        booking.status == BookingStatus.confirmed) {
      actions.add(const SizedBox(height: 8));
      actions.add(FilledButton.icon(
        onPressed: loading ? null : onAdvanceKit,
        icon: const Icon(Icons.local_shipping),
        label: Text(l10n.markAs(kitLabel(nextKitStatus!, l10n))),
      ));
    }

    if (booking.status == BookingStatus.confirmed &&
        booking.bookingType != BookingType.homeTestKit) {
      actions.add(const SizedBox(height: 8));
      actions.add(OutlinedButton.icon(
        onPressed: loading ? null : onMarkDelivered,
        icon: const Icon(Icons.assignment_turned_in),
        label: Text(l10n.markResultDelivered),
      ));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.actions,
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
