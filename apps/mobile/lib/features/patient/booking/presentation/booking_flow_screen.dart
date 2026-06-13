import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(flow.step)),
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

  String _stepTitle(BookingStep step) {
    return switch (step) {
      BookingStep.type => 'Choose booking type',
      BookingStep.slot => 'Choose a time slot',
      BookingStep.address => 'Enter home address',
      BookingStep.payment => 'Payment method',
      BookingStep.confirm => 'Confirm booking',
      BookingStep.submitting => 'Processing…',
      BookingStep.done => 'Booking confirmed!',
      BookingStep.error => 'Booking failed',
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _BookingSummaryCard(params: params),
        const SizedBox(height: 16),
        Text('How would you like to take this test?',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _TypeOption(
          icon: Icons.local_hospital_outlined,
          title: 'Lab Visit',
          subtitle: 'Visit the lab in person',
          onTap: () => notifier.selectType(BookingType.labVisit),
        ),
        if (params.supportsHomeCollection)
          _TypeOption(
            icon: Icons.home_outlined,
            title: 'Home Collection',
            subtitle: 'A phlebotomist visits your home',
            onTap: () => notifier.selectType(BookingType.homeCollection),
          ),
        if (params.supportsHomeTestKit)
          _TypeOption(
            icon: Icons.local_shipping_outlined,
            title: 'Home Test Kit',
            subtitle: 'Kit shipped to you; self-collect sample',
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
    if (flow.slotsLoading) return const LoadingIndicator();

    if (flow.slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_busy, size: 48),
            const SizedBox(height: 12),
            const Text('No slots available in the next 7 days'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: notifier.skipSlot,
              child: const Text('Continue without a slot'),
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
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Enter the address for the service:'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Home address',
              hintText: 'Street, apartment, city…',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            maxLines: 3,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Address is required' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.notifier.submitAddress(_ctrl.text.trim());
              }
            },
            child: const Text('Continue'),
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
            title: Text(_paymentLabel(m)),
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

  String _paymentLabel(PaymentMethod m) => switch (m) {
        PaymentMethod.online => 'Online (demo)',
        PaymentMethod.cashLabVisit => 'Cash at lab',
        PaymentMethod.cashHomeCollection => 'Cash on collection',
        PaymentMethod.cashOnDelivery => 'Cash on delivery',
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
                _Row('Type', _typeLabel(flow.selectedType)),
                if (flow.selectedSlot != null)
                  _Row(
                    'Slot',
                    DateFormat('EEE d MMM · h:mm a').format(
                        DateTime.parse(flow.selectedSlot!.startsAt).toLocal()),
                  ),
                if (flow.homeAddress != null)
                  _Row('Address', flow.homeAddress!),
                _Row('Payment', _paymentLabel(flow.selectedPayment)),
                _Row('Total', '${p.priceEgp} EGP'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: notifier.confirm,
          child: const Text('Confirm Booking'),
        ),
      ],
    );
  }

  String _typeLabel(BookingType? t) => switch (t) {
        BookingType.labVisit => 'Lab Visit',
        BookingType.homeCollection => 'Home Collection',
        BookingType.homeTestKit => 'Home Test Kit',
        null => '—',
      };

  String _paymentLabel(PaymentMethod? m) => switch (m) {
        PaymentMethod.online => 'Online (demo)',
        PaymentMethod.cashLabVisit => 'Cash at lab',
        PaymentMethod.cashHomeCollection => 'Cash on collection',
        PaymentMethod.cashOnDelivery => 'Cash on delivery',
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text('Booking Confirmed!',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Your booking for ${flow.params.testName} at ${flow.params.labName} has been created.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/patient/bookings'),
              child: const Text('View My Bookings'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/patient'),
              child: const Text('Back to Labs'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text('Booking Failed',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(flow.errorMessage ?? 'An error occurred.',
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: notifier.back,
              child: const Text('Try Again'),
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
                    child: Text('Prep: ${params.preparation}',
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
