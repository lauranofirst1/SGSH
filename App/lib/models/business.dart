class business_data {
  final int id;
  final String name;
  final String address;
  final String time;
  final String number;
  final String description;
  final String image;
  final String url;
  final String lat;
  final String lng;
  final List<String> tags;
  final int category;

  business_data({
    required this.id,
    required this.name,
    required this.address,
    required this.time,
    required this.number,
    required this.description,
    required this.image,
    required this.url,
    required this.lat,
    required this.lng,
    required this.tags,
    required this.category,
  });

  factory business_data.fromMap(Map<String, dynamic> data) {
    String clean(String? value, String fallback) =>
        (value != null && value.trim().isNotEmpty) ? value : fallback;

    List<String> parseTags(dynamic tags) {
      if (tags == null) return [];
      if (tags is String) {
        return tags
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    return business_data(
      id: data["id"] ?? 0,
      name: clean(data["name"], "이름 없음"),
      address: clean(data["address"], "주소 없음"),
      time: clean(data["time"], "운영 시간 없음"),
      number: clean(data["number"], "전화번호 없음"),
      description: clean(data["description"], "설명 없음"),
      image: clean(data["image"], "이미지 없음"),
      url: clean(data["url"], "https://via.placeholder.com/300"),
      lat: (data["lat"] ?? '0.0').toString(),
      lng: (data["lng"] ?? '0.0').toString(),
      tags: parseTags(data["tags"]),
      category:
          data["category"] is int
              ? data["category"]
              : int.tryParse(data["category"].toString()) ?? 0, // ✅ 이 라인 수정
    );
  }

  /// 🔥 double 타입의 위도/경도 getter
  double? get latDouble => double.tryParse(lat);
  double? get lngDouble => double.tryParse(lng);
}
