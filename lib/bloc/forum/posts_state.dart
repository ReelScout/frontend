import 'package:equatable/equatable.dart';
import 'package:frontend/dto/response/forum_post_response_dto.dart';

class PostOperation extends Equatable {
  const PostOperation._({required this.isLoading, this.message});
  final bool isLoading;
  final String? message;

  factory PostOperation.loading() => const PostOperation._(isLoading: true);
  factory PostOperation.success([String? message]) => PostOperation._(isLoading: false, message: message);
  factory PostOperation.error(String message) => PostOperation._(isLoading: false, message: message);

  @override
  List<Object?> get props => [isLoading, message];
}

abstract class PostsState extends Equatable {
  const PostsState();
  @override
  List<Object?> get props => [];
}

class PostsInitial extends PostsState {
  const PostsInitial();
}

class PostsLoading extends PostsState {
  const PostsLoading();
}

class PostsLoaded extends PostsState {
  const PostsLoaded({required this.posts, this.currentOperation});
  final List<ForumPostResponseDto> posts;
  final PostOperation? currentOperation;

  PostsLoaded copyWith({List<ForumPostResponseDto>? posts, PostOperation? currentOperation}) =>
      PostsLoaded(posts: posts ?? this.posts, currentOperation: currentOperation);

  @override
  List<Object?> get props => [posts, currentOperation];
}

class PostsError extends PostsState {
  const PostsError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

