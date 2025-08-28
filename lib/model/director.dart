import 'package:json_annotation/json_annotation.dart';

part 'generated/director.g.dart';

@JsonSerializable()
class Director {
  Director({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  factory Director.fromJson(Map<String, dynamic> json) => _$DirectorFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorToJson(this);
}