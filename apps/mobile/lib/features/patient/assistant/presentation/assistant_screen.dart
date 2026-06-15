import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../application/chat_notifier.dart';
import '../data/chat_models.dart';

/// Brightness-aware palette helpers. The screen draws its own surfaces/bubbles,
/// so it can't rely on the global theme picking the right neutral — these map a
/// token to its light/dark constant based on the active brightness.
extension _AssistantPalette on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cSurface => _isDark ? AppColors.surfaceDark : AppColors.surface;
  Color get cSurfaceMuted =>
      _isDark ? AppColors.surfaceMutedDark : AppColors.surfaceMuted;
  Color get cForeground =>
      _isDark ? AppColors.foregroundDark : AppColors.foreground;
  Color get cLine => _isDark ? AppColors.lineSubtleDark : AppColors.lineSubtle;
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottomSoon();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(chatNotifierProvider);

    // Keep the view pinned to the latest content as it streams in.
    ref.listen(chatNotifierProvider, (_, __) => _scrollToBottomSoon());
    ref.listen(chatNotifierProvider.select((s) => s.error), (_, error) {
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.assistantTitle),
        actions: [
          IconButton(
            tooltip: l10n.assistantNewChat,
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: state.messages.isEmpty
                ? null
                : () => ref.read(chatNotifierProvider.notifier).startNewChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyState(onSuggestion: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) =>
                        _MessageBubble(message: state.messages[i]),
                  ),
          ),
          _Composer(
            controller: _controller,
            enabled: !state.isStreaming,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final theme = Theme.of(context);
    final showTyping = message.isStreaming && message.content.isEmpty;
    final showBubble = message.content.isNotEmpty || showTyping;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showBubble)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.brand : context.cSurfaceMuted,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: showTyping
                  ? const _TypingIndicator()
                  : Text(
                      message.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.white : context.cForeground,
                        height: 1.35,
                      ),
                    ),
            ),
          for (final tool in message.tools)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _ToolResultCards(tool: tool),
            ),
        ],
      ),
    );
  }
}

class _ToolResultCards extends StatelessWidget {
  const _ToolResultCards({required this.tool});

  final ToolResult tool;

  @override
  Widget build(BuildContext context) {
    final cards = tool.tool == 'find_labs'
        ? tool.labs.map<Widget>((l) => _LabCard(lab: l)).toList()
        : tool.tests.map<Widget>((t) => _TestCard(test: t)).toList();
    if (cards.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == cards.length - 1 ? 0 : 8),
              child: cards[i],
            ),
        ],
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  const _LabCard({required this.lab});

  final AssistantLabCard lab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/patient/labs/${lab.labId}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: context.cSurfaceMuted,
                  child: const Icon(Icons.science_outlined,
                      size: 18, color: AppColors.brand),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lab.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 13, color: AppColors.mutedForeground),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              lab.city ?? lab.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.mutedForeground),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (lab.priceEgp != null) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${lab.priceEgp} EGP',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.brand),
                      ),
                      Text('from',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: AppColors.mutedForeground)),
                    ],
                  ),
                ],
              ],
            ),
            if (lab.rating != null || lab.homeCollection) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  if (lab.rating != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star,
                            size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(
                          '${lab.rating!.toStringAsFixed(1)} (${lab.reviews})',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  if (lab.homeCollection)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.home_outlined,
                            size: 13, color: Color(0xFF059669)),
                        const SizedBox(width: 2),
                        Text('Home collection',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFF059669))),
                      ],
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

class _TestCard extends StatelessWidget {
  const _TestCard({required this.test});

  final AssistantTestCard test;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push(
        '/patient/tests/${Uri.encodeComponent(test.name)}'
        '?category=${Uri.encodeComponent(test.category)}',
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.cLine),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${test.category} · ${test.labCount} '
                    '${test.labCount == 1 ? 'lab' : 'labs'}',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.mutedForeground),
                  ),
                ],
              ),
            ),
            if (test.minPriceEgp != null) ...[
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${test.minPriceEgp} EGP',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.brand),
                  ),
                  Text('from',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.mutedForeground)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_controller.value + i * 0.2) % 1.0;
              final opacity = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0, 1);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Opacity(
                  opacity: opacity.toDouble(),
                  child: const CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.mutedForeground,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final suggestions = [
      l10n.assistantSuggestion1,
      l10n.assistantSuggestion2,
      l10n.assistantSuggestion3,
    ];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const Center(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.brand,
            child: Icon(Icons.health_and_safety_outlined,
                color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.assistantEmptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.assistantEmptyBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 24),
        for (final s in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton(
              onPressed: () => onSuggestion(s),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                minimumSize: const Size.fromHeight(0),
              ),
              child: Text(s, textAlign: TextAlign.start),
            ),
          ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.cLine)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: enabled ? (_) => onSend() : null,
                    decoration: InputDecoration(
                      hintText: l10n.assistantInputHint,
                      filled: true,
                      fillColor: context.cSurfaceMuted,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: enabled ? onSend : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.assistantDisclaimer,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: AppColors.mutedForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
