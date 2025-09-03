import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/content_service.dart';
import 'content_event.dart';
import 'content_state.dart';

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
    } catch (error) {
      emit(ContentAddError(
        message: error.toString(),
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
    } catch (error) {
      emit(ContentUpdateError(
        message: error.toString(),
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
    } catch (error) {
      emit(ContentDeleteError(
        message: error.toString(),
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
      
      // Apply client-side filtering
      List<dynamic> filteredContents = contents;
      
      if (event.genreFilter != null && event.genreFilter!.isNotEmpty) {
        filteredContents = filteredContents.where((content) {
          return content.genres.contains(event.genreFilter);
        }).toList();
      }
      
      if (event.contentTypeFilter != null && event.contentTypeFilter!.isNotEmpty) {
        filteredContents = filteredContents.where((content) {
          return content.contentType == event.contentTypeFilter;
        }).toList();
      }
      
      emit(ContentLoaded(contents: filteredContents.cast()));
    } catch (error) {
      emit(ContentError(
        message: error.toString(),
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
    } catch (error) {
      emit(ContentTypesError(
        message: error.toString(),
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
    } catch (error) {
      emit(GenresError(
        message: error.toString(),
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
    } catch (error) {
      emit(ContentError(
        message: error.toString(),
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