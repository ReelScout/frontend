// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/create_thread_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateThreadRequestDto _$CreateThreadRequestDtoFromJson(
  Map<String, dynamic> json,
) => CreateThreadRequestDto(
  title: json['title'] as String,
  body: json['body'] as String,
);

Map<String, dynamic> _$CreateThreadRequestDtoToJson(
  CreateThreadRequestDto instance,
) => <String, dynamic>{'title': instance.title, 'body': instance.body};
