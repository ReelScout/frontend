import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/dto/response/watchlist_response_dto.dart';
import 'package:frontend/services/watchlist_service.dart';
import 'package:frontend/utils/error_utils.dart';
import 'package:frontend/bloc/watchlist/watchlist_event.dart';
import 'package:frontend/bloc/watchlist/watchlist_state.dart';

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
    on<AddContentToWatchlist>(_onAddContentToWatchlist);
    on<RemoveContentFromWatchlist>(_onRemoveContentFromWatchlist);
    on<LoadWatchlistsByContentId>(_onLoadWatchlistsByContentId);
    on<LoadPublicWatchlistsByMemberId>(_onLoadPublicWatchlistsByMemberId);
    on<LoadWatchlistById>(_onLoadWatchlistById);
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
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(WatchlistError(message: msg));
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
      final errorMessage = e is DioException ? mapDioError(e) : kGenericErrorMessage;

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
      final errorMessage = e is DioException ? mapDioError(e) : kGenericErrorMessage;

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
      final errorMessage = e is DioException ? mapDioError(e) : kGenericErrorMessage;

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

  /// Handles adding content to a watchlist
  Future<void> _onAddContentToWatchlist(
      AddContentToWatchlist event,
      Emitter<WatchlistState> emit,
      ) async {
    final currentState = state as WatchlistLoaded;

    // Find the watchlist to add content to
    final watchlist = currentState.watchlists.firstWhere(
          (w) => w.id == event.watchlistId,
      orElse: () => WatchlistResponseDto(
        id: event.watchlistId,
        name: 'Unknown',
        isPublic: false,
      ),
    );

    // Emit loading state
    emit(currentState.copyWith(
      currentOperation: WatchlistOperation.loading(
        type: WatchlistOperationType.addContent,
        watchlistId: event.watchlistId,
        watchlistName: watchlist.name,
      ),
    ));

    try {
      await _watchlistService.addContentToWatchlist(
        event.watchlistId,
        event.contentId,
      );

      if (state is WatchlistLoaded) {
        // Update watchlistsWithContent to include this watchlist
        final currentWatchlistsWithContent = (state as WatchlistLoaded).watchlistsWithContent ?? [];
        final updatedWatchlistsWithContent = List<WatchlistResponseDto>.from(currentWatchlistsWithContent);

        // Add the watchlist if it's not already in the list
        if (!updatedWatchlistsWithContent.any((w) => w.id == watchlist.id)) {
          updatedWatchlistsWithContent.add(watchlist);
        }

        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.success(
            type: WatchlistOperationType.addContent,
            watchlistId: event.watchlistId,
            watchlistName: watchlist.name,
            message: 'Content added to "${watchlist.name}" successfully',
          ),
          watchlistsWithContent: updatedWatchlistsWithContent,
        ));
      }
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.addContent,
            watchlistId: event.watchlistId,
            watchlistName: watchlist.name,
            message: msg,
          ),
        ));
      }
    }
  }

  /// Handles removing content from a watchlist
  Future<void> _onRemoveContentFromWatchlist(
      RemoveContentFromWatchlist event,
      Emitter<WatchlistState> emit,
      ) async {
    final currentState = state as WatchlistLoaded;

    // Find the watchlist to remove content from
    final watchlist = currentState.watchlists.firstWhere(
          (w) => w.id == event.watchlistId,
      orElse: () => WatchlistResponseDto(
        id: event.watchlistId,
        name: 'Unknown',
        isPublic: false,
      ),
    );

    try {
      await _watchlistService.removeContentFromWatchlist(
        event.watchlistId,
        event.contentId,
      );

      if (state is WatchlistLoaded) {
        // Update watchlistsWithContent to remove this watchlist
        final currentWatchlistsWithContent = (state as WatchlistLoaded).watchlistsWithContent ?? [];
        final updatedWatchlistsWithContent = List<WatchlistResponseDto>.from(currentWatchlistsWithContent)
            .where((w) => w.id != event.watchlistId)
            .toList();

        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.success(
            type: WatchlistOperationType.removeContent,
            watchlistId: event.watchlistId,
            watchlistName: watchlist.name,
            message: 'Content removed from "${watchlist.name}" successfully',
          ),
          watchlistsWithContent: updatedWatchlistsWithContent,
        ));
      }
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      if (state is WatchlistLoaded) {
        emit((state as WatchlistLoaded).copyWith(
          currentOperation: WatchlistOperation.error(
            type: WatchlistOperationType.removeContent,
            watchlistId: event.watchlistId,
            watchlistName: watchlist.name,
            message: msg,
          ),
        ));
      }
    }
  }

  /// Handles loading watchlists that contain a specific content
  Future<void> _onLoadWatchlistsByContentId(
    LoadWatchlistsByContentId event,
    Emitter<WatchlistState> emit,
  ) async {
    // Ensure we have a loaded state with user's watchlists
    if (state is! WatchlistLoaded) {
      add(const LoadWatchlists());
      return;
    }

    final currentState = state as WatchlistLoaded;

    try {
      final watchlistsWithContent = await _watchlistService.getWatchlistsByContentId(event.contentId);

      emit(currentState.copyWith(
        watchlistsWithContent: watchlistsWithContent,
      ));
    } catch (e) {
      // If we can't load watchlists with content, just continue without this info
      // The dialog will work without pre-selecting checkboxes
      emit(currentState.copyWith(
        watchlistsWithContent: [],
      ));
    }
  }

  /// Handles loading public watchlists for a specific member
  Future<void> _onLoadPublicWatchlistsByMemberId(
    LoadPublicWatchlistsByMemberId event,
    Emitter<WatchlistState> emit,
  ) async {
    // We don't require a loaded state for this operation since it's independent
    // If state is initial, we'll create a minimal loaded state
    WatchlistLoaded currentState;
    if (state is WatchlistLoaded) {
      currentState = state as WatchlistLoaded;
    } else {
      currentState = const WatchlistLoaded(watchlists: []);
    }

    try {
      final publicWatchlists = await _watchlistService.getPublicWatchlistsByMemberId(event.memberId);

      emit(currentState.copyWith(
        publicWatchlists: publicWatchlists,
      ));
    } catch (e) {
      // If we can't load public watchlists, set empty list
      emit(currentState.copyWith(
        publicWatchlists: [],
      ));
    }
  }

  /// Handles loading a specific watchlist by ID with its contents
  Future<void> _onLoadWatchlistById(
    LoadWatchlistById event,
    Emitter<WatchlistState> emit,
  ) async {
    // We don't require a loaded state for this operation since it's independent
    // If state is initial, we'll create a minimal loaded state
    WatchlistLoaded currentState;
    if (state is WatchlistLoaded) {
      currentState = state as WatchlistLoaded;
    } else {
      currentState = const WatchlistLoaded(watchlists: []);
    }

    try {
      final watchlistDetails = await _watchlistService.getWatchlistById(event.watchlistId);

      emit(currentState.copyWith(
        watchlistDetails: watchlistDetails,
      ));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(WatchlistError(message: msg));
    }
  }

}
