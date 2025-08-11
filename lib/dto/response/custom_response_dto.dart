import 'package:json_annotation/json_annotation.dart';

part '../generated/response/custom_response_dto.g.dart';

@JsonSerializable()
class CustomResponseDto {
  const CustomResponseDto({
    required this.message,
  });

  final String message;

  factory CustomResponseDto.fromJson(Map<String, dynamic> json) => _$CustomResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CustomResponseDtoToJson(this);
}