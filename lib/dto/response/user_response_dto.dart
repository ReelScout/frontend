import 'package:frontend/dto/response/entity_response_dto.dart';

import '../../model/role.dart';

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
}