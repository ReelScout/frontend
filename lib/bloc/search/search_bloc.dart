import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/services/search_service.dart';
import 'package:frontend/bloc/search/search_event.dart';
import 'package:frontend/bloc/search/search_state.dart';
import 'package:frontend/utils/error_utils.dart';

const _debounceDuration = Duration(milliseconds: 500);

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required SearchService searchService,
  }) : _searchService = searchService,
       super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchClearRequested>(_onSearchClearRequested);
  }

  final SearchService _searchService;
  Timer? _debounceTimer;

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    // Create a completer to handle the debounced search
    final completer = Completer<void>();
    
    // Start debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      completer.complete();
    });
    
    // Wait for the debounce timer to complete
    await completer.future;
    
    // Check if the emitter is still valid before proceeding
    if (emit.isDone) return;
    
    // Perform the search
    await _performSearch(query, emit);
  }

  Future<void> _performSearch(String query, Emitter<SearchState> emit) async {
    emit(SearchLoading());

    try {
      final results = await _searchService.search(query);
      
      final hasContents = results.contents.isNotEmpty;
      final hasUsers = results.users.isNotEmpty;
      
      if (!hasContents && !hasUsers) {
        emit(SearchEmpty(query: query));
      } else {
        emit(SearchLoaded(results: results, query: query));
      }
    } on DioException catch (e) {
      emit(SearchError(
        message: mapDioError(e),
        query: query,
      ));
    } catch (_) {
      emit(SearchError(
        message: kGenericErrorMessage,
        query: query,
      ));
    }
  }

  void _onSearchClearRequested(
    SearchClearRequested event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
