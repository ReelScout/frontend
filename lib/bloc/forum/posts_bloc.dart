import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/forum/posts_event.dart';
import 'package:frontend/bloc/forum/posts_state.dart';
import 'package:frontend/dto/request/create_post_request_dto.dart';
import 'package:frontend/dto/request/report_post_request_dto.dart';
import 'package:frontend/services/forum_service.dart';
import 'package:frontend/utils/error_utils.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc({required ForumService forumService})
      : _forumService = forumService,
        super(const PostsInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePost>(_onCreatePost);
    on<ReportPost>(_onReportPost);
    on<DeletePost>(_onDeletePost);
  }

  final ForumService _forumService;

  Future<void> _onLoadPosts(LoadPosts event, Emitter<PostsState> emit) async {
    emit(const PostsLoading());
    try {
      final posts = await _forumService.getPostsByThread(event.threadId);
      emit(PostsLoaded(posts: posts));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(PostsError(message: msg));
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<PostsState> emit) async {
    if (state is! PostsLoaded) {
      add(LoadPosts(threadId: event.threadId));
      return;
    }
    final current = state as PostsLoaded;
    emit(current.copyWith(currentOperation: PostOperation.loading()));
    try {
      await _forumService.createPost(
        event.threadId,
        CreatePostRequestDto(body: event.body, parentId: event.parentId),
      );
      final posts = await _forumService.getPostsByThread(event.threadId);
      emit(PostsLoaded(posts: posts, currentOperation: PostOperation.success('Posted')));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(current.copyWith(currentOperation: PostOperation.error(msg)));
    }
  }

  Future<void> _onReportPost(ReportPost event, Emitter<PostsState> emit) async {
    if (state is! PostsLoaded) {
      // No need to reload posts just to report; keep state minimal
      emit(const PostsLoading());
      try {
        await _forumService.reportPost(event.postId, ReportPostRequestDto(reason: event.reason));
        emit(PostsLoaded(posts: const [], currentOperation: PostOperation.success('Report sent')));
      } catch (e) {
        final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
        emit(PostsError(message: msg));
      }
      return;
    }
    final current = state as PostsLoaded;
    emit(current.copyWith(currentOperation: PostOperation.loading()));
    try {
      await _forumService.reportPost(event.postId, ReportPostRequestDto(reason: event.reason));
      emit(current.copyWith(currentOperation: PostOperation.success('Report sent')));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(current.copyWith(currentOperation: PostOperation.error(msg)));
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<PostsState> emit) async {
    if (state is! PostsLoaded) {
      add(LoadPosts(threadId: event.threadId));
      return;
    }
    final current = state as PostsLoaded;
    emit(current.copyWith(currentOperation: PostOperation.loading()));
    try {
      await _forumService.deletePost(event.postId);
      final posts = await _forumService.getPostsByThread(event.threadId);
      emit(PostsLoaded(posts: posts, currentOperation: PostOperation.success('Post deleted')));
    } catch (e) {
      final msg = e is DioException ? mapDioError(e) : kGenericErrorMessage;
      emit(current.copyWith(currentOperation: PostOperation.error(msg)));
    }
  }
}
