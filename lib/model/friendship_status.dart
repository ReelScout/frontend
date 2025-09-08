import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum FriendshipStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('ACCEPTED')
  accepted,

  @JsonValue('REJECTED')
  rejected,
}

