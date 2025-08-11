import 'package:json_annotation/json_annotation.dart';

part 'generated/owner.g.dart';

@JsonSerializable()
class Owner {
  String firstName;
  String lastName;

  Owner({
    required this.firstName,
    required this.lastName,
  });

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}