class UserProfile {
  final String id;
  final String email;
  final int? point;
  final String? bId;

  UserProfile({
    required this.id,
    required this.email,
    this.point,
    this.bId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      point: json['point'],
      bId: json['b_id'],
    );
  }
}
