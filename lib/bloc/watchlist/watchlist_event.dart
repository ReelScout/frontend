import 'package:equatable/equatable.dart';
import 'package:frontend/dto/request/watchlist_request_dto.dart';

/// Base class for all watchlist-related events
abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the user's watchlists from the server
/// This is typically called when the page is first loaded or needs to be refreshed
class LoadWatchlists extends WatchlistEvent {
  const LoadWatchlists();

  @override
  String toString() => 'LoadWatchlists()';
}

/// Event to create a new watchlist
/// 
/// [watchlistRequest] contains the name and privacy settings for the new watchlist
/// Validation is performed in the BLoC to ensure data integrity
class AddWatchlist extends WatchlistEvent {
  const AddWatchlist({
    required this.watchlistRequest,
  });

  final WatchlistRequestDto watchlistRequest;

  @override
  List<Object?> get props => [watchlistRequest];

  @override
  String toString() => 'AddWatchlist(name: ${watchlistRequest.name}, isPublic: ${watchlistRequest.isPublic})';
}

/// Event to update an existing watchlist
/// 
/// [id] is the unique identifier of the watchlist to update
/// [watchlistRequest] contains the updated name and privacy settings
/// Validation is performed in the BLoC to ensure data integrity
class UpdateWatchlist extends WatchlistEvent {
  const UpdateWatchlist({
    required this.id,
    required this.watchlistRequest,
  });

  final int id;
  final WatchlistRequestDto watchlistRequest;

  @override
  List<Object?> get props => [id, watchlistRequest];

  @override
  String toString() => 'UpdateWatchlist(id: $id, name: ${watchlistRequest.name}, isPublic: ${watchlistRequest.isPublic})';
}

/// Event to delete an existing watchlist
/// 
/// [id] is the unique identifier of the watchlist to delete
class DeleteWatchlist extends WatchlistEvent {
  const DeleteWatchlist({
    required this.id,
  });

  final int id;

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'DeleteWatchlist(id: $id)';
}

/// Event to refresh watchlists after an operation completes
/// This is used internally by the BLoC and should not be dispatched directly from UI
class RefreshWatchlists extends WatchlistEvent {
  const RefreshWatchlists();

  @override
  String toString() => 'RefreshWatchlists()';
}

/// Event to clear any current operation state
/// Useful for resetting UI after showing success/error messages
class ClearWatchlistOperationState extends WatchlistEvent {
  const ClearWatchlistOperationState();

  @override
  String toString() => 'ClearWatchlistOperationState()';
}

/// Event to add content to a specific watchlist
/// 
/// [watchlistId] is the unique identifier of the watchlist to add content to
/// [contentId] is the unique identifier of the content to add
class AddContentToWatchlist extends WatchlistEvent {
  const AddContentToWatchlist({
    required this.watchlistId,
    required this.contentId,
  });

  final int watchlistId;
  final int contentId;

  @override
  List<Object?> get props => [watchlistId, contentId];

  @override
  String toString() => 'AddContentToWatchlist(watchlistId: $watchlistId, contentId: $contentId)';
}

/// Event to remove content from a specific watchlist
/// 
/// [watchlistId] is the unique identifier of the watchlist to remove content from
/// [contentId] is the unique identifier of the content to remove
class RemoveContentFromWatchlist extends WatchlistEvent {
  const RemoveContentFromWatchlist({
    required this.watchlistId,
    required this.contentId,
  });

  final int watchlistId;
  final int contentId;

  @override
  List<Object?> get props => [watchlistId, contentId];

  @override
  String toString() => 'RemoveContentFromWatchlist(watchlistId: $watchlistId, contentId: $contentId)';
}

/// Event to load watchlists that contain a specific content
/// 
/// [contentId] is the unique identifier of the content to check
class LoadWatchlistsByContentId extends WatchlistEvent {
  const LoadWatchlistsByContentId({
    required this.contentId,
  });

  final int contentId;

  @override
  List<Object?> get props => [contentId];

  @override
  String toString() => 'LoadWatchlistsByContentId(contentId: $contentId)';
}

/// Event to load public watchlists for a specific member
/// 
/// [memberId] is the unique identifier of the member whose public watchlists to load
class LoadPublicWatchlistsByMemberId extends WatchlistEvent {
  const LoadPublicWatchlistsByMemberId({
    required this.memberId,
  });

  final int memberId;

  @override
  List<Object?> get props => [memberId];

  @override
  String toString() => 'LoadPublicWatchlistsByMemberId(memberId: $memberId)';
}

/// Event to load a specific watchlist by ID with its contents
/// 
/// [watchlistId] is the unique identifier of the watchlist to load
class LoadWatchlistById extends WatchlistEvent {
  const LoadWatchlistById({
    required this.watchlistId,
  });

  final int watchlistId;

  @override
  List<Object?> get props => [watchlistId];

  @override
  String toString() => 'LoadWatchlistById(watchlistId: $watchlistId)';
}
