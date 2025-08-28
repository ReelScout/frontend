import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'generated/owner.g.dart';

@JsonSerializable()
class Owner {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String id;
  
  String firstName;
  String lastName;

  Owner({
    String? id,
    required this.firstName,
    required this.lastName,
  }) : id = id ?? const Uuid().v4();

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}