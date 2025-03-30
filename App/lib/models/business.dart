
class business_data {
  final int id;
  final String name;
  final String address;
  final String time;
  final String number;
  final String description;
  final String image;
  final String url;

  business_data({
    required this.id,
    required this.name,
    required this.address,
    required this.time,
    required this.number,
    required this.description,
    required this.image,
    required this.url,
  });

  // 🔥 Supabase에서 가져온 `Map<String, dynamic>` 데이터를 `business_data` 객체로 변환
  factory business_data.fromMap(Map<String, dynamic> data) {
    return business_data(
      id: data["id"] ?? 0,
      name: data["name"] ?? "이름 없음",
      address: data["address"] ?? "주소 없음",
      time: data["time"] ?? "운영 시간 없음",
      number: data["number"] ?? "전화번호 없음",
      description: data["description"] ?? "설명 없음",
      image: data["image"] ?? "이미지 없음",
      url: data["url"] ?? "https://via.placeholder.com/300", // 기본 이미지
    );
  }
}