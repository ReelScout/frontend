import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();
  @override
  List<Object?> get props => [];
}

class LoadPosts extends PostsEvent {
  const LoadPosts({required this.threadId});
  final int threadId;
  @override
  List<Object?> get props => [threadId];
}

class CreatePost extends PostsEvent {
  const CreatePost({required this.threadId, required this.body, this.parentId});
  final int threadId;
  final String body;
  final int? parentId;
  @override
  List<Object?> get props => [threadId, body, parentId];
}

class ReportPost extends PostsEvent {
  const ReportPost({required this.postId, required this.reason});
  final int postId;
  final String reason;
  @override
  List<Object?> get props => [postId, reason];
}
