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
    on<LoadContentRequested>(_onLoadContentRequested);
    on<LoadContentTypesRequested>(_onLoadContentTypesRequested);
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

  Future<void> _onLoadContentRequested(
    LoadContentRequested event,
    Emitter<ContentState> emit,
  ) async {
    emit(ContentLoading());
    
    try {
      final contents = await _contentService.getAllContent();
      emit(ContentLoaded(contents: contents));
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

  void _onClearContent(
    ClearContent event,
    Emitter<ContentState> emit,
  ) {
    emit(ContentInitial());
  }
}