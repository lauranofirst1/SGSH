class HitData {
  final int id;
  final int bId;
  final int hits;
  final String date;

  HitData({
    required this.id,
    required this.bId,
    required this.hits,
    required this.date,
  });

  factory HitData.fromMap(Map<String, dynamic> map) {
    return HitData(
      id: map['id'],
      bId: map['b_id'],
      hits: map['hits'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'b_id': bId,
      'hits': hits,
      'date': date,
    };
  }
}
