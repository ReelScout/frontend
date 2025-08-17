import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:frontend/model/role.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../model/location.dart';
import '../../model/owner.dart';

part '../generated/response/production_company_response_dto.g.dart';

@JsonSerializable()
class ProductionCompanyResponseDto extends UserResponseDto {
  const ProductionCompanyResponseDto({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    super.base64Image,
    required this.name,
    required this.location,
    required this.website,
    required this.owners
  });

  final String name;
  final Location location;
  final String website;
  final List<Owner> owners;

  factory ProductionCompanyResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanyResponseDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProductionCompanyResponseDtoToJson(this);
}