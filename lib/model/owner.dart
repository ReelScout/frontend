import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'generated/owner.g.dart';

@JsonSerializable()
class Owner {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String id;
  
  String firstName;
  String lastName;

  Owner({
    String? id,
    required this.firstName,
    required this.lastName,
  }) : id = id ?? const Uuid().v4();

  // Copy method for creating new instances with same ID
  Owner copyWith({
    String? firstName,
    String? lastName,
  }) {
    return Owner(
      id: id, // Keep the same ID
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}