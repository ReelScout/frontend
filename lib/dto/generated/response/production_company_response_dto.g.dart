// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../response/production_company_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductionCompanyResponseDto _$ProductionCompanyResponseDtoFromJson(
  Map<String, dynamic> json,
) => ProductionCompanyResponseDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role']),
  base64Image: json['base64Image'] as String?,
  name: json['name'] as String,
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  website: json['website'] as String,
  owners: (json['owners'] as List<dynamic>)
      .map((e) => Owner.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProductionCompanyResponseDtoToJson(
  ProductionCompanyResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'role': _$RoleEnumMap[instance.role]!,
  'base64Image': instance.base64Image,
  'name': instance.name,
  'location': instance.location,
  'website': instance.website,
  'owners': instance.owners,
};

const _$RoleEnumMap = {
  Role.member: 'MEMBER',
  Role.verifiedMember: 'VERIFIED_MEMBER',
  Role.moderator: 'MODERATOR',
  Role.productionCompany: 'PRODUCTION_COMPANY',
  Role.admin: 'ADMIN',
};
