// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/watchlist_with_contents_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchlistWithContentsDto _$WatchlistWithContentsDtoFromJson(
  Map<String, dynamic> json,
) => WatchlistWithContentsDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isPublic: json['isPublic'] as bool,
  contents: (json['contents'] as List<dynamic>)
      .map((e) => ContentResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WatchlistWithContentsDtoToJson(
  WatchlistWithContentsDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isPublic': instance.isPublic,
  'contents': instance.contents,
};
