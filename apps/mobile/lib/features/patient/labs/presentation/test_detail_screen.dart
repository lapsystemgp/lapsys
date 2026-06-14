import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/location/location_service.dart';
import '../../booking/data/booking_models.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../data/lab_models.dart';
import '../data/public_repository.dart';

enum _Sort { nearest, price, rating }

/// Shows every lab that offers a given test, ranked by distance (when a
/// location fix is available) — the mobile twin of the web TestDetailClient.
class TestDetailScreen extends ConsumerStatefulWidget {
  final String testName;
  final String category;

  const TestDetailScreen({
    super.key,
    required this.testName,
    required this.category,
  });

  @override
  ConsumerState<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends ConsumerState<TestDetailScreen> {
  LatLng? _userLocation;
  _Sort _sort = _Sort.price;

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  Future<void> _resolveLocation({bool forceRetry = false}) async {
    // Reuse the session-cached fix so we don't prompt for permission twice.
    // On an explicit retry, drop the cache so the request runs again.
    if (forceRetry) ref.invalidate(currentLocationProvider);
    final loc = await ref.read(currentLocationProvider.future);
    if (!mounted || loc == null) return;
    setState(() {
      _userLocation = loc;
      // Once we know where the user is, default to the nearest-first view —
      // same behaviour as the web client.
      if (_sort == _Sort.price) _sort = _Sort.nearest;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = (name: widget.testName, category: widget.category);
    final offersAsync = ref.watch(testOffersProvider(key));

    return Scaffold(
      appBar: AppBar(title: Text(widget.testName)),
      body: offersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(testOffersProvider(key)),
        ),
        data: (data) => _buildContent(context, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TestOffersResponse data) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Compute distance for each lab when we have a fix.
    final labs = data.labs.map((lab) {
      double? km;
      if (_userLocation != null &&
          lab.latitude != null &&
          lab.longitude != null) {
        km = haversineKm(
          _userLocation!.lat,
          _userLocation!.lng,
          lab.latitude!,
          lab.longitude!,
        );
      }
      return (lab: lab, km: km);
    }).toList();

    final hasDistance = labs.any((e) => e.km != null);

    labs.sort((a, b) {
      switch (_sort) {
        case _Sort.nearest:
          final da = a.km ?? double.maxFinite;
          final db = b.km ?? double.maxFinite;
          if (da != db) return da.compareTo(db);
          return a.lab.priceEgp.compareTo(b.lab.priceEgp);
        case _Sort.rating:
          return (b.lab.rating ?? -1).compareTo(a.lab.rating ?? -1);
        case _Sort.price:
          return a.lab.priceEgp.compareTo(b.lab.priceEgp);
      }
    });

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // ── Test info card ──────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('🧪', style: TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.name, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(data.category,
                              style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (data.description != null) ...[
                  const SizedBox(height: 12),
                  Text(data.description!, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (data.turnaroundTime != null)
                      _MetaChip(
                          icon: Icons.schedule,
                          label: l10n.resultsIn(data.turnaroundTime!)),
                    if (data.parametersCount != null)
                      _MetaChip(
                          icon: Icons.menu_book_outlined,
                          label: l10n.parametersCount(data.parametersCount!)),
                    _MetaChip(
                        icon: Icons.science_outlined,
                        label: l10n.atLabsCount(data.labs.length)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── Sort selector ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(l10n.sortBy, style: theme.textTheme.labelLarge),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _sortChip(l10n.nearest, _Sort.nearest,
                          enabled: hasDistance),
                      const SizedBox(width: 6),
                      _sortChip(l10n.price, _Sort.price),
                      const SizedBox(width: 6),
                      _sortChip(l10n.rating, _Sort.rating),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!hasDistance)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Row(
              children: [
                Icon(Icons.location_off_outlined,
                    size: 14, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.enableLocationForSort,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
                TextButton(
                  onPressed: () => _resolveLocation(forceRetry: true),
                  child: Text(l10n.enable),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),

        // ── Labs offering this test ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text(l10n.labsOfferingTest(data.name),
              style: theme.textTheme.titleMedium),
        ),
        if (labs.isEmpty)
          EmptyState(
            icon: Icons.science_outlined,
            message: l10n.noLabsOfferTest,
          )
        else
          ...labs.map((e) => _OfferCard(
                offer: e.lab,
                distanceKm: e.km,
                testName: data.name,
                preparation: data.preparation,
              )),
      ],
    );
  }

  Widget _sortChip(String label, _Sort value, {bool enabled = true}) {
    return ChoiceChip(
      label: Text(label),
      selected: _sort == value,
      onSelected:
          enabled ? (v) => setState(() => _sort = v ? value : _sort) : null,
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.outline),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  final TestOfferLab offer;
  final double? distanceKm;
  final String testName;
  final String? preparation;

  const _OfferCard({
    required this.offer,
    required this.distanceKm,
    required this.testName,
    required this.preparation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(offer.labName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text('${offer.priceEgp} EGP',
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (distanceKm != null)
                  _InlineStat(
                    icon: Icons.navigation_outlined,
                    label: distanceKm! < 1
                        ? '${(distanceKm! * 1000).round()} m'
                        : '${distanceKm!.toStringAsFixed(1)} km',
                    color: theme.colorScheme.primary,
                  ),
                if (offer.rating != null)
                  _InlineStat(
                    icon: Icons.star_rounded,
                    label:
                        '${offer.rating!.toStringAsFixed(1)} (${offer.reviews})',
                  ),
                if (offer.accreditation != null)
                  _InlineStat(
                      icon: Icons.verified_outlined,
                      label: offer.accreditation!),
                if (offer.turnaroundTime != null)
                  _InlineStat(
                      icon: Icons.schedule, label: offer.turnaroundTime!),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 15, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(offer.address,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (offer.homeCollection || offer.homeTestKit) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (offer.homeCollection)
                    _InlineStat(
                      icon: Icons.home_outlined,
                      label: l10n.homeCollection,
                      color: Colors.green.shade700,
                    ),
                  if (offer.homeCollection && offer.homeTestKit)
                    const SizedBox(width: 12),
                  if (offer.homeTestKit)
                    _InlineStat(
                      icon: Icons.science_outlined,
                      label: l10n.homeTestKit,
                      color: Colors.green.shade700,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.push(
                      '/patient/labs/${offer.labId}',
                    ),
                    child: Text(l10n.viewLab),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push(
                      '/patient/book',
                      extra: BookingFlowParams(
                        labId: offer.labId,
                        testId: offer.labTestId,
                        labName: offer.labName,
                        testName: testName,
                        priceEgp: offer.priceEgp,
                        supportsHomeCollection: offer.homeCollection,
                        supportsHomeTestKit: offer.homeTestKit,
                        preparation: preparation,
                      ),
                    ),
                    child: Text(l10n.bookNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InlineStat({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.outline;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 3),
        Text(label,
            style: theme.textTheme.labelMedium?.copyWith(color: c)),
      ],
    );
  }
}
