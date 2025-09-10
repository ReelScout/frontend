import 'package:json_annotation/json_annotation.dart';

part '../generated/request/promotion_request_create_dto.g.dart';

@JsonSerializable()
class PromotionRequestCreateDto {
  const PromotionRequestCreateDto({this.message});

  final String? message;

  factory PromotionRequestCreateDto.fromJson(Map<String, dynamic> json) =>
      _$PromotionRequestCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionRequestCreateDtoToJson(this);
}
