import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/lab_models.dart';
import '../data/public_repository.dart';
import '../../../../core/location/location_service.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';

// Shared search text, used by BOTH the Tests and Labs tabs.
final _searchQueryProvider = StateProvider<String>((_) => '');

// Labs-tab-only filters (sort / home collection). The query is merged in
// from [_searchQueryProvider] when the request is built.
final _labsFilterProvider = StateProvider<LabsFilter>(
  (_) => const LabsFilter(),
);

class LabsScreen extends ConsumerStatefulWidget {
  const LabsScreen({super.key});

  @override
  ConsumerState<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends ConsumerState<LabsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applySearch(String q) {
    ref.read(_searchQueryProvider.notifier).state = q;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(_labsFilterProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.findTestOrLab),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: l10n.labFilters,
              onPressed: () => _showFilters(context, filter),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(104),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: SearchBar(
                    controller: _searchCtrl,
                    hintText: l10n.searchHint,
                    leading: const Icon(Icons.search),
                    trailing: [
                      if (_searchCtrl.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _applySearch('');
                          },
                        ),
                    ],
                    onChanged: _applySearch,
                  ),
                ),
                TabBar(
                  tabs: [
                    Tab(text: l10n.testsTab),
                    Tab(text: l10n.labsTab),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _TestsTabView(),
            _LabsTabView(),
          ],
        ),
      ),
    );
  }

  void _showFilters(BuildContext context, LabsFilter current) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _FiltersSheet(current: current),
    );
  }
}

// ─── Tests tab — searches medical tests, opens nearest-labs detail ───────────

class _TestsTabView extends ConsumerWidget {
  const _TestsTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(_searchQueryProvider);
    final testsAsync = ref.watch(testsListProvider(query));

    return testsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(testsListProvider(query)),
      ),
      data: (data) {
        if (data.items.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            message: l10n.noTestsFound,
            subtitle: l10n.tryDifferentTestName,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(testsListProvider(query)),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.items.length,
            itemBuilder: (context, i) => _TestCard(test: data.items[i]),
          ),
        );
      },
    );
  }
}

class _TestCard extends StatelessWidget {
  final PublicTestCard test;

  const _TestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          '/patient/tests/${Uri.encodeComponent(test.name)}'
          '?category=${Uri.encodeComponent(test.category)}',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
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
                    Text(test.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(test.category,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (test.minPriceEgp != null)
                          _Chip(
                              icon: Icons.payments_outlined,
                              label: l10n.fromPriceEgp(test.minPriceEgp.toString())),
                        _Chip(
                            icon: Icons.science_outlined,
                            label: l10n.labCount(test.labCount)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Labs tab — searches lab facilities (the original behaviour) ─────────────

class _LabsTabView extends ConsumerWidget {
  const _LabsTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final query = ref.watch(_searchQueryProvider);
    final baseFilter = ref.watch(_labsFilterProvider);
    // Inject the user's location (when known) so the backend can return a
    // distanceKm per lab and honour the "Nearest" sort.
    final location = ref.watch(currentLocationProvider).valueOrNull;
    final filter = baseFilter.copyWith(
      q: query.isEmpty ? null : query,
      userLat: location?.lat,
      userLng: location?.lng,
    );
    final labsAsync = ref.watch(labsListProvider(filter));

    return labsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(labsListProvider(filter)),
      ),
      data: (data) {
        if (data.items.isEmpty) {
          return EmptyState(
            icon: Icons.science_outlined,
            message: l10n.noLabsFound,
            subtitle: l10n.tryAdjustingFilters,
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(labsListProvider(filter)),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: data.items.length,
            itemBuilder: (context, i) => _LabCard(lab: data.items[i]),
          ),
        );
      },
    );
  }
}

class _LabCard extends StatelessWidget {
  final PublicLabCard lab;

  const _LabCard({required this.lab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/patient/labs/${lab.id}', extra: lab),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emoji avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    lab.imageEmoji ?? '🔬',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lab.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      lab.address,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (lab.rating != null)
                          _Chip(
                              icon: Icons.star_rounded,
                              label:
                                  '${lab.rating!.toStringAsFixed(1)} (${lab.reviews})'),
                        if (lab.startingFromEgp != null)
                          _Chip(
                              icon: Icons.payments_outlined,
                              label: l10n.startingFromEgp(lab.startingFromEgp!)),
                        if (lab.homeCollection)
                          _Chip(
                              icon: Icons.home_outlined,
                              label: l10n.homeCollection),
                        if (lab.distanceKm != null)
                          _Chip(
                              icon: Icons.location_on_outlined,
                              label: l10n.distanceKm(lab.distanceKm!.toStringAsFixed(1))),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.primary),
        const SizedBox(width: 3),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.primary)),
      ],
    );
  }
}

class _FiltersSheet extends ConsumerStatefulWidget {
  final LabsFilter current;

  const _FiltersSheet({required this.current});

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  late String? _sort;
  late bool _homeOnly;

  @override
  void initState() {
    super.initState();
    _sort = widget.current.sort;
    _homeOnly = widget.current.homeCollectionOnly;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sortBy, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _sortChip(l10n.bestRating, 'rating'),
              _sortChip(l10n.lowestPrice, 'price'),
              _sortChip(l10n.nearest, 'distance'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.homeCollectionOnly),
            value: _homeOnly,
            onChanged: (v) => setState(() => _homeOnly = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ref.read(_labsFilterProvider.notifier).state =
                    LabsFilter(sort: _sort, homeCollectionOnly: _homeOnly);
                Navigator.pop(context);
              },
              child: Text(l10n.apply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _sort == value,
      onSelected: (v) => setState(() => _sort = v ? value : null),
    );
  }
}
