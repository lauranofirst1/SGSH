class ReservationViewModel {
  final int id;
  final int bId;
  final String storeName;
  final String storeImage;
  final String category;
  final String location;
  final String date; // ISO 문자열
  final String time;
  final int count;
  final String status;

  ReservationViewModel({
    required this.id,
    required this.bId,
    required this.storeName,
    required this.storeImage,
    required this.category,
    required this.location,
    required this.date,
    required this.time,
    required this.count,
    required this.status,
  });

  factory ReservationViewModel.fromReserveAndBusiness({
    required Map<String, dynamic> reserve,
    required Map<String, dynamic> business,
  }) {
    return ReservationViewModel(
      id: reserve['id'],
      bId: reserve['b_id'],
      storeName: business['name'] ?? '가게 이름',
      storeImage: business['image'] ?? 'https://example.com/default-image.png',
      category: business['category'] ?? '중식',
      location: business['location'] ?? '코엑스',
      date: reserve['date'] ?? '',
      time: reserve['time'] ?? '',
      count: reserve['count'] ?? 0,
      status: reserve['status'] ?? 'confirmed',
    );
  }

  int? get dDay {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return null;
    final now = DateTime.now();
    return parsed.difference(now).inDays;
  }
}
