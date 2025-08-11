import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Role {
  @JsonValue('MEMBER')
  member,

  @JsonValue('VERIFIED_MEMBER')
  verifiedMember,

  @JsonValue('MODERATOR')
  moderator,

  @JsonValue('PRODUCTION_COMPANY')
  productionCompany,

  @JsonValue('ADMIN')
  admin
}
