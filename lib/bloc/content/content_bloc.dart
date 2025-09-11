import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/services/content_service.dart';
import 'package:frontend/bloc/content/content_event.dart';
import 'package:frontend/bloc/content/content_state.dart';
import 'package:frontend/utils/error_utils.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc({
    required ContentService contentService,
  }) : _contentService = contentService,
       super(ContentInitial()) {
    on<AddContentRequested>(_onAddContentRequested);
    on<UpdateContentRequested>(_onUpdateContentRequested);
    on<DeleteContentRequested>(_onDeleteContentRequested);
    on<LoadContentRequested>(_onLoadContentRequested);
    on<LoadContentTypesRequested>(_onLoadContentTypesRequested);
    on<LoadGenresRequested>(_onLoadGenresRequested);
    on<LoadMyContentsRequested>(_onLoadMyContentsRequested);
    on<ClearContent>(_onClearContent);
  }

  final ContentService _contentService;

  Future<void> _onAddContentRequested(
    AddContentRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentAdding());
    
    try {
      final content = await _contentService.addContent(event.contentRequest);
      emit(ContentAddSuccess(
        content: content,
        message: 'Content added successfully!',
      ));
    } on DioException catch (e) {
      emit(ContentAddError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const ContentAddError(
        message: kGenericErrorMessage,
      ));
    }
  }


  Future<void> _onUpdateContentRequested(
    UpdateContentRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentUpdating());
    
    try {
      final content = await _contentService.updateContent(event.contentId, event.contentRequest);
      emit(ContentUpdateSuccess(
        content: content,
        message: 'Content updated successfully!',
      ));
    } on DioException catch (e) {
      emit(ContentUpdateError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const ContentUpdateError(
        message: kGenericErrorMessage,
      ));
    }
  }

  Future<void> _onDeleteContentRequested(
    DeleteContentRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentDeleting());
    
    try {
      await _contentService.deleteContent(event.contentId);
      emit(const ContentDeleteSuccess(
        message: 'Content deleted successfully!',
      ));
    } on DioException catch (e) {
      emit(ContentDeleteError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const ContentDeleteError(
        message: kGenericErrorMessage,
      ));
    }
  }

  Future<void> _onLoadContentRequested(
    LoadContentRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    
    try {
      final contents = await _contentService.getAllContent();

      // Apply client-side filtering with strong typing
      List<ContentResponseDto> filtered = contents;

      if (event.genreFilter != null && event.genreFilter!.isNotEmpty) {
        final genre = event.genreFilter!;
        filtered = filtered.where((c) => c.genres.contains(genre)).toList();
      }

      if (event.contentTypeFilter != null && event.contentTypeFilter!.isNotEmpty) {
        final type = event.contentTypeFilter!;
        filtered = filtered.where((c) => c.contentType == type).toList();
      }

      emit(ContentLoaded(contents: filtered));
    } on DioException catch (e) {
      emit(ContentError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const ContentError(
        message: kGenericErrorMessage,
      ));
    }
  }

  Future<void> _onLoadContentTypesRequested(
    LoadContentTypesRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentTypesLoading());
    
    try {
      final contentTypes = await _contentService.getContentTypes();
      emit(ContentTypesLoaded(contentTypes: contentTypes));
    } on DioException catch (e) {
      emit(ContentTypesError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const ContentTypesError(
        message: kGenericErrorMessage,
      ));
    }
  }

  Future<void> _onLoadGenresRequested(
    LoadGenresRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(GenresLoading());
    
    try {
      final genres = await _contentService.getGenres();
      emit(GenresLoaded(genres: genres));
    } on DioException catch (e) {
      emit(GenresError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const GenresError(
        message: kGenericErrorMessage,
      ));
    }
  }

  Future<void> _onLoadMyContentsRequested(
    LoadMyContentsRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    
    try {
      final contents = await _contentService.getMyContents();
      emit(ContentLoaded(contents: contents));
    } on DioException catch (e) {
      emit(ContentError(
        message: mapDioError(e),
      ));
    } catch (_) {
      emit(const ContentError(
        message: kGenericErrorMessage,
      ));
    }
  }

  void _onClearContent(
    ClearContent event,
    Emitter<ContentState> emit,
  ) {
    emit(ContentInitial());
  }
}
