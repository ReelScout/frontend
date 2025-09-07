import 'package:equatable/equatable.dart';
import '../../dto/response/watchlist_response_dto.dart';

/// Base class for all watchlist states
abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the BLoC is first created
class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();

  @override
  String toString() => 'WatchlistInitial()';
}

/// State indicating watchlists are being loaded from the server
class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();

  @override
  String toString() => 'WatchlistLoading()';
}

/// State containing the loaded watchlists and current operation status
class WatchlistLoaded extends WatchlistState {
  const WatchlistLoaded({
    required this.watchlists,
    this.currentOperation,
    this.watchlistsWithContent,
  });

  final List<WatchlistResponseDto> watchlists;
  final WatchlistOperation? currentOperation;
  final List<WatchlistResponseDto>? watchlistsWithContent;

  @override
  List<Object?> get props => [watchlists, currentOperation, watchlistsWithContent];

  @override
  String toString() => 'WatchlistLoaded(count: ${watchlists.length}, operation: $currentOperation)';

  /// Helper method to create a copy with updated watchlists
  WatchlistLoaded copyWith({
    List<WatchlistResponseDto>? watchlists,
    WatchlistOperation? currentOperation,
    List<WatchlistResponseDto>? watchlistsWithContent,
  }) {
    return WatchlistLoaded(
      watchlists: watchlists ?? this.watchlists,
      currentOperation: currentOperation ?? this.currentOperation,
      watchlistsWithContent: watchlistsWithContent ?? this.watchlistsWithContent,
    );
  }

  /// Helper method to clear the current operation
  WatchlistLoaded clearOperation() {
    return WatchlistLoaded(
      watchlists: watchlists,
      currentOperation: null,
      watchlistsWithContent: watchlistsWithContent,
    );
  }

  /// Helper method to update a specific watchlist in the list
  WatchlistLoaded updateWatchlist(WatchlistResponseDto updatedWatchlist) {
    final updatedList = watchlists.map((w) => 
      w.id == updatedWatchlist.id ? updatedWatchlist : w
    ).toList();
    
    return WatchlistLoaded(
      watchlists: updatedList,
      currentOperation: currentOperation,
      watchlistsWithContent: watchlistsWithContent,
    );
  }

  /// Helper method to add a watchlist to the list
  WatchlistLoaded addWatchlist(WatchlistResponseDto newWatchlist) {
    return WatchlistLoaded(
      watchlists: [...watchlists, newWatchlist],
      currentOperation: currentOperation,
      watchlistsWithContent: watchlistsWithContent,
    );
  }

  /// Helper method to remove a watchlist from the list
  WatchlistLoaded removeWatchlist(int watchlistId) {
    final updatedList = watchlists.where((w) => w.id != watchlistId).toList();
    
    return WatchlistLoaded(
      watchlists: updatedList,
      currentOperation: currentOperation,
      watchlistsWithContent: watchlistsWithContent,
    );
  }
}

/// State indicating a general error occurred (usually during initial loading)
class WatchlistError extends WatchlistState {
  const WatchlistError({
    required this.message,
    this.watchlists = const [],
  });

  final String message;
  final List<WatchlistResponseDto> watchlists; // Keep existing watchlists if available

  @override
  List<Object?> get props => [message, watchlists];

  @override
  String toString() => 'WatchlistError(message: $message, watchlistCount: ${watchlists.length})';
}

/// Represents the current operation being performed on watchlists
class WatchlistOperation extends Equatable {
  const WatchlistOperation({
    required this.type,
    required this.status,
    this.watchlistId,
    this.watchlistName,
    this.message,
  });

  final WatchlistOperationType type;
  final WatchlistOperationStatus status;
  final int? watchlistId;
  final String? watchlistName;
  final String? message;

  @override
  List<Object?> get props => [type, status, watchlistId, watchlistName, message];

  @override
  String toString() => 'WatchlistOperation(type: $type, status: $status, id: $watchlistId, name: $watchlistName)';

  /// Helper method to create a loading operation
  static WatchlistOperation loading({
    required WatchlistOperationType type,
    int? watchlistId,
    String? watchlistName,
  }) {
    return WatchlistOperation(
      type: type,
      status: WatchlistOperationStatus.loading,
      watchlistId: watchlistId,
      watchlistName: watchlistName,
    );
  }

  /// Helper method to create a success operation
  static WatchlistOperation success({
    required WatchlistOperationType type,
    int? watchlistId,
    String? watchlistName,
    String? message,
  }) {
    return WatchlistOperation(
      type: type,
      status: WatchlistOperationStatus.success,
      watchlistId: watchlistId,
      watchlistName: watchlistName,
      message: message,
    );
  }

  /// Helper method to create an error operation
  static WatchlistOperation error({
    required WatchlistOperationType type,
    required String message,
    int? watchlistId,
    String? watchlistName,
  }) {
    return WatchlistOperation(
      type: type,
      status: WatchlistOperationStatus.error,
      watchlistId: watchlistId,
      watchlistName: watchlistName,
      message: message,
    );
  }
}

/// Types of operations that can be performed on watchlists
enum WatchlistOperationType {
  add,
  update,
  delete,
  addContent,
  removeContent,
}

/// Status of a watchlist operation
enum WatchlistOperationStatus {
  loading,
  success,
  error,
}