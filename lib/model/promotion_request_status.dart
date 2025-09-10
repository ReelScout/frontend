import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PromotionRequestStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('APPROVED')
  approved,

  @JsonValue('REJECTED')
  rejected,
}

