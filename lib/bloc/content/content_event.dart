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

class LoadContentRequested extends ContentEvent {
  const LoadContentRequested();
}

class ClearContent extends ContentEvent {
  const ClearContent();
}

class LoadContentTypesRequested extends ContentEvent {
  const LoadContentTypesRequested();
}