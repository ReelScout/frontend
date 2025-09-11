import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fl_chart/fl_chart.dart';
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

        // Raw table
        Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Threads')),
                DataColumn(label: Text('Posts')),
                DataColumn(label: Text('Reports')),
                DataColumn(label: Text('Saves')),
              ],
              rows: rows
                  .map(
                    (r) => DataRow(
                      cells: [
                        DataCell(SizedBox(width: 220, child: Text(r.title, overflow: TextOverflow.ellipsis))),
                        DataCell(Text(r.threads.toString())),
                        DataCell(Text(r.posts.toString())),
                        DataCell(Text(r.reports.toString())),
                        DataCell(Text(r.saves.toString())),
                      ],
                    ),
                  )
                  .toList(),
            ),
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
    final topByPosts = [...rows]..sort((a, b) => b.posts.compareTo(a.posts));
    final topBySaves = [...rows]..sort((a, b) => b.saves.compareTo(a.saves));
    final showCount = topByPosts.length < 5 ? topByPosts.length : 5;
    final showCountSaves = topBySaves.length < 5 ? topBySaves.length : 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        Widget postsCard = Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top by Posts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
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
                                  if (i < 0 || i >= showCount) return const SizedBox.shrink();
                                  final label = topByPosts[i].title;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: SizedBox(width: 60, child: Text(label, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(showCount, (i) {
                            final v = topByPosts[i].posts.toDouble();
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: v, color: theme.colorScheme.primary, width: 16, borderRadius: BorderRadius.circular(4)),
                              ],
                            );
                          }),
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
                    Text('Top by Saves', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
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
                                  if (i < 0 || i >= showCountSaves) return const SizedBox.shrink();
                                  final label = topBySaves[i].title;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: SizedBox(width: 60, child: Text(label, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(showCountSaves, (i) {
                            final v = topBySaves[i].saves.toDouble();
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: v, color: Colors.green, width: 16, borderRadius: BorderRadius.circular(4)),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: postsCard),
              const SizedBox(width: 12),
              Expanded(child: savesCard),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              postsCard,
              const SizedBox(height: 12),
              savesCard,
            ],
          );
        }
      },
    );
  }
}
