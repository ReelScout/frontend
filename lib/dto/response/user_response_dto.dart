import 'package:frontend/dto/response/entity_response_dto.dart';
import 'package:frontend/dto/response/production_company_response_dto.dart';
import '../../model/role.dart';
import 'member_response_dto.dart';

abstract class UserResponseDto extends EntityResponseDto {
  const UserResponseDto({
    required super.id,
    required this.username,
    required this.email,
    required this.role,
    this.base64Image
  });

  final String username;
  final String email;
  final Role role;
  final String? base64Image;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    switch (json['role']) {
      case Role.productionCompany: return ProductionCompanyResponseDto.fromJson(json);
      case Role.member: return MemberResponseDto.fromJson(json);
      case Role.verifiedMember: return MemberResponseDto.fromJson(json);
      case Role.moderator: return MemberResponseDto.fromJson(json);
      case Role.admin: return MemberResponseDto.fromJson(json);
      default: throw Exception('Unknown role: ${json['role']}');
    }
  }

  Map<String, dynamic> toJson();
}