import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/bloc/watchlist/watchlist_bloc.dart';
import 'package:frontend/bloc/watchlist/watchlist_event.dart';
import 'package:frontend/bloc/watchlist/watchlist_state.dart';
import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/styles/app_colors.dart';
import 'package:frontend/utils/base64_image_cache.dart';
import 'package:frontend/pages/forum/forum_page.dart';

class ContentDetailPage extends StatelessWidget {
  final ContentResponseDto content;

  const ContentDetailPage({
    super.key,
    required this.content,
  });

  Future<void> _launchTrailerUrl(BuildContext context) async {
    if (content.trailerUrl == null || content.trailerUrl!.isEmpty) {
      return;
    }

    try {
      final Uri url = Uri.parse(content.trailerUrl!);
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open trailer URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showWatchlistDialog(BuildContext context) {
    final watchlistBloc = context.read<WatchlistBloc>();
    
    // Load watchlists if not already loaded
    if (watchlistBloc.state is! WatchlistLoaded) {
      watchlistBloc.add(const LoadWatchlists());
    } else {
      // Load watchlists that contain this content
      watchlistBloc.add(LoadWatchlistsByContentId(contentId: content.id));
    }

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: watchlistBloc,
          child: WatchlistDialog(content: content),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            onPressed: () => _showWatchlistDialog(context),
            icon: const Icon(Icons.add_circle),
            tooltip: 'Add to watchlist',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ForumPage(content: content),
                ),
              );
            },
            icon: const Icon(Icons.forum),
            tooltip: 'Open forum',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content image
            if (content.base64Image != null)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    decodeBase64Cached(content.base64Image!) ?? Uint8List(0),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.movie,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.movie,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 24),

            // Title and basic info
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),

            // Content type and production company
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    content.contentType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    content.productionCompanyName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description section
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Directors section
            if (content.directors.isNotEmpty) ...[
              Text(
                'Directors',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content.directors.map((director) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '${director.firstName} ${director.lastName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Actors section
            if (content.actors.isNotEmpty) ...[
              Text(
                'Cast',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content.actors.map((actor) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '${actor.firstName} ${actor.lastName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Trailer section (if available)
            if (content.trailerUrl != null && content.trailerUrl!.isNotEmpty) ...[
              Text(
                'Trailer',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _launchTrailerUrl(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Watch Trailer',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class WatchlistDialog extends StatefulWidget {
  final ContentResponseDto content;

  const WatchlistDialog({
    super.key,
    required this.content,
  });

  @override
  State<WatchlistDialog> createState() => _WatchlistDialogState();
}

class _WatchlistDialogState extends State<WatchlistDialog> {
  final Set<int> selectedWatchlistIds = <int>{};
  final Set<int> loadingWatchlistIds = <int>{};
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (state is WatchlistLoaded) {
          // Initialize selected watchlists when first loaded
          if (state.watchlistsWithContent != null && !_isInitialized) {
            setState(() {
              selectedWatchlistIds.clear();
              selectedWatchlistIds.addAll(state.watchlistsWithContent!.map((w) => w.id));
              _isInitialized = true;
            });
          } else if (state.watchlists.isNotEmpty && !_isInitialized) {
            context.read<WatchlistBloc>().add(LoadWatchlistsByContentId(contentId: widget.content.id));
          }
        }
      },
      child: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.playlist_add, color: Colors.blue),
                SizedBox(width: 8),
                Text('Manage Watchlists'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: _buildDialogContent(state),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogContent(WatchlistState state) {
    if (state is WatchlistLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading watchlists...'),
            ],
          ),
        ),
      );
    } else if (state is WatchlistError) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<WatchlistBloc>().add(const LoadWatchlists());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (state is WatchlistLoaded) {
      if (state.watchlists.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.playlist_remove, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No watchlists found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a watchlist first to add content',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select watchlists for "${widget.content.title}":',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.watchlists.length,
              itemBuilder: (context, index) {
                final watchlist = state.watchlists[index];
                final isSelected = selectedWatchlistIds.contains(watchlist.id);
                final isLoading = loadingWatchlistIds.contains(watchlist.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  child: CheckboxListTile(
                    title: Text(
                      watchlist.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isLoading ? Colors.grey : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          watchlist.isPublic ? Icons.public : Icons.lock,
                          size: 14,
                          color: watchlist.isPublic ? Colors.green[600] : Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          watchlist.isPublic ? 'Public' : 'Private',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (isLoading) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ],
                      ],
                    ),
                    value: isSelected,
                    enabled: !isLoading,
                    onChanged: isLoading ? null : (bool? value) async {
                      await _handleWatchlistToggle(watchlist.id, value ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _handleWatchlistToggle(int watchlistId, bool shouldAdd) async {
    setState(() {
      loadingWatchlistIds.add(watchlistId);
    });

    try {
      final bloc = context.read<WatchlistBloc>();
      
      if (shouldAdd) {
        bloc.add(AddContentToWatchlist(
          watchlistId: watchlistId,
          contentId: widget.content.id,
        ));
        
        // Wait a bit for the operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));
        
        setState(() {
          selectedWatchlistIds.add(watchlistId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content added to watchlist'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        bloc.add(RemoveContentFromWatchlist(
          watchlistId: watchlistId,
          contentId: widget.content.id,
        ));
        
        // Wait a bit for the operation to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));
        
        setState(() {
          selectedWatchlistIds.remove(watchlistId);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content removed from watchlist'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingWatchlistIds.remove(watchlistId);
        });
      }
    }
  }
}
