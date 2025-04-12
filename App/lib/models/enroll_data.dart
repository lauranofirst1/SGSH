class enroll_data {
  final int id;
  final bool check;
  final String name;
  final String phone;
  final String businessName;
  final String address;
  final String time;
  final String image;

  enroll_data({
    required this.id,
    required this.check,
    required this.name,
    required this.phone,
    required this.businessName,
    required this.address,
    required this.time,
    required this.image,
  });

  factory enroll_data.fromMap(Map<String, dynamic> data) {
    String safeString(dynamic val, [String fallback = '정보 없음']) {
      return (val is String && val.trim().isNotEmpty) ? val : fallback;
    }

    String safeImage(dynamic val) {
      final url = val?.toString() ?? '';
      return url.startsWith('http')
          ? url
          : "assets/images/noimage.png";
    }

    return enroll_data(
      id: data['id'] is int ? data['id'] : 0,
      check: data['check'] is bool ? data['check'] : false,
      name: safeString(data['name'], '이름 없음'),
      phone: safeString(data['phone'], '전화번호 없음'),
      businessName: safeString(data['business_name'], '가게 이름 없음'),
      address: safeString(data['address'], '주소 없음'),
      time: safeString(data['time'], '운영 시간 없음'),
      image: safeImage(data['image']),
    );
  }
}
