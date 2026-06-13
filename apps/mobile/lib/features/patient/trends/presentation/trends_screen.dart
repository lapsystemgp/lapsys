import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/health_profile_models.dart';
import '../application/health_profile_provider.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_state.dart';

class TrendsScreen extends ConsumerStatefulWidget {
  const TrendsScreen({super.key});

  @override
  ConsumerState<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends ConsumerState<TrendsScreen> {
  String _range = '12m';
  String _groupBy = 'analyte';

  HealthProfileParams get _params => (range: _range, groupBy: _groupBy);

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(healthProfileProvider(_params));

    return Scaffold(
      appBar: AppBar(title: const Text('Health Trends')),
      body: Column(
        children: [
          _FilterRow(
            range: _range,
            groupBy: _groupBy,
            onRangeChanged: (v) => setState(() => _range = v),
            onGroupByChanged: (v) => setState(() => _groupBy = v),
          ),
          const Divider(height: 1),
          Expanded(
            child: profileAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => ErrorState(
                error: e,
                onRetry: () => ref.invalidate(healthProfileProvider(_params)),
              ),
              data: (profile) => _TrendsBody(
                profile: profile,
                onRefresh: () async =>
                    ref.invalidate(healthProfileProvider(_params)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter row ───────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.range,
    required this.groupBy,
    required this.onRangeChanged,
    required this.onGroupByChanged,
  });

  final String range;
  final String groupBy;
  final ValueChanged<String> onRangeChanged;
  final ValueChanged<String> onGroupByChanged;

  static const _ranges = [
    ('3 mo', '3m'),
    ('6 mo', '6m'),
    ('12 mo', '12m'),
    ('All', 'all'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (label, val) in _ranges)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label, style: const TextStyle(fontSize: 12)),
                      selected: range == val,
                      onSelected: (selected) {
                        if (selected) onRangeChanged(val);
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'analyte',
                label: Text('By Analyte'),
                icon: Icon(Icons.biotech, size: 16),
              ),
              ButtonSegment(
                value: 'lab_test',
                label: Text('By Test'),
                icon: Icon(Icons.science, size: 16),
              ),
            ],
            selected: {groupBy},
            onSelectionChanged: (v) => onGroupByChanged(v.first),
            style: ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _TrendsBody extends StatelessWidget {
  const _TrendsBody({required this.profile, required this.onRefresh});

  final HealthProfileResponse profile;
  final Future<void> Function() onRefresh;

  bool get _hasSeries => profile.groupBy == 'analyte'
      ? profile.series.isNotEmpty
      : profile.labTestGroups.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!profile.hasStructuredData) ...[
            _NoDataCard(),
            const SizedBox(height: 12),
          ],

          if (profile.hasStructuredData && !_hasSeries)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No trends in the selected period. Try a wider time range.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),

          if (profile.groupBy == 'analyte')
            for (final s in profile.series) _SeriesCard(series: s),

          if (profile.groupBy == 'lab_test')
            for (final g in profile.labTestGroups)
              _LabTestGroupSection(group: g),

          if (profile.pdfOnlyBookings.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PdfOnlySection(bookings: profile.pdfOnlyBookings),
          ],

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              profile.disclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NoDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No structured data yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'When labs enter your test values as structured data, trends and charts will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Series card ──────────────────────────────────────────────────────────────

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series});

  final HealthSeries series;

  static double? _latestRefLow(List<HealthPoint> pts) {
    for (final p in pts.reversed) {
      if (p.refLow != null) return p.refLow;
    }
    return null;
  }

  static double? _latestRefHigh(List<HealthPoint> pts) {
    for (final p in pts.reversed) {
      if (p.refHigh != null) return p.refHigh;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...series.points]
      ..sort((a, b) => a.testDate.compareTo(b.testDate));
    final refLow = _latestRefLow(sorted);
    final refHigh = _latestRefHigh(sorted);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series.displayName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _InlineChip(
                            series.chartUnit,
                            color:
                                theme.colorScheme.secondaryContainer,
                            textColor:
                                theme.colorScheme.onSecondaryContainer,
                          ),
                          if (series.category != null)
                            _InlineChip(
                              series.category!,
                              color: theme.colorScheme.tertiaryContainer,
                              textColor:
                                  theme.colorScheme.onTertiaryContainer,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _TrendBadge(direction: series.trend.direction),
              ],
            ),
            const SizedBox(height: 8),

            // Trend narrative
            Text(
              series.trend.narrative,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Qualitative note
            if (series.trend.qualitativeNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.amber.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        series.trend.qualitativeNote!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Chart
            if (sorted.length >= 2) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: _TrendMiniChart(
                  points: sorted,
                  refLow: refLow,
                  refHigh: refHigh,
                  unit: series.chartUnit,
                ),
              ),
            ] else if (sorted.length == 1) ...[
              const SizedBox(height: 12),
              _SingleValueDisplay(
                  point: sorted.first, unit: series.chartUnit),
            ],

            // Recent readings
            if (sorted.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 8),
              const SizedBox(height: 4),
              Text(
                'Recent readings',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              ...sorted.reversed
                  .take(4)
                  .map((p) => _ReadingRow(
                        point: p,
                        unit: series.chartUnit,
                      )),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Mini line chart ──────────────────────────────────────────────────────────

class _TrendMiniChart extends StatelessWidget {
  const _TrendMiniChart({
    required this.points,
    required this.unit,
    this.refLow,
    this.refHigh,
  });

  final List<HealthPoint> points;
  final String unit;
  final double? refLow;
  final double? refHigh;

  double get _minY {
    final vals = points.map((p) => p.value);
    double min = vals.reduce(math.min);
    if (refLow != null && refLow! < min) min = refLow!;
    return min;
  }

  double get _maxY {
    final vals = points.map((p) => p.value);
    double max = vals.reduce(math.max);
    if (refHigh != null && refHigh! > max) max = refHigh!;
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lo = _minY;
    final hi = _maxY;
    final range = hi - lo;
    final pad = range < 0.01 ? 1.0 : range * 0.2;
    final minY = lo - pad;
    final maxY = hi + pad;

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: points.length > 3,
            curveSmoothness: 0.2,
            color: theme.colorScheme.primary,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final abnormal =
                    index < points.length && points[index].abnormal == true;
                return FlDotCirclePainter(
                  radius: 4,
                  color: abnormal ? Colors.red : theme.colorScheme.primary,
                  strokeWidth: 1.5,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withAlpha(20),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (refLow != null)
              HorizontalLine(
                y: refLow!,
                color: Colors.green.withAlpha(128),
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding:
                      const EdgeInsets.only(right: 4, bottom: 2),
                  style: const TextStyle(
                      fontSize: 8,
                      color: Colors.green,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) => 'Low',
                ),
              ),
            if (refHigh != null)
              HorizontalLine(
                y: refHigh!,
                color: Colors.orange.withAlpha(128),
                strokeWidth: 1,
                dashArray: [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.bottomRight,
                  padding:
                      const EdgeInsets.only(right: 4, top: 2),
                  style: const TextStyle(
                      fontSize: 8,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600),
                  labelResolver: (_) => 'High',
                ),
              ),
          ],
        ),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 ||
                    idx >= points.length ||
                    value != idx.toDouble()) {
                  return const SizedBox.shrink();
                }
                final date =
                    DateTime.tryParse(points[idx].testDate);
                if (date == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('d/M').format(date.toLocal()),
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) {
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _fmtVal(value),
                  style: TextStyle(
                    fontSize: 9,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.dividerColor.withAlpha(76),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom:
                BorderSide(color: theme.dividerColor, width: 0.5),
            left: BorderSide(color: theme.dividerColor, width: 0.5),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                theme.colorScheme.inverseSurface,
            getTooltipItems: (touchedSpots) => touchedSpots.map((ts) {
              final idx = ts.x.toInt();
              final p =
                  (idx >= 0 && idx < points.length) ? points[idx] : null;
              final date = p != null
                  ? DateTime.tryParse(p.testDate)
                  : null;
              final dateStr = date != null
                  ? DateFormat('d MMM').format(date.toLocal())
                  : '';
              return LineTooltipItem(
                '$dateStr\n${_fmtVal(ts.y)} $unit',
                TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onInverseSurface,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static String _fmtVal(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ─── Single value display (1 point only) ─────────────────────────────────────

class _SingleValueDisplay extends StatelessWidget {
  const _SingleValueDisplay({required this.point, required this.unit});

  final HealthPoint point;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(point.testDate);
    final dateStr = date != null
        ? DateFormat('d MMM yyyy').format(date.toLocal())
        : '';
    final abnormal = point.abnormal == true;

    return Row(
      children: [
        Icon(Icons.science_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '${_fmtVal(point.value)} $unit',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: abnormal ? Colors.red : null,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          dateStr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  static String _fmtVal(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ─── Reading row ──────────────────────────────────────────────────────────────

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.point, required this.unit});

  final HealthPoint point;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(point.testDate);
    final dateStr =
        date != null ? DateFormat('d MMM yyyy').format(date.toLocal()) : '';
    final abnormal = point.abnormal == true;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              dateStr,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              '${_fmtVal(point.value)} $unit',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: abnormal ? Colors.red : null,
              ),
            ),
          ),
          if (point.refLow != null || point.refHigh != null)
            Text(
              '[${point.refLow != null ? _fmtVal(point.refLow!) : '?'}'
              ' – '
              '${point.refHigh != null ? _fmtVal(point.refHigh!) : '?'}]',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (abnormal)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child:
                  Icon(Icons.warning_amber, size: 14, color: Colors.red),
            ),
        ],
      ),
    );
  }

  static String _fmtVal(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ─── Lab test group section ───────────────────────────────────────────────────

class _LabTestGroupSection extends StatelessWidget {
  const _LabTestGroupSection({required this.group});

  final LabTestGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.labTestName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        ...group.series.map((s) => _SeriesCard(series: s)),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── PDF-only section ─────────────────────────────────────────────────────────

class _PdfOnlySection extends StatelessWidget {
  const _PdfOnlySection({required this.bookings});

  final List<PdfOnlyBooking> bookings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'PDF-only results',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'These results have a PDF but no structured data for trending.',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ...bookings.map((b) {
              final date = DateTime.tryParse(b.scheduledAt);
              final dateStr = date != null
                  ? DateFormat('d MMM yyyy').format(date.toLocal())
                  : '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        b.testName,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      b.labName,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Shared mini widgets ──────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.direction});

  final String direction;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (direction) {
      'increasing' => (Icons.trending_up, Colors.orange, 'Rising'),
      'decreasing' => (Icons.trending_down, Colors.blue, 'Falling'),
      'stable' => (Icons.trending_flat, Colors.green, 'Stable'),
      _ => (
          Icons.help_outline,
          Theme.of(context).colorScheme.onSurfaceVariant,
          'Not enough data',
        ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InlineChip extends StatelessWidget {
  const _InlineChip(this.label,
      {required this.color, required this.textColor});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor),
      ),
    );
  }
}
