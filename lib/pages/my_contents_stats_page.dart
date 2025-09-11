import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/pages/content_stats_detail_page.dart';
import 'package:frontend/bloc/content_stats/content_stats_bloc.dart';
import 'package:frontend/bloc/content_stats/content_stats_event.dart';
import 'package:frontend/bloc/content_stats/content_stats_state.dart';
import 'package:frontend/dto/response/content_stats_row_dto.dart';

class MyContentsStatsPage extends HookWidget {
  const MyContentsStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final statsBloc = context.read<ContentStatsBloc>();

    useEffect(() {
      statsBloc.add(const LoadMyContentsStatsRequested());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contents · Stats'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RefreshIndicator(
            onRefresh: () async {
              statsBloc.add(const LoadMyContentsStatsRequested());
            },
            child: BlocBuilder<ContentStatsBloc, ContentStatsState>(
              buildWhen: (previous, current) =>
                  current is ContentStatsLoading ||
                  current is ContentStatsLoaded ||
                  current is ContentStatsError,
              builder: (context, state) {
                if (state is ContentStatsLoading) {
                  return ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                }

                if (state is ContentStatsError) {
                  return ListView(
                    children: [
                      const SizedBox(height: 100),
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => statsBloc.add(const LoadMyContentsStatsRequested()),
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  );
                }

                if (state is ContentStatsLoaded) {
                  final rows = state.rows;
                  if (rows.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text(
                            'No stats available yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _StatsTable(rows: rows),
                    ],
                  );
                }

                // Initial render before first stats load (or ignored non-stats states)
                return ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => context.read<ContentStatsBloc>().add(const LoadMyContentsStatsRequested()),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _StatsTable extends StatelessWidget {
  const _StatsTable({required this.rows});

  final List<ContentStatsRowDto> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = _computeTotals(rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI cards
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _KpiCard(
              title: 'Threads',
              value: totals['threads']!,
              color: theme.colorScheme.primary,
              icon: Icons.forum,
            ),
            _KpiCard(
              title: 'Posts',
              value: totals['posts']!,
              color: Colors.blue,
              icon: Icons.chat_bubble,
            ),
            _KpiCard(
              title: 'Saves',
              value: totals['saves']!,
              color: Colors.green,
              icon: Icons.bookmark,
            ),
            _KpiCard(
              title: 'Reports',
              value: totals['reports']!,
              color: Colors.orange,
              icon: Icons.report,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Charts
        _ChartsSection(rows: rows),
        const SizedBox(height: 16),

        // Titles list (replaces raw table)
        Card(
          elevation: 2,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = rows[index];
              return ListTile(
                title: Text(r.title, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ContentStatsDetailPage(row: r),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, int> _computeTotals(List<ContentStatsRowDto> rows) {
    int threads = 0, posts = 0, reports = 0, saves = 0;
    for (final r in rows) {
      threads += r.threads;
      posts += r.posts;
      reports += r.reports;
      saves += r.saves;
    }
    return {
      'threads': threads,
      'posts': posts,
      'reports': reports,
      'saves': saves,
    };
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      value.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.rows});

  final List<ContentStatsRowDto> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        // Pie: interaction mix
        final totals = _computeTotals(rows);
        final totalSum = (totals['threads']! + totals['posts']! + totals['saves']! + totals['reports']!);

        Widget pieCard = Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Interaction Mix', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (rows.isEmpty || totalSum == 0) _EmptyChartCard(title: 'Interaction Mix', message: 'No interactions yet')
                else SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        _pieSection(value: totals['threads']!.toDouble(), color: Colors.indigo, label: 'Threads'),
                        _pieSection(value: totals['posts']!.toDouble(), color: Colors.blue, label: 'Posts'),
                        _pieSection(value: totals['saves']!.toDouble(), color: Colors.green, label: 'Saves'),
                        _pieSection(value: totals['reports']!.toDouble(), color: Colors.orange, label: 'Reports'),
                      ],
                    ),
                  ),
                ),
                if (rows.isNotEmpty && totalSum > 0) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _LegendItem(color: Colors.indigo, label: 'Threads', value: totals['threads']!, total: totalSum),
                      _LegendItem(color: Colors.blue, label: 'Posts', value: totals['posts']!, total: totalSum),
                      _LegendItem(color: Colors.green, label: 'Saves', value: totals['saves']!, total: totalSum),
                      _LegendItem(color: Colors.orange, label: 'Reports', value: totals['reports']!, total: totalSum),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );

        // Metric selectors for bar charts
        final metrics = _Metric.values;
        _Metric leftMetric = _Metric.posts;
        _Metric rightMetric = _Metric.saves;
        // Use StatefulBuilder to hold local metric state without changing class type
        bool isNavigating = false;
        return StatefulBuilder(
          builder: (context, setState) {
            List<_BarDatum> leftData = _topByMetric(rows, leftMetric, 5);
            List<_BarDatum> rightData = _topByMetric(rows, rightMetric, 5);

            Widget selector(_Metric metric, void Function(_Metric) onChanged) {
              return DropdownButton<_Metric>(
                value: metric,
                onChanged: (m) => m == null ? null : onChanged(m),
                items: metrics
                    .map((m) => DropdownMenuItem<_Metric>(
                          value: m,
                          child: Text(_metricLabel(m)),
                        ))
                    .toList(),
              );
            }

            Color colorFor(_Metric m) {
              switch (m) {
                case _Metric.posts:
                  return Colors.blue;
                case _Metric.saves:
                  return Colors.green;
                case _Metric.threads:
                  return Colors.indigo;
                case _Metric.reports:
                  return Colors.orange;
              }
            }

            Widget postsCard = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top by ${_metricLabel(leftMetric)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        selector(leftMetric, (m) => setState(() => leftMetric = m)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (leftData.isEmpty || leftData.every((d) => d.value == 0))
                      _EmptyChartCard(title: 'Top by ${_metricLabel(leftMetric)}', message: 'No data yet')
                    else SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= leftData.length) return const SizedBox.shrink();
                                  final label = leftData[i].label;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: SizedBox(width: 60, child: Text(label, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(leftData.length, (i) {
                            final v = leftData[i].value.toDouble();
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: v, color: colorFor(leftMetric), width: 16, borderRadius: BorderRadius.circular(4)),
                              ],
                            );
                          }),
                          barTouchData: BarTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchCallback: (ev, resp) {
                              if (resp == null || resp.spot == null) return;
                              if (ev is! FlTapUpEvent) return; // only on tap release
                              if (isNavigating) return;
                              final idx = resp.spot!.touchedBarGroupIndex;
                              if (idx < 0 || idx >= leftData.length) return;
                              final row = leftData[idx].row;
                              isNavigating = true;
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ContentStatsDetailPage(row: row),
                                    ),
                                  )
                                  .whenComplete(() {
                                isNavigating = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            Widget savesCard = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Top by ${_metricLabel(rightMetric)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        selector(rightMetric, (m) => setState(() => rightMetric = m)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (rightData.isEmpty || rightData.every((d) => d.value == 0))
                      _EmptyChartCard(title: 'Top by ${_metricLabel(rightMetric)}', message: 'No data yet')
                    else SizedBox(
                      height: 240,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= rightData.length) return const SizedBox.shrink();
                                  final label = rightData[i].label;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: SizedBox(width: 60, child: Text(label, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(rightData.length, (i) {
                            final v = rightData[i].value.toDouble();
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: v, color: colorFor(rightMetric), width: 16, borderRadius: BorderRadius.circular(4)),
                              ],
                            );
                          }),
                          barTouchData: BarTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchCallback: (ev, resp) {
                              if (resp == null || resp.spot == null) return;
                              if (ev is! FlTapUpEvent) return; // only on tap release
                              if (isNavigating) return;
                              final idx = resp.spot!.touchedBarGroupIndex;
                              if (idx < 0 || idx >= rightData.length) return;
                              final row = rightData[idx].row;
                              isNavigating = true;
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ContentStatsDetailPage(row: row),
                                    ),
                                  )
                                  .whenComplete(() {
                                isNavigating = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  pieCard,
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: postsCard),
                      const SizedBox(width: 12),
                      Expanded(child: savesCard),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  pieCard,
                  const SizedBox(height: 12),
                  postsCard,
                  const SizedBox(height: 12),
                  savesCard,
                ],
              );
            }
          },
        );
      },
    );
  }

  Map<String, int> _computeTotals(List<ContentStatsRowDto> rows) {
    int threads = 0, posts = 0, reports = 0, saves = 0;
    for (final r in rows) {
      threads += r.threads;
      posts += r.posts;
      reports += r.reports;
      saves += r.saves;
    }
    return {
      'threads': threads,
      'posts': posts,
      'reports': reports,
      'saves': saves,
    };
  }

  PieChartSectionData _pieSection({required double value, required Color color, required String label}) {
    if (value <= 0) {
      return PieChartSectionData(value: 0, color: color.withValues(alpha: 0.1));
    }
    return PieChartSectionData(
      value: value,
      color: color,
      title: '',
    );
  }

  List<_BarDatum> _topByMetric(List<ContentStatsRowDto> rows, _Metric metric, int topN) {
    int pick(ContentStatsRowDto r) {
      switch (metric) {
        case _Metric.posts:
          return r.posts;
        case _Metric.saves:
          return r.saves;
        case _Metric.threads:
          return r.threads;
        case _Metric.reports:
          return r.reports;
      }
    }

    final sorted = [...rows]..sort((a, b) => pick(b).compareTo(pick(a)));
    final take = sorted.take(topN).toList();
    return [
      for (int i = 0; i < take.length; i++)
        _BarDatum(index: i, label: take[i].title, value: pick(take[i]), row: take[i])
    ];
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.value, required this.total});

  final Color color;
  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = (value / total * 100).toStringAsFixed(0);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label ($percent%)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _EmptyChartCard extends StatelessWidget {
  const _EmptyChartCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insights, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

enum _Metric { posts, saves, threads, reports }

String _metricLabel(_Metric m) {
  switch (m) {
    case _Metric.posts:
      return 'Posts';
    case _Metric.saves:
      return 'Saves';
    case _Metric.threads:
      return 'Threads';
    case _Metric.reports:
      return 'Reports';
  }
}

class _BarDatum {
  _BarDatum({required this.index, required this.label, required this.value, required this.row});
  final int index;
  final String label;
  final int value;
  final ContentStatsRowDto row;
}
