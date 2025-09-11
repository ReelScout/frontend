import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/services/content_service.dart';
import 'package:frontend/utils/error_utils.dart';

import 'content_stats_event.dart';
import 'content_stats_state.dart';

class ContentStatsBloc extends Bloc<ContentStatsEvent, ContentStatsState> {
  ContentStatsBloc({required ContentService contentService})
      : _contentService = contentService,
        super(ContentStatsInitial()) {
    on<LoadMyContentsStatsRequested>(_onLoadMyContentsStatsRequested);
  }

  final ContentService _contentService;

  Future<void> _onLoadMyContentsStatsRequested(
    LoadMyContentsStatsRequested event,
    Emitter<ContentStatsState> emit,
  ) async {
    emit(ContentStatsLoading());
    try {
      final stats = await _contentService.getMyContentsStats();
      emit(ContentStatsLoaded(rows: stats));
    } on DioException catch (e) {
      emit(ContentStatsError(message: mapDioError(e)));
    } catch (_) {
      emit(const ContentStatsError(message: kGenericErrorMessage));
    }
  }
}

