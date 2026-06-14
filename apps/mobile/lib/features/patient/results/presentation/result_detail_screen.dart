import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/dio_client.dart';
import '../../workspace/application/workspace_provider.dart';
import '../../workspace/data/workspace_models.dart';
import '../../workspace/data/patient_repository.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';

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
      builder: (_) => _PdfViewer(url: url, dio: ref.read(dioClientProvider)),
    );
  }

  Future<void> _share(String url, String fileName) async {
    try {
      final bytes = await _downloadFile(ref.read(dioClientProvider), url);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], subject: fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  Future<void> _submitReview(WorkspaceResult result) async {
    final l10n = AppLocalizations.of(context)!;
    int rating = 5;
    final commentCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.writeReview),
        content: StatefulBuilder(builder: (ctx, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.rateExperience(result.labName)),
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
                decoration: InputDecoration(
                  labelText: l10n.commentOptional,
                ),
                maxLines: 3,
              ),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.submit),
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
          SnackBar(content: Text(l10n.reviewSubmitted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.failedToSubmit(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(workspaceProvider);
    final result = _getResult();

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.result)),
        body: const LoadingIndicator(),
      );
    }

    final date = DateFormat('d MMMM yyyy')
        .format(DateTime.parse(result.scheduledAt).toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultDetail),
        actions: [
          if (result.file != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.sharePdf,
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
                    label: Text(l10n.writeReview),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.summary, style: Theme.of(context).textTheme.titleSmall),
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
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.yourReview, style: Theme.of(context).textTheme.titleSmall),
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

/// Downloads a protected result file through the authenticated [dio] client.
///
/// [url] is the relative path returned by the API (e.g. `/results/files/{id}`);
/// Dio resolves it against the configured base URL and attaches the Bearer
/// token via the auth interceptor.
Future<Uint8List> _downloadFile(Dio dio, String url) async {
  final response = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  final data = response.data;
  if (data == null || data.isEmpty) {
    throw Exception('Empty file response');
  }
  return Uint8List.fromList(data);
}

class _PdfViewer extends StatefulWidget {
  final String url;
  final Dio dio;

  const _PdfViewer({required this.url, required this.dio});

  @override
  State<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<_PdfViewer> {
  late final Future<PdfController> _controllerFuture;
  PdfController? _controller;

  @override
  void initState() {
    super.initState();
    _controllerFuture = _open();
  }

  Future<PdfController> _open() async {
    final bytes = await _downloadFile(widget.dio, widget.url);
    final controller = PdfController(document: PdfDocument.openData(bytes));
    _controller = controller;
    return controller;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final height = MediaQuery.of(context).size.height * 0.85;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(l10n.document,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<PdfController>(
              future: _controllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.couldNotOpenDocument(snapshot.error.toString())),
                    ),
                  );
                }
                return PdfView(controller: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
