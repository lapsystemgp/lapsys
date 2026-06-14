import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../workspace/application/workspace_provider.dart';
import '../../workspace/data/workspace_models.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/empty_state.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final resultsAsync = ref.watch(resultsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myResults)),
      body: resultsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(workspaceProvider),
        ),
        data: (results) {
          if (results.isEmpty) {
            return EmptyState(
              icon: Icons.science_outlined,
              message: l10n.noResultsYet,
              subtitle: l10n.completedTestsWillAppear,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(workspaceProvider),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length,
              itemBuilder: (context, i) => _ResultCard(result: results[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final WorkspaceResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final date = DateFormat('d MMM yyyy')
        .format(DateTime.parse(result.scheduledAt).toLocal());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push('/patient/results/${result.bookingId}', extra: result),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(result.testName,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  _ResultStatusBadge(status: result.resultStatus),
                ],
              ),
              const SizedBox(height: 4),
              Text(result.labName,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 4),
                  Text(date, style: theme.textTheme.bodySmall),
                  const Spacer(),
                  if (result.hasStructuredData)
                    Chip(
                      label: Text(l10n.resultStatusStructured),
                      avatar: const Icon(Icons.analytics, size: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (result.file != null)
                    const Icon(Icons.picture_as_pdf, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStatusBadge extends StatelessWidget {
  final ResultStatus status;

  const _ResultStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (status) {
      ResultStatus.pending => (l10n.resultStatusPending, Colors.orange),
      ResultStatus.uploaded => (l10n.resultStatusUploaded, Colors.blue),
      ResultStatus.delivered => (l10n.resultStatusDelivered, Colors.green),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
