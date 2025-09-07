import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/injection_container.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_event.dart';
import '../bloc/watchlist/watchlist_state.dart';
import '../services/watchlist_service.dart';
import '../dto/response/content_response_dto.dart';
import '../pages/content_detail_page.dart';
import 'dart:convert';

class WatchlistDetailPage extends StatelessWidget {
  final int watchlistId;
  final String watchlistName;

  const WatchlistDetailPage({
    super.key,
    required this.watchlistId,
    required this.watchlistName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WatchlistBloc(
        watchlistService: getIt<WatchlistService>(),
      )..add(LoadWatchlistById(watchlistId: watchlistId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(watchlistName),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<WatchlistBloc, WatchlistState>(
              builder: (context, state) {
                return _buildContent(context, state);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WatchlistState state) {
    if (state is WatchlistError) {
      return _buildErrorState(context, state.message);
    }

    if (state is WatchlistLoaded && state.watchlistDetails != null) {
      return _buildWatchlistContent(context, state.watchlistDetails!);
    }

    // Loading state
    return _buildLoadingState(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading watchlist...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load watchlist',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<WatchlistBloc>().add(
                LoadWatchlistById(watchlistId: watchlistId),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistContent(BuildContext context, watchlistDetails) {
    final contents = watchlistDetails.contents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contents list
        Text(
          'Contents',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        if (contents.isEmpty)
          _buildEmptyState(context)
        else
          Expanded(
            child: ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                return _buildContentCard(context, contents[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.movie_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No contents in this watchlist',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This watchlist is currently empty.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, ContentResponseDto content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContentDetailPage(content: content),
            ),
          );
        },
        leading: _buildContentImage(context, content.base64Image),
        title: Text(
          content.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              content.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    content.contentType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    content.genres.join(', '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildContentImage(BuildContext context, String? base64Image) {
    try {
      if (base64Image != null && base64Image.isNotEmpty) {
        final decodedBytes = base64Decode(base64Image);
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: MemoryImage(decodedBytes),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    } catch (e) {
      // Fall through to default icon
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.movie,
        color: Theme.of(context).primaryColor,
        size: 30,
      ),
    );
  }
}