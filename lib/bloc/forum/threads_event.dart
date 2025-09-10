import 'package:equatable/equatable.dart';
import 'package:frontend/dto/request/create_thread_request_dto.dart';

abstract class ThreadsEvent extends Equatable {
  const ThreadsEvent();

  @override
  List<Object?> get props => [];
}

class LoadThreads extends ThreadsEvent {
  const LoadThreads({required this.contentId});
  final int contentId;
  @override
  List<Object?> get props => [contentId];
}

class CreateThread extends ThreadsEvent {
  const CreateThread({required this.contentId, required this.request});
  final int contentId;
  final CreateThreadRequestDto request;
  @override
  List<Object?> get props => [contentId, request];
}

class DeleteThread extends ThreadsEvent {
  const DeleteThread({required this.contentId, required this.threadId});
  final int contentId;
  final int threadId;
  @override
  List<Object?> get props => [contentId, threadId];
}
