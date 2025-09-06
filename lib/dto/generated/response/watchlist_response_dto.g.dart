// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/watchlist_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchlistResponseDto _$WatchlistResponseDtoFromJson(
  Map<String, dynamic> json,
) => WatchlistResponseDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isPublic: json['isPublic'] as bool,
);

Map<String, dynamic> _$WatchlistResponseDtoToJson(
  WatchlistResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isPublic': instance.isPublic,
};
