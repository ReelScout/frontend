import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum VerificationRequestStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('APPROVED')
  approved,

  @JsonValue('REJECTED')
  rejected,
}

