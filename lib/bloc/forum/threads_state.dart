import 'package:equatable/equatable.dart';
import 'package:frontend/dto/response/forum_thread_response_dto.dart';

class ThreadOperation extends Equatable {
  const ThreadOperation._({required this.isLoading, this.message});
  final bool isLoading;
  final String? message;

  factory ThreadOperation.loading() => const ThreadOperation._(isLoading: true);
  factory ThreadOperation.success([String? message]) => ThreadOperation._(isLoading: false, message: message);
  factory ThreadOperation.error(String message) => ThreadOperation._(isLoading: false, message: message);

  @override
  List<Object?> get props => [isLoading, message];
}

abstract class ThreadsState extends Equatable {
  const ThreadsState();
  @override
  List<Object?> get props => [];
}

class ThreadsInitial extends ThreadsState {
  const ThreadsInitial();
}

class ThreadsLoading extends ThreadsState {
  const ThreadsLoading();
}

class ThreadsLoaded extends ThreadsState {
  const ThreadsLoaded({required this.threads, this.currentOperation});
  final List<ForumThreadResponseDto> threads;
  final ThreadOperation? currentOperation;

  ThreadsLoaded copyWith({List<ForumThreadResponseDto>? threads, ThreadOperation? currentOperation}) =>
      ThreadsLoaded(threads: threads ?? this.threads, currentOperation: currentOperation);

  @override
  List<Object?> get props => [threads, currentOperation];
}

class ThreadsError extends ThreadsState {
  const ThreadsError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

