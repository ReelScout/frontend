// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/watchlist_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchlistRequestDto _$WatchlistRequestDtoFromJson(Map<String, dynamic> json) =>
    WatchlistRequestDto(
      name: json['name'] as String,
      isPublic: json['isPublic'] as bool,
    );

Map<String, dynamic> _$WatchlistRequestDtoToJson(
  WatchlistRequestDto instance,
) => <String, dynamic>{'name': instance.name, 'isPublic': instance.isPublic};
