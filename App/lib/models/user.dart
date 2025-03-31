class UserData {
  final String name;
  final String email;
  final String joinDate;

  UserData({
    required this.name,
    required this.email,
    required this.joinDate,
  });

  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      name: data["name"] ?? "이름 없음",
      email: data["email"] ?? "이메일 없음",
      joinDate: data["joinDate"] ?? "가입 날짜 없음",
    );
  }
}
