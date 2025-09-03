import 'package:equatable/equatable.dart';
import '../../dto/request/content_request_dto.dart';

abstract class ContentEvent extends Equatable {
  const ContentEvent();

  @override
  List<Object?> get props => [];
}

class AddContentRequested extends ContentEvent {
  const AddContentRequested({required this.contentRequest});

  final ContentRequestDto contentRequest;

  @override
  List<Object?> get props => [contentRequest];
}

class UpdateContentRequested extends ContentEvent {
  const UpdateContentRequested({
    required this.contentId,
    required this.contentRequest,
  });

  final int contentId;
  final ContentRequestDto contentRequest;

  @override
  List<Object?> get props => [contentId, contentRequest];
}

class LoadContentRequested extends ContentEvent {
  const LoadContentRequested({
    this.genreFilter,
    this.contentTypeFilter,
  });

  final String? genreFilter;
  final String? contentTypeFilter;

  @override
  List<Object?> get props => [genreFilter, contentTypeFilter];
}

class ClearContent extends ContentEvent {
  const ClearContent();
}

class LoadContentTypesRequested extends ContentEvent {
  const LoadContentTypesRequested();
}

class LoadGenresRequested extends ContentEvent {
  const LoadGenresRequested();
}

class LoadMyContentsRequested extends ContentEvent {
  const LoadMyContentsRequested();
}

class DeleteContentRequested extends ContentEvent {
  const DeleteContentRequested({required this.contentId});

  final int contentId;

  @override
  List<Object?> get props => [contentId];
}