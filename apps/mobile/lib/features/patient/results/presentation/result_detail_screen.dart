import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../workspace/application/workspace_provider.dart';
import '../../workspace/data/workspace_models.dart';
import '../../workspace/data/patient_repository.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class ResultDetailScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final WorkspaceResult? initial;

  const ResultDetailScreen({
    super.key,
    required this.bookingId,
    this.initial,
  });

  @override
  ConsumerState<ResultDetailScreen> createState() =>
      _ResultDetailScreenState();
}

class _ResultDetailScreenState extends ConsumerState<ResultDetailScreen> {
  bool _submittingReview = false;

  WorkspaceResult? _getResult() {
    final workspace = ref.read(workspaceProvider).valueOrNull;
    if (workspace != null) {
      final found = workspace.results
          .cast<WorkspaceResult?>()
          .firstWhere((x) => x?.bookingId == widget.bookingId,
              orElse: () => null);
      if (found != null) return found;
    }
    return widget.initial;
  }

  Future<void> _openPdf(String url) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PdfViewer(url: url),
    );
  }

  Future<void> _share(String url, String fileName) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      await Share.shareXFiles([XFile(file.path)], subject: fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  Future<void> _submitReview(WorkspaceResult result) async {
    int rating = 5;
    final commentCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Write a Review'),
        content: StatefulBuilder(builder: (ctx, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rate your experience at ${result.labName}'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => rating = i + 1),
                  ),
                ),
              ),
              TextField(
                controller: commentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                ),
                maxLines: 3,
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _submittingReview = true);
    try {
      final comment = commentCtrl.text.trim();
      await ref.read(patientRepositoryProvider).submitReview(
            bookingId: widget.bookingId,
            rating: rating,
            comment: comment.isEmpty ? null : comment,
          );
      ref.invalidate(workspaceProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
      }
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(workspaceProvider);
    final result = _getResult();

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const LoadingIndicator(),
      );
    }

    final date = DateFormat('d MMMM yyyy')
        .format(DateTime.parse(result.scheduledAt).toLocal());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Detail'),
        actions: [
          if (result.file != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share PDF',
              onPressed: () =>
                  _share(result.file!.fileUrl, result.file!.fileName),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(result: result, date: date),
          if (result.summary != null) ...[
            const SizedBox(height: 12),
            _SummaryCard(summary: result.summary!),
          ],
          if (result.file != null) ...[
            const SizedBox(height: 12),
            _PdfCard(
              file: result.file!,
              onOpen: () => _openPdf(result.file!.fileUrl),
            ),
          ],
          if (result.review != null) ...[
            const SizedBox(height: 12),
            _ExistingReviewCard(review: result.review!),
          ],
          if (result.canReview && result.review == null) ...[
            const SizedBox(height: 16),
            _submittingReview
                ? const Center(child: CircularProgressIndicator())
                : FilledButton.icon(
                    onPressed: () => _submitReview(result),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Write a Review'),
                  ),
          ],
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final WorkspaceResult result;
  final String date;

  const _HeaderCard({required this.result, required this.date});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (result.resultStatus) {
      ResultStatus.pending => ('Pending', Colors.orange),
      ResultStatus.uploaded => ('Uploaded', Colors.blue),
      ResultStatus.delivered => ('Delivered', Colors.green),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(result.testName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(result.labName,
                style: Theme.of(context).textTheme.bodyMedium),
            Text(date,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ResultSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(summary.summary),
            if (summary.highlights.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...summary.highlights.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(item.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline)),
                      ),
                      Expanded(
                        child: Text(item.value,
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PdfCard extends StatelessWidget {
  final ResultFile file;
  final VoidCallback onOpen;

  const _PdfCard({required this.file, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(file.fileName),
        subtitle: Text('${(file.sizeBytes / 1024).round()} KB'),
        trailing: const Icon(Icons.open_in_new),
        onTap: onOpen,
      ),
    );
  }
}

class _ExistingReviewCard extends StatelessWidget {
  final WorkspaceResultReview review;

  const _ExistingReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Review', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 18,
                  color: Colors.amber,
                ),
              ),
            ),
            if (review.comment != null) ...[
              const SizedBox(height: 4),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── PDF bottom sheet ─────────────────────────────────────────────────────────

class _PdfViewer extends StatefulWidget {
  final String url;

  const _PdfViewer({required this.url});

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  late final PdfController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: _openCached(widget.url),
    );
  }

  Future<PdfDocument> _openCached(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return PdfDocument.openFile(file.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Document',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: PdfView(controller: _controller)),
        ],
      ),
    );
  }
}
