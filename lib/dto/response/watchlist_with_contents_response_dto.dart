import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/dto/response/watchlist_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/watchlist_with_contents_response_dto.g.dart';

@JsonSerializable()
class WatchlistWithContentsDto extends WatchlistResponseDto {
  const WatchlistWithContentsDto({
    required super.id,
    required super.name,
    required super.isPublic,
    required this.contents,
  });

  final List<ContentResponseDto> contents;

  factory WatchlistWithContentsDto.fromJson(Map<String, dynamic> json) => _$WatchlistWithContentsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WatchlistWithContentsDtoToJson(this);
}