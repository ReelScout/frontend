// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/content_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentResponseDto _$ContentResponseDtoFromJson(Map<String, dynamic> json) =>
    ContentResponseDto(
      id: (json['id'] as num).toInt(),
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
      productionCompanyId: (json['productionCompanyId'] as num).toInt(),
      productionCompanyName: json['productionCompanyName'] as String,
    );

Map<String, dynamic> _$ContentResponseDtoToJson(ContentResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'contentType': instance.contentType,
      'actors': instance.actors,
      'directors': instance.directors,
      'base64Image': instance.base64Image,
      'trailerUrl': instance.trailerUrl,
      'productionCompanyId': instance.productionCompanyId,
      'productionCompanyName': instance.productionCompanyName,
    };
