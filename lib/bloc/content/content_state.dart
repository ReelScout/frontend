import 'package:equatable/equatable.dart';
import '../../dto/response/content_response_dto.dart';

abstract class ContentState extends Equatable {
  const ContentState();

  @override
  List<Object?> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentLoaded extends ContentState {
  const ContentLoaded({required this.contents});

  final List<ContentResponseDto> contents;

  @override
  List<Object?> get props => [contents];
}

class ContentError extends ContentState {
  const ContentError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ContentAdding extends ContentState {}

class ContentAddSuccess extends ContentState {
  const ContentAddSuccess({
    required this.content,
    this.message,
  });

  final ContentResponseDto content;
  final String? message;

  @override
  List<Object?> get props => [content, message];
}

class ContentAddError extends ContentState {
  const ContentAddError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ContentUpdating extends ContentState {}

class ContentUpdateSuccess extends ContentState {
  const ContentUpdateSuccess({
    required this.content,
    this.message,
  });

  final ContentResponseDto content;
  final String? message;

  @override
  List<Object?> get props => [content, message];
}

class ContentUpdateError extends ContentState {
  const ContentUpdateError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ContentTypesLoading extends ContentState {}

class ContentTypesLoaded extends ContentState {
  const ContentTypesLoaded({required this.contentTypes});

  final List<String> contentTypes;

  @override
  List<Object?> get props => [contentTypes];
}

class ContentTypesError extends ContentState {
  const ContentTypesError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class GenresLoading extends ContentState {}

class GenresLoaded extends ContentState {
  const GenresLoaded({required this.genres});

  final List<String> genres;

  @override
  List<Object?> get props => [genres];
}

class GenresError extends ContentState {
  const GenresError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ContentDeleting extends ContentState {}

class ContentDeleteSuccess extends ContentState {
  const ContentDeleteSuccess({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class ContentDeleteError extends ContentState {
  const ContentDeleteError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}