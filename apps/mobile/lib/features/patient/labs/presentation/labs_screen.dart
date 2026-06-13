import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/lab_models.dart';
import '../data/public_repository.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';

// Active filter state
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
    ref.read(_labsFilterProvider.notifier).state =
        LabsFilter(q: q.isEmpty ? null : q);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(_labsFilterProvider);
    final labsAsync = ref.watch(labsListProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Lab'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Search labs or services…',
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filters',
            onPressed: () => _showFilters(context, filter),
          ),
        ],
      ),
      body: labsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labsListProvider(filter)),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return const EmptyState(
              icon: Icons.science_outlined,
              message: 'No labs found',
              subtitle: 'Try adjusting your search or filters',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(labsListProvider(filter)),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: data.items.length,
              itemBuilder: (context, i) =>
                  _LabCard(lab: data.items[i]),
            ),
          );
        },
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

class _LabCard extends StatelessWidget {
  final PublicLabCard lab;

  const _LabCard({required this.lab});

  @override
  Widget build(BuildContext context) {
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
                              label: 'From ${lab.startingFromEgp} EGP'),
                        if (lab.homeCollection)
                          _Chip(
                              icon: Icons.home_outlined,
                              label: 'Home collection'),
                        if (lab.distanceKm != null)
                          _Chip(
                              icon: Icons.location_on_outlined,
                              label:
                                  '${lab.distanceKm!.toStringAsFixed(1)} km'),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _sortChip('Best rating', 'rating'),
              _sortChip('Lowest price', 'price'),
              _sortChip('Nearest', 'distance'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Home collection only'),
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
              child: const Text('Apply'),
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
