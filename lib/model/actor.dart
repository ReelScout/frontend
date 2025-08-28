import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'generated/actor.g.dart';

@JsonSerializable()
class Actor {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String id;
  
  String firstName;
  String lastName;

  Actor({
    String? id,
    required this.firstName,
    required this.lastName,
  }) : id = id ?? const Uuid().v4();

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

  Map<String, dynamic> toJson() => _$ActorToJson(this);
}