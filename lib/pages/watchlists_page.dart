import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_event.dart';
import '../bloc/watchlist/watchlist_state.dart';
import '../components/watchlist_card.dart';
import '../components/watchlist_dialog.dart';

class WatchlistsPage extends HookWidget {
  const WatchlistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      // Load watchlists when the page is first loaded
      context.read<WatchlistBloc>().add(const LoadWatchlists());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlists'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<WatchlistBloc, WatchlistState>(
        listener: (context, state) {
          // Handle operation feedback with snackbars
          if (state is WatchlistLoaded && state.currentOperation != null) {
            final operation = state.currentOperation!;
            
            if (operation.status == WatchlistOperationStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(operation.message ?? 'Operation completed successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              
              // Auto-clear operation state after showing snackbar
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted) {
                  context.read<WatchlistBloc>().add(const ClearWatchlistOperationState());
                }
              });
            }
            
            if (operation.status == WatchlistOperationStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(operation.message ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () {
                      // Retry the failed operation
                      _retryFailedOperation(context, operation);
                    },
                  ),
                ),
              );
              
              // Auto-clear operation state after showing snackbar
              Future.delayed(const Duration(seconds: 3), () {
                if (context.mounted) {
                  context.read<WatchlistBloc>().add(const ClearWatchlistOperationState());
                }
              });
            }
          }
        },
        builder: (context, state) {
          if (state is WatchlistInitial || state is WatchlistLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading watchlists...'),
                ],
              ),
            );
          }

          if (state is WatchlistError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading watchlists',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<WatchlistBloc>().add(const LoadWatchlists());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is WatchlistLoaded) {
            if (state.watchlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_add_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No watchlists yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first watchlist to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WatchlistBloc>().add(const LoadWatchlists());
                
                // Wait for the loading to complete
                final completer = Completer<void>();
                final subscription = context.read<WatchlistBloc>().stream.listen((newState) {
                  if (newState is WatchlistLoaded || newState is WatchlistError) {
                    if (!completer.isCompleted) completer.complete();
                  }
                });
                
                await completer.future;
                subscription.cancel();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.separated(
                  itemCount: state.watchlists.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final watchlist = state.watchlists[index];
                    final isBeingDeleted = state.currentOperation?.type == WatchlistOperationType.delete &&
                                          state.currentOperation?.watchlistId == watchlist.id &&
                                          state.currentOperation?.status == WatchlistOperationStatus.loading;
                    
                    return AnimatedOpacity(
                      opacity: isBeingDeleted ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Stack(
                        children: [
                          WatchlistCard(
                            watchlist: watchlist,
                            onTap: () => _showEditDialog(context, watchlist),
                            onEdit: () => _showEditDialog(context, watchlist),
                            onDelete: () => _showDeleteConfirmation(context, watchlist),
                          ),
                          if (isBeingDeleted)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 8),
                                      Text('Deleting...'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          final isAddingWatchlist = state is WatchlistLoaded &&
                                   state.currentOperation?.type == WatchlistOperationType.add &&
                                   state.currentOperation?.status == WatchlistOperationStatus.loading;

          return FloatingActionButton(
            onPressed: () => _showCreateDialog(context),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: isAddingWatchlist 
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissal during loading
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<WatchlistBloc>(),
        child: const WatchlistDialog(),
      ),
    );
  }

  void _showEditDialog(BuildContext context, watchlist) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissal during loading
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<WatchlistBloc>(),
        child: WatchlistDialog(watchlistToEdit: watchlist),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, watchlist) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.orange[700],
            ),
            const SizedBox(width: 8),
            const Text('Delete Watchlist'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${watchlist.name}"?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. All contents in this watchlist will be permanently removed.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WatchlistBloc>().add(
                DeleteWatchlist(
                  id: watchlist.id,
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _retryFailedOperation(BuildContext context, WatchlistOperation operation) {
    context.read<WatchlistBloc>().add(const ClearWatchlistOperationState());
    
    // Note: Retry logic would need to be implemented based on the specific operation
    // For now, we just clear the error state
    // In a real implementation, you might want to store the original event parameters
    // and re-dispatch the failed event
  }
}