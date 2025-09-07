import 'package:equatable/equatable.dart';
import 'package:frontend/dto/response/search_response_dto.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.results,
    required this.query,
  });

  final SearchResponseDto results;
  final String query;

  @override
  List<Object?> get props => [results, query];
}

class SearchEmpty extends SearchState {
  const SearchEmpty({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  const SearchError({
    required this.message,
    required this.query,
  });

  final String message;
  final String query;

  @override
  List<Object?> get props => [message, query];
}
