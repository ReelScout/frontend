// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/member_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberResponseDto _$MemberResponseDtoFromJson(Map<String, dynamic> json) =>
    MemberResponseDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      role: $enumDecode(_$RoleEnumMap, json['role']),
      base64Image: json['base64Image'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MemberResponseDtoToJson(MemberResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'role': _$RoleEnumMap[instance.role]!,
      'base64Image': instance.base64Image,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'birthDate': instance.birthDate.toIso8601String(),
      'favoriteGenres': instance.favoriteGenres,
    };

const _$RoleEnumMap = {
  Role.member: 'MEMBER',
  Role.verifiedMember: 'VERIFIED_MEMBER',
  Role.moderator: 'MODERATOR',
  Role.productionCompany: 'PRODUCTION_COMPANY',
  Role.admin: 'ADMIN',
};
