abstract class UserRequestDto {
  const UserRequestDto({
    required this.username,
    required this.email,
    required this.password,
    this.base64Image
  });

  final String username;
  final String email;
  final String password;
  final String? base64Image;

  Map<String, dynamic> toJson();
}
