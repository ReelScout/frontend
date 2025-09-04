// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/member_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberRequestDto _$MemberRequestDtoFromJson(Map<String, dynamic> json) =>
    MemberRequestDto(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      base64Image: json['base64Image'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MemberRequestDtoToJson(MemberRequestDto instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'base64Image': instance.base64Image,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'birthDate': instance.birthDate.toIso8601String(),
      'favoriteGenres': instance.favoriteGenres,
    };
