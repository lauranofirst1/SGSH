class reserve_data {
  final int bId;
  final String? date;
  final String? time;
  final int? count;
  final String? rTime; // ✅ 문자열로 유지
  final String? status;
  final String uuid;
  final String? comment;

  reserve_data({
    required this.bId,
    this.date,
    this.time,
    this.count,
    required this.rTime,
    this.status,
    required this.uuid,
    this.comment,
  });

  factory reserve_data.fromJson(Map<String, dynamic> json) {
    return reserve_data(
      bId: json['b_id'] ?? 0,
      date: json['date'] as String?,
      time: json['time'] as String?,
      count: json['count'] != null
          ? int.tryParse(json['count'].toString())
          : null,
      rTime: json['r_time'] as String?, // ✅ 그냥 string으로 받아
      status: json['status'] as String?,
      uuid: json['uuid'] ?? '',
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'b_id': bId,
      'date': date,
      'time': time,
      'count': count,
      'r_time': rTime, // ✅ 문자열 그대로 보냄
      'status': status,
      'uuid': uuid,
      'comment': comment,
    };
  }
}
