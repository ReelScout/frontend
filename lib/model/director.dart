import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'generated/director.g.dart';

@JsonSerializable()
class Director {
  @JsonKey(includeFromJson: false, includeToJson: false)
  String id;
  
  String firstName;
  String lastName;

  Director({
    String? id,
    required this.firstName,
    required this.lastName,
  }) : id = id ?? const Uuid().v4();

  factory Director.fromJson(Map<String, dynamic> json) => _$DirectorFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorToJson(this);
}