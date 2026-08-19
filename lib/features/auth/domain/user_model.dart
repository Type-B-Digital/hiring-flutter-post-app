class UserModel {
  final int id;
  final String username;
  final String email;
  final String accessToken;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      username: json['username'].toString(),
      email: json['email'].toString(),
      accessToken: json['accessToken'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'accessToken': accessToken,
    };
  }
}
