import 'package:frontend/dto/request/user_request_dto.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:frontend/model/location.dart';
import 'package:frontend/model/owner.dart';

part '../generated/request/production_company_request_dto.g.dart';

@JsonSerializable()
class ProductionCompanyRequestDto extends UserRequestDto {
  const ProductionCompanyRequestDto({
    required super.username,
    required super.email,
    required super.password,
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

  factory ProductionCompanyRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ProductionCompanyRequestDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProductionCompanyRequestDtoToJson(this);
}
