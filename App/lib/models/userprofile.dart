class UserProfile {
  final String id;
  final String email;
  final int? point;
  final String? bId;
  final String? code;

  UserProfile({
    required this.id,
    required this.email,
    this.point,
    this.bId,
    this.code,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
  return UserProfile(
    id: json['id'].toString(),           // 🔄 int -> String
    email: json['email'].toString(),     // 🔄
    point: json['point'],
    bId: json['b_id']?.toString(),
    code: json['code']?.toString(),      // 🔄 int일 수도 있으니 toString 처리
  );

  }
}
