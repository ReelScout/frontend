import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchClearRequested extends SearchEvent {
  const SearchClearRequested();
}