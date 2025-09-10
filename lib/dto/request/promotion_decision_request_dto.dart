import 'package:json_annotation/json_annotation.dart';

part '../generated/request/promotion_decision_request_dto.g.dart';

@JsonSerializable()
class PromotionDecisionRequestDto {
  const PromotionDecisionRequestDto({this.reason});

  final String? reason;

  factory PromotionDecisionRequestDto.fromJson(Map<String, dynamic> json) =>
      _$PromotionDecisionRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionDecisionRequestDtoToJson(this);
}
