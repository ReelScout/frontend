import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/forum/threads_event.dart';
import 'package:frontend/bloc/forum/threads_state.dart';
import 'package:frontend/services/forum_service.dart';
import 'package:frontend/utils/error_utils.dart';

class ThreadsBloc extends Bloc<ThreadsEvent, ThreadsState> {
  ThreadsBloc({required ForumService forumService})
      : _forumService = forumService,
        super(const ThreadsInitial()) {
    on<LoadThreads>(_onLoadThreads);
    on<CreateThread>(_onCreateThread);
    on<DeleteThread>(_onDeleteThread);
  }

  final ForumService _forumService;

  Future<void> _onLoadThreads(LoadThreads event, Emitter<ThreadsState> emit) async {
    emit(const ThreadsLoading());
    try {
      final threads = await _forumService.getThreadsByContent(event.contentId);
      emit(ThreadsLoaded(threads: threads));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(ThreadsError(message: msg));
    }
  }

  Future<void> _onCreateThread(CreateThread event, Emitter<ThreadsState> emit) async {
    // Ensure we have a loaded state for optimistic update-like UX
    if (state is! ThreadsLoaded) {
      add(LoadThreads(contentId: event.contentId));
      return;
    }
    final current = state as ThreadsLoaded;
    emit(current.copyWith(currentOperation: ThreadOperation.loading()));
    try {
      await _forumService.createThread(event.contentId, event.request);
      // reload
      final threads = await _forumService.getThreadsByContent(event.contentId);
      emit(ThreadsLoaded(threads: threads, currentOperation: ThreadOperation.success('Thread created')));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(current.copyWith(currentOperation: ThreadOperation.error(msg)));
    }
  }

  Future<void> _onDeleteThread(DeleteThread event, Emitter<ThreadsState> emit) async {
    if (state is! ThreadsLoaded) {
      add(LoadThreads(contentId: event.contentId));
      return;
    }
    final current = state as ThreadsLoaded;
    emit(current.copyWith(currentOperation: ThreadOperation.loading()));
    try {
      await _forumService.deleteThread(event.threadId);
      final threads = await _forumService.getThreadsByContent(event.contentId);
      emit(ThreadsLoaded(threads: threads, currentOperation: ThreadOperation.success('Thread deleted')));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(current.copyWith(currentOperation: ThreadOperation.error(msg)));
    }
  }
}
