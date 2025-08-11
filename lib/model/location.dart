import 'package:json_annotation/json_annotation.dart';

part 'generated/location.g.dart';

@JsonSerializable()
class Location {
  String address;
  String city;
  String state;
  String country;
  String postalCode;

  Location({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}