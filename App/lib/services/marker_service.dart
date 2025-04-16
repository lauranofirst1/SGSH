import 'package:app/models/business.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarkerService {
  final Set<Marker> markers = {};
  List<Map<String, dynamic>> _savedBusinesses = [];

  /// Supabase에서 DB에 저장된 모든 가게 불러오기
  Future<void> loadSavedBusinesses() async {
    final supabase = Supabase.instance.client;
    _savedBusinesses = await supabase.from('business_data').select('*');

     print('🧪 불러온 데이터 개수: ${_savedBusinesses.length}');
  for (final biz in _savedBusinesses) {
    print('📦 가게: ${biz['name']}, 위치: ${biz['lat']}, ${biz['lng']}');
  }
  }

  /// 외부 검색 결과 기반으로 마커 생성
  void buildMarkers(
    List results,
    void Function(String, String, business_data?) onMarkerTap,
  ) {
    markers.clear(); // 기존 마커 초기화

    for (var result in results) {
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      final name = result['name'];
      final address = result['vicinity'] ?? result['formatted_address'];
      final matchedBiz = getMatchedBusiness(lat, lng);

      markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name, snippet: address),
          icon: matchedBiz != null
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
              : BitmapDescriptor.defaultMarker,
          onTap: () => onMarkerTap(
            name,
            address,
            matchedBiz != null ? business_data.fromMap(matchedBiz) : null,
          ),
        ),
      );
    }
  }

  /// DB에 저장된 가게들 중 lat/lng로 일치 여부 판단
  Map<String, dynamic>? getMatchedBusiness(double lat, double lng) {
    const tolerance = 0.0001;

    for (var biz in _savedBusinesses) {
      if (biz['lat'] == null || biz['lng'] == null ||
          biz['lat'].toString().isEmpty || biz['lng'].toString().isEmpty) {
        continue;
      }

      final savedLat = double.tryParse(biz['lat'].toString());
      final savedLng = double.tryParse(biz['lng'].toString());

      if (savedLat == null || savedLng == null) continue;

      if ((lat - savedLat).abs() < tolerance &&
          (lng - savedLng).abs() < tolerance) {
        return biz;
      }
    }
    return null;
  }

  /// DB에서 가져온 savedBusinesses 데이터로 마커 찍기
  void buildSavedBusinessMarkers(
    void Function(String, String, business_data?) onMarkerTap,
  ) {
    for (var biz in _savedBusinesses) {
      if (biz['lat'] == null || biz['lng'] == null ||
          biz['lat'].toString().isEmpty || biz['lng'].toString().isEmpty) {
        continue;
      }

      final lat = double.tryParse(biz['lat'].toString());
      final lng = double.tryParse(biz['lng'].toString());
      if (lat == null || lng == null) continue;

      final name = biz['name'] ?? '이름 없음';
      final address = biz['address'] ?? '주소 없음';

      markers.add(
        Marker(
          markerId: MarkerId('saved-$name'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name, snippet: address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () => onMarkerTap(
            name,
            address,
            business_data.fromMap(biz),
          ),
        ),
      );
    }
  }

  /// 마커 디버깅용 출력
  void debugPrintMarkers() {
    print('📌 마커 총 개수: ${markers.length}');
    for (final marker in markers) {
      print('🟠 ${marker.markerId}: ${marker.position}');
    }
  }
}
