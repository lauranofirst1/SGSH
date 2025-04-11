// menu_data

// id: 정렬용 인덱스
// b_id: business_data 정보의 id
// name: 메뉴 이름
// price: 가격
// description: 메뉴 설명
// image: 메뉴 이미지
class menu_data {
  final int id;
  final int b_id; // 🔥 b_id를 int로 변경
  final String name;
  final int price;
  final String description;
  final String image;

  menu_data({
    required this.id,
    required this.b_id, // 🔥 int 유지
    required this.name,
    required this.price,
    required this.description,
    required this.image,
  });

  factory menu_data.fromMap(Map<String, dynamic> data) {
    return menu_data(
      id: data["id"] as int,
      b_id: data["b_id"] as int, // 🔥 int로 변환
      name: data["name"] ?? "이름 없음",
      price: data["price"] as int, //
      description: data["description"] ?? "설명 없음",
      image: data["image"] ?? "이미지 없음",
    );
  }
}
