import 'package:json_annotation/json_annotation.dart';

part 'generated/actor.g.dart';

@JsonSerializable()
class Actor {
  Actor({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

  Map<String, dynamic> toJson() => _$ActorToJson(this);
}