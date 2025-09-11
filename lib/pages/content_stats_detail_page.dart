import 'package:flutter/material.dart';
import 'package:frontend/dto/response/content_stats_row_dto.dart';

class ContentStatsDetailPage extends StatelessWidget {
  const ContentStatsDetailPage({super.key, required this.row});

  final ContentStatsRowDto row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Stats'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _statTile(Icons.forum, 'Threads', row.threads, Colors.indigo),
                      const Divider(height: 24),
                      _statTile(Icons.chat_bubble, 'Posts', row.posts, Colors.blue),
                      const Divider(height: 24),
                      _statTile(Icons.bookmark, 'Saves', row.saves, Colors.green),
                      const Divider(height: 24),
                      _statTile(Icons.report, 'Reports', row.reports, Colors.orange),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, String label, int value, Color color) {
    return Row(
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
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text(value.toString(), style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

