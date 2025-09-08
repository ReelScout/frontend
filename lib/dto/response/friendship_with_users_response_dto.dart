import 'package:frontend/dto/response/friendship_response_dto.dart';
import 'package:frontend/model/friendship_status.dart';
import 'package:frontend/dto/response/user_response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part '../generated/response/friendship_with_users_response_dto.g.dart';

@JsonSerializable()
class FriendshipWithUsersResponseDto extends FriendshipResponseDto {
  const FriendshipWithUsersResponseDto({
    required super.id,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required this.requester,
    required this.addressee,
  });

  final UserResponseDto requester;
  final UserResponseDto addressee;

  factory FriendshipWithUsersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FriendshipWithUsersResponseDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FriendshipWithUsersResponseDtoToJson(this);
}

