import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../application/booking_flow_notifier.dart';
import '../data/booking_models.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class BookingFlowScreen extends ConsumerWidget {
  final BookingFlowParams params;

  const BookingFlowScreen({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(bookingFlowProvider(params));
    final notifier = ref.read(bookingFlowProvider(params).notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(l10n, flow.step)),
        leading: flow.step == BookingStep.type
            ? const BackButton()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: notifier.back,
              ),
      ),
      body: _buildStep(context, ref, flow, notifier),
    );
  }

  String _stepTitle(AppLocalizations l10n, BookingStep step) {
    return switch (step) {
      BookingStep.type => l10n.chooseBookingType,
      BookingStep.slot => l10n.chooseTimeSlot,
      BookingStep.address => l10n.enterHomeAddress,
      BookingStep.payment => l10n.paymentMethod,
      BookingStep.confirm => l10n.confirmBookingStep,
      BookingStep.submitting => l10n.processingEllipsis,
      BookingStep.done => l10n.bookingConfirmedBang,
      BookingStep.error => l10n.bookingFailed,
    };
  }

  Widget _buildStep(BuildContext context, WidgetRef ref,
      BookingFlowState flow, BookingFlowNotifier notifier) {
    return switch (flow.step) {
      BookingStep.type => _TypeStep(params: params, notifier: notifier),
      BookingStep.slot => _SlotStep(flow: flow, notifier: notifier),
      BookingStep.address => _AddressStep(flow: flow, notifier: notifier),
      BookingStep.payment => _PaymentStep(flow: flow, notifier: notifier),
      BookingStep.confirm =>
        _ConfirmStep(flow: flow, notifier: notifier, context: context),
      BookingStep.submitting => const LoadingIndicator(),
      BookingStep.done => _DoneStep(flow: flow),
      BookingStep.error =>
        _ErrorStep(flow: flow, notifier: notifier),
    };
  }
}

// ─── Step: type ───────────────────────────────────────────────────────────────

class _TypeStep extends StatelessWidget {
  final BookingFlowParams params;
  final BookingFlowNotifier notifier;

  const _TypeStep({required this.params, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BookingSummaryCard(params: params),
        const SizedBox(height: 16),
        Text(l10n.howToTakeTest,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _TypeOption(
          icon: Icons.local_hospital_outlined,
          title: l10n.labVisit,
          subtitle: l10n.visitLabInPerson,
          onTap: () => notifier.selectType(BookingType.labVisit),
        ),
        if (params.supportsHomeCollection)
          _TypeOption(
            icon: Icons.home_outlined,
            title: l10n.homeCollection,
            subtitle: l10n.phlebotomistVisitsHome,
            onTap: () => notifier.selectType(BookingType.homeCollection),
          ),
        if (params.supportsHomeTestKit)
          _TypeOption(
            icon: Icons.local_shipping_outlined,
            title: l10n.homeTestKit,
            subtitle: l10n.kitShippedSelfCollect,
            onTap: () => notifier.selectType(BookingType.homeTestKit),
          ),
      ],
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ─── Step: slot ───────────────────────────────────────────────────────────────

class _SlotStep extends StatelessWidget {
  final BookingFlowState flow;
  final BookingFlowNotifier notifier;

  const _SlotStep({required this.flow, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (flow.slotsLoading) return const LoadingIndicator();

    if (flow.slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 48),
            const SizedBox(height: 12),
            Text(l10n.noSlotsAvailable7Days),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: notifier.skipSlot,
              child: Text(l10n.continueWithoutSlot),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flow.slots.length,
      itemBuilder: (context, i) {
        final slot = flow.slots[i];
        final start = DateTime.parse(slot.startsAt).toLocal();
        final formatted = DateFormat('EEE d MMM · h:mm a').format(start);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(formatted),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => notifier.selectSlot(slot),
          ),
        );
      },
    );
  }
}

// ─── Step: address ────────────────────────────────────────────────────────────

class _AddressStep extends StatefulWidget {
  final BookingFlowState flow;
  final BookingFlowNotifier notifier;

  const _AddressStep({required this.flow, required this.notifier});

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.flow.homeAddress ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.enterAddressForService),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ctrl,
            decoration: InputDecoration(
              labelText: l10n.homeAddressLabel,
              hintText: l10n.streetApartmentCityHint,
              prefixIcon: const Icon(Icons.home_outlined),
            ),
            maxLines: 3,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.addressRequired : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.notifier.submitAddress(_ctrl.text.trim());
              }
            },
            child: Text(l10n.continueAction),
          ),
        ],
      ),
    );
  }
}

// ─── Step: payment ────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  final BookingFlowState flow;
  final BookingFlowNotifier notifier;

  const _PaymentStep({required this.flow, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final type = flow.selectedType;
    final options = [
      PaymentMethod.online,
      if (type == BookingType.labVisit) PaymentMethod.cashLabVisit,
      if (type == BookingType.homeCollection) PaymentMethod.cashHomeCollection,
      if (type == BookingType.homeTestKit) PaymentMethod.cashOnDelivery,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: options.map((m) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(_paymentIcon(m)),
            title: Text(_paymentLabel(l10n, m)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => notifier.selectPayment(m),
          ),
        );
      }).toList(),
    );
  }

  IconData _paymentIcon(PaymentMethod m) => m == PaymentMethod.online
      ? Icons.credit_card
      : Icons.payments_outlined;

  String _paymentLabel(AppLocalizations l10n, PaymentMethod m) => switch (m) {
        PaymentMethod.online => l10n.paymentOnlineDemo,
        PaymentMethod.cashLabVisit => l10n.paymentCashAtLab,
        PaymentMethod.cashHomeCollection => l10n.paymentCashOnCollection,
        PaymentMethod.cashOnDelivery => l10n.paymentCashOnDelivery,
      };
}

// ─── Step: confirm ────────────────────────────────────────────────────────────

class _ConfirmStep extends StatelessWidget {
  final BookingFlowState flow;
  final BookingFlowNotifier notifier;
  final BuildContext context;

  const _ConfirmStep({
    required this.flow,
    required this.notifier,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    final p = flow.params;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BookingSummaryCard(params: p),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(l10n.typeLabel, _typeLabel(l10n, flow.selectedType)),
                if (flow.selectedSlot != null)
                  _Row(
                    l10n.slot,
                    DateFormat('EEE d MMM · h:mm a').format(
                        DateTime.parse(flow.selectedSlot!.startsAt).toLocal()),
                  ),
                if (flow.homeAddress != null)
                  _Row(l10n.address, flow.homeAddress!),
                _Row(l10n.payment, _paymentLabel(l10n, flow.selectedPayment)),
                _Row(l10n.total, '${p.priceEgp} EGP'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: notifier.confirm,
          child: Text(l10n.confirmBookingButton),
        ),
      ],
    );
  }

  String _typeLabel(AppLocalizations l10n, BookingType? t) => switch (t) {
        BookingType.labVisit => l10n.labVisit,
        BookingType.homeCollection => l10n.homeCollection,
        BookingType.homeTestKit => l10n.homeTestKit,
        null => '—',
      };

  String _paymentLabel(AppLocalizations l10n, PaymentMethod? m) => switch (m) {
        PaymentMethod.online => l10n.paymentOnlineDemo,
        PaymentMethod.cashLabVisit => l10n.paymentCashAtLab,
        PaymentMethod.cashHomeCollection => l10n.paymentCashOnCollection,
        PaymentMethod.cashOnDelivery => l10n.paymentCashOnDelivery,
        null => '—',
      };
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ─── Step: done ───────────────────────────────────────────────────────────────

class _DoneStep extends StatelessWidget {
  final BookingFlowState flow;

  const _DoneStep({required this.flow});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(l10n.bookingConfirmedBang,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.bookingCreatedFor(flow.params.testName, flow.params.labName),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/patient/bookings'),
              child: Text(l10n.viewMyBookings),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/patient'),
              child: Text(l10n.backToLabs),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step: error ──────────────────────────────────────────────────────────────

class _ErrorStep extends StatelessWidget {
  final BookingFlowState flow;
  final BookingFlowNotifier notifier;

  const _ErrorStep({required this.flow, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(l10n.bookingFailed,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(flow.errorMessage ?? 'An error occurred.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: notifier.back,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared summary card ──────────────────────────────────────────────────────

class _BookingSummaryCard extends StatelessWidget {
  final BookingFlowParams params;

  const _BookingSummaryCard({required this.params});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(params.testName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(params.labName,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer)),
            const SizedBox(height: 8),
            Text('${params.priceEgp} EGP',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(color: theme.colorScheme.primary)),
            if (params.preparation != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(l10n.prepLabel(params.preparation!),
                        style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
