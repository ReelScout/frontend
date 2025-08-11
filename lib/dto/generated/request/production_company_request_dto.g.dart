// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../request/production_company_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductionCompanyRequestDto _$ProductionCompanyRequestDtoFromJson(
  Map<String, dynamic> json,
) => ProductionCompanyRequestDto(
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  base64Image: json['base64Image'] as String?,
  name: json['name'] as String,
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  website: json['website'] as String,
  owners: (json['owners'] as List<dynamic>)
      .map((e) => Owner.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProductionCompanyRequestDtoToJson(
  ProductionCompanyRequestDto instance,
) => <String, dynamic>{
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'base64Image': instance.base64Image,
  'name': instance.name,
  'location': instance.location,
  'website': instance.website,
  'owners': instance.owners,
};
