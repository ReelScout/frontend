import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../services/watchlist_service.dart';
import '../../dto/response/custom_response_dto.dart';
import '../../dto/response/watchlist_response_dto.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

/// BLoC for managing watchlist operations with optimistic updates and comprehensive error handling
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({
    required WatchlistService watchlistService,
  })  : _watchlistService = watchlistService,
        super(const WatchlistInitial()) {
    on<LoadWatchlists>(_onLoadWatchlists);
    on<AddWatchlist>(_onAddWatchlist);
    on<UpdateWatchlist>(_onUpdateWatchlist);
    on<DeleteWatchlist>(_onDeleteWatchlist);
    on<RefreshWatchlists>(_onRefreshWatchlists);
    on<ClearWatchlistOperationState>(_onClearOperationState);
  }

  final WatchlistService _watchlistService;

  /// Handles loading watchlists from the server
  Future<void> _onLoadWatchlists(
    LoadWatchlists event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());

    try {
      final watchlists = await _watchlistService.getMyWatchlists();
      emit(WatchlistLoaded(watchlists: watchlists));
    } catch (e) {
      String errorMessage = 'Failed to load watchlists';
      if (e is DioException && e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          if (customResponse.message.isNotEmpty) {
            errorMessage = customResponse.message;
          }
        } catch (_) {
          // Use fallback message
        }
      }
      emit(WatchlistError(message: errorMessage));
    }
  }

  /// Handles adding a new watchlist
  Future<void> _onAddWatchlist(
    AddWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    // Validate input
    if (event.watchlistRequest.name.trim().isEmpty) {
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.add,
            message: 'Watchlist name cannot be empty',
          ),
        ));
      }
      return;
    }

    if (event.watchlistRequest.name.trim().length > 50) {
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.add,
            message: 'Watchlist name cannot exceed 50 characters',
          ),
        ));
      }
      return;
    }

    // Ensure we have a loaded state
    if (state is! WatchlistLoaded) {
      add(const LoadWatchlists());
      return;
    }

    final currentState = state as WatchlistLoaded;

    // Emit loading state
    emit(currentState.copyWith(
      currentOperation: WatchlistOperation.loading(
        type: WatchlistOperationType.add,
        watchlistName: event.watchlistRequest.name.trim(),
      ),
    ));

    try {
      final newWatchlist = await _watchlistService.addWatchlist(event.watchlistRequest);

      // Add the new watchlist and show success
      if (state is WatchlistLoaded) {
        final updatedState = (state as WatchlistLoaded).addWatchlist(newWatchlist);

        emit(updatedState.copyWith(
          currentOperation: WatchlistOperation.success(
            type: WatchlistOperationType.add,
            watchlistId: newWatchlist.id,
            watchlistName: newWatchlist.name,
            message: 'Watchlist "${newWatchlist.name}" created successfully',
          ),
        ));
      }
    } catch (e) {
      String errorMessage = 'Failed to create watchlist';
      if (e is DioException && e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          if (customResponse.message.isNotEmpty) {
            errorMessage = customResponse.message;
          }
        } catch (_) {
          // Use fallback message
        }
      }

      // Show error
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.add,
            message: errorMessage,
            watchlistName: event.watchlistRequest.name.trim(),
          ),
        ));
      }
    }
  }

  /// Handles updating an existing watchlist
  Future<void> _onUpdateWatchlist(
    UpdateWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    // Validate input
    if (event.watchlistRequest.name.trim().isEmpty) {
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.update,
            message: 'Watchlist name cannot be empty',
            watchlistId: event.id,
          ),
        ));
      }
      return;
    }

    if (event.watchlistRequest.name.trim().length > 50) {
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.update,
            message: 'Watchlist name cannot exceed 50 characters',
            watchlistId: event.id,
          ),
        ));
      }
      return;
    }

    // Ensure we have a loaded state
    if (state is! WatchlistLoaded) {
      add(const LoadWatchlists());
      return;
    }

    final currentState = state as WatchlistLoaded;

    // Emit loading state
    emit(currentState.copyWith(
      currentOperation: WatchlistOperation.loading(
        type: WatchlistOperationType.update,
        watchlistId: event.id,
        watchlistName: event.watchlistRequest.name.trim(),
      ),
    ));

    try {
      final updatedWatchlist = await _watchlistService.updateWatchlist(
        event.id,
        event.watchlistRequest,
      );

      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded)
            .updateWatchlist(updatedWatchlist)
            .copyWith(
              currentOperation: WatchlistOperation.success(
                type: WatchlistOperationType.update,
                watchlistId: updatedWatchlist.id,
                watchlistName: updatedWatchlist.name,
                message: 'Watchlist "${updatedWatchlist.name}" updated successfully',
              ),
            ));
      }
    } catch (e) {
      String errorMessage = 'Failed to update watchlist';
      if (e is DioException && e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          if (customResponse.message.isNotEmpty) {
            errorMessage = customResponse.message;
          }
        } catch (_) {
          // Use fallback message
        }
      }

      // Show error
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.update,
            message: errorMessage,
            watchlistId: event.id,
          ),
        ));
      }
    }
  }

  /// Handles deleting a watchlist
  Future<void> _onDeleteWatchlist(
    DeleteWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    // Ensure we have a loaded state
    if (state is! WatchlistLoaded) {
      add(const LoadWatchlists());
      return;
    }

    final currentState = state as WatchlistLoaded;

    // Find the watchlist to delete
    final watchlistToDelete = currentState.watchlists.firstWhere(
      (w) => w.id == event.id,
      orElse: () => WatchlistResponseDto(
        id: event.id,
        name: 'Unknown',
        isPublic: false,
      ),
    );

    // Emit loading state
    emit(currentState.copyWith(
      currentOperation: WatchlistOperation.loading(
        type: WatchlistOperationType.delete,
        watchlistId: event.id,
        watchlistName: watchlistToDelete.name,
      ),
    ));

    try {
      final response = await _watchlistService.deleteWatchlist(event.id);

      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded)
            .removeWatchlist(event.id)
            .copyWith(
              currentOperation: WatchlistOperation.success(
                type: WatchlistOperationType.delete,
                watchlistId: event.id,
                watchlistName: watchlistToDelete.name,
                message: response.message.isNotEmpty 
                    ? response.message 
                    : 'Watchlist "${watchlistToDelete.name}" deleted successfully',
              ),
            ));
      }
    } catch (e) {
      String errorMessage = 'Failed to delete watchlist';
      if (e is DioException && e.response?.data != null) {
        try {
          final customResponse = CustomResponseDto.fromJson(e.response!.data);
          if (customResponse.message.isNotEmpty) {
            errorMessage = customResponse.message;
          }
        } catch (_) {
          // Use fallback message
        }
      }

      // Show error
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.delete,
            message: errorMessage,
            watchlistId: event.id,
            watchlistName: watchlistToDelete.name,
          ),
        ));
      }
    }
  }

  /// Handles refreshing watchlists (used internally)
  Future<void> _onRefreshWatchlists(
    RefreshWatchlists event,
    Emitter<WatchlistState> emit,
  ) async {
    add(const LoadWatchlists());
  }

  /// Handles clearing the current operation state
  void _onClearOperationState(
    ClearWatchlistOperationState event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoaded) {
      emit((state as WatchlistLoaded).clearOperation());
    }
  }

}