// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/search_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseDto _$SearchResponseDtoFromJson(Map<String, dynamic> json) =>
    SearchResponseDto(
      users: (json['users'] as List<dynamic>)
          .map((e) => UserResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      contents: (json['contents'] as List<dynamic>)
          .map((e) => ContentResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchResponseDtoToJson(SearchResponseDto instance) =>
    <String, dynamic>{'users': instance.users, 'contents': instance.contents};
