import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/watchlist/watchlist_bloc.dart';
import '../bloc/watchlist/watchlist_event.dart';
import '../bloc/watchlist/watchlist_state.dart';
import '../dto/request/watchlist_request_dto.dart';
import '../dto/response/watchlist_response_dto.dart';

class WatchlistDialog extends HookWidget {
  final WatchlistResponseDto? watchlistToEdit;

  const WatchlistDialog({
    super.key,
    this.watchlistToEdit,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: watchlistToEdit?.name ?? '');
    final isPublic = useState(watchlistToEdit?.isPublic ?? false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isEditing = watchlistToEdit != null;

    return BlocConsumer<WatchlistBloc, WatchlistState>(
      listener: (context, state) {
        if (state is WatchlistLoaded && state.currentOperation != null) {
          final operation = state.currentOperation!;
          
          // Handle operation completion
          if (operation.status == WatchlistOperationStatus.success) {
            // Check if this operation is relevant to our dialog
            final isRelevantAdd = operation.type == WatchlistOperationType.add && !isEditing;
            final isRelevantUpdate = operation.type == WatchlistOperationType.update && 
                                   isEditing && 
                                   operation.watchlistId == watchlistToEdit?.id;
            
            if (isRelevantAdd || isRelevantUpdate) {
              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(operation.message ?? 'Operation completed successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              
              // Clear the operation state and close dialog
              context.read<WatchlistBloc>().add(const ClearWatchlistOperationState());
              Navigator.of(context).pop(true); // Return true to indicate success
            }
          }
          
          // Handle operation errors
          if (operation.status == WatchlistOperationStatus.error) {
            final isRelevantAdd = operation.type == WatchlistOperationType.add && !isEditing;
            final isRelevantUpdate = operation.type == WatchlistOperationType.update && 
                                   isEditing && 
                                   operation.watchlistId == watchlistToEdit?.id;
            
            if (isRelevantAdd || isRelevantUpdate) {
              // Show error snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(operation.message ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
              
              // Clear the operation state but don't close dialog
              context.read<WatchlistBloc>().add(const ClearWatchlistOperationState());
            }
          }
        }
      },
      builder: (context, state) {
        // Determine if there's an ongoing operation relevant to this dialog
        bool isLoading = false;
        if (state is WatchlistLoaded && state.currentOperation != null) {
          final operation = state.currentOperation!;
          if (operation.status == WatchlistOperationStatus.loading) {
            final isRelevantAdd = operation.type == WatchlistOperationType.add && !isEditing;
            final isRelevantUpdate = operation.type == WatchlistOperationType.update && 
                                   isEditing && 
                                   operation.watchlistId == watchlistToEdit?.id;
            isLoading = isRelevantAdd || isRelevantUpdate;
          }
        }

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit : Icons.playlist_add,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(isEditing ? 'Edit Watchlist' : 'Create New Watchlist'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Watchlist Name',
                    hintText: 'Enter a name for your watchlist',
                    prefixIcon: const Icon(Icons.list_alt),
                    border: const OutlineInputBorder(),
                    errorMaxLines: 2,
                    suffixIcon: isLoading 
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a watchlist name';
                    }
                    if (value.trim().length > 50) {
                      return 'Watchlist name cannot exceed 50 characters';
                    }
                    return null;
                  },
                  maxLength: 50,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: !isLoading ? (_) => _submitForm(context, formKey, nameController, isPublic, isEditing) : null,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Settings',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: Text(
                            isPublic.value ? 'Public Watchlist' : 'Private Watchlist',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            isPublic.value
                                ? 'Other users can see this watchlist'
                                : 'Only you can see this watchlist',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          value: isPublic.value,
                          onChanged: isLoading ? null : (value) => isPublic.value = value,
                          secondary: Icon(
                            isPublic.value ? Icons.public : Icons.lock,
                            color: isPublic.value ? Colors.green[700] : Colors.orange[700],
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Updating watchlist...' : 'Creating watchlist...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () {
                // Clear any operation state when cancelling
                if (state is WatchlistLoaded && state.currentOperation != null) {
                  context.read<WatchlistBloc>().add(const ClearWatchlistOperationState());
                }
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: isLoading 
                  ? null 
                  : () => _submitForm(context, formKey, nameController, isPublic, isEditing),
              icon: isLoading 
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(isEditing ? Icons.save : Icons.check),
              label: Text(isLoading 
                  ? (isEditing ? 'Saving...' : 'Creating...')
                  : (isEditing ? 'Save Changes' : 'Create')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.grey[600],
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitForm(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    ValueNotifier<bool> isPublic,
    bool isEditing,
  ) {
    if (formKey.currentState?.validate() ?? false) {
      final watchlistRequest = WatchlistRequestDto(
        name: nameController.text.trim(),
        isPublic: isPublic.value,
      );

      if (isEditing) {
        context.read<WatchlistBloc>().add(
          UpdateWatchlist(
            id: watchlistToEdit!.id,
            watchlistRequest: watchlistRequest,
          ),
        );
      } else {
        context.read<WatchlistBloc>().add(
          AddWatchlist(watchlistRequest: watchlistRequest),
        );
      }
    }
  }
}