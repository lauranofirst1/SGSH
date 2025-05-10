// 🔧 MarkerService 개선 버전 (viewport 필터링 지원)
import 'package:app/models/business.dart';
import 'package:app/models/hit_data.dart';
import 'package:collection/collection.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarkerService {
  final Set<Marker> visibleMarkers = {}; // 지도에 실제로 표시될 마커
  final List<Map<String, dynamic>> _savedBusinesses = [];
  final Set<Marker> _allMarkers = {}; // 모든 마커 (필터링 전)

  List<business_data> get savedBusinessList =>
      _savedBusinesses.map((biz) => business_data.fromMap(biz)).toList();

  /// Supabase에서 DB에 저장된 모든 가게 불러오기
  Future<void> loadSavedBusinesses() async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('business_data').select('*');
    _savedBusinesses.clear();
    _savedBusinesses.addAll(data);

    print('🧪 불러온 데이터 개수: ${_savedBusinesses.length}');
  }

  /// DB에서 가져온 savedBusinesses 데이터로 마커 생성
  void buildSavedBusinessMarkers(
    void Function(String, String, business_data?) onMarkerTap,
  ) {
    _allMarkers.clear();

    for (var biz in _savedBusinesses) {
      final lat = double.tryParse(biz['lat'].toString());
      final lng = double.tryParse(biz['lng'].toString());
      if (lat == null || lng == null) continue;

      final name = biz['name'] ?? '이름 없음';
      final address = biz['address'] ?? '주소 없음';

      _allMarkers.add(
        Marker(
          markerId: MarkerId('saved-$name'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name, snippet: address),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          onTap: () => onMarkerTap(name, address, business_data.fromMap(biz)),
        ),
      );
    }
  }

  /// 지도 뷰포트 내 마커만 필터링
  void updateVisibleMarkers(LatLngBounds bounds) {
    visibleMarkers.clear();
    for (final marker in _allMarkers) {
      final pos = marker.position;
      if (_isInsideBounds(pos, bounds)) {
        visibleMarkers.add(marker);
      }
    }
  }

  bool _isInsideBounds(LatLng pos, LatLngBounds bounds) {
    return pos.latitude >= bounds.southwest.latitude &&
        pos.latitude <= bounds.northeast.latitude &&
        pos.longitude >= bounds.southwest.longitude &&
        pos.longitude <= bounds.northeast.longitude;
  }

  void debugPrintMarkers() {
    print('📌 전체 마커 수: ${_allMarkers.length}');
    print('📌 화면에 보이는 마커 수: ${visibleMarkers.length}');
  }

  List<business_data> getRecommendations({required int limit}) {
    return _savedBusinesses
        .where((biz) => biz['lat'] != null && biz['lng'] != null)
        .take(limit)
        .map((biz) => business_data.fromMap(biz))
        .toList();
  }

  Future<List<business_data>> getTopBusinessesByHits(int limit) async {
  final supabase = Supabase.instance.client;
  final hitResult = await supabase.from('business_hits').select('*');
  final List<HitData> hits = hitResult.map((e) => HitData.fromMap(e)).toList();

  // 🔁 1. bId 기준으로 조회수 합산
  final Map<int, int> hitCountMap = {};
  for (final hit in hits) {
    hitCountMap.update(hit.bId, (value) => value + hit.hits, ifAbsent: () => hit.hits);
  }

  // 🔢 2. 조회수 높은 순으로 bId 정렬
  final sortedBIds = hitCountMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final topBIds = sortedBIds.map((e) => e.key).take(limit).toList();

  // 🏪 3. bId로 business_data 매칭
  final List<business_data> topStores = [];
  for (final bId in topBIds) {
    final matched = _savedBusinesses.firstWhereOrNull((b) => b['id'] == bId);
    if (matched != null) {
      topStores.add(business_data.fromMap(matched));
    }
  }

  return topStores;
}

}
