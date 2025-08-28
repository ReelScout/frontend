// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/content_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentRequestDto _$ContentRequestDtoFromJson(Map<String, dynamic> json) =>
    ContentRequestDto(
      title: json['title'] as String,
      description: json['description'] as String,
      contentType: json['contentType'] as String,
      actors: (json['actors'] as List<dynamic>)
          .map((e) => Actor.fromJson(e as Map<String, dynamic>))
          .toList(),
      directors: (json['directors'] as List<dynamic>)
          .map((e) => Director.fromJson(e as Map<String, dynamic>))
          .toList(),
      base64Image: json['base64Image'] as String?,
      trailerUrl: json['trailerUrl'] as String?,
    );

Map<String, dynamic> _$ContentRequestDtoToJson(ContentRequestDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'contentType': instance.contentType,
      'actors': instance.actors,
      'directors': instance.directors,
      'base64Image': instance.base64Image,
      'trailerUrl': instance.trailerUrl,
    };
