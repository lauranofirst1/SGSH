import 'package:app/models/business.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarkerService {
  final Set<Marker> markers = {};
  List<Map<String, dynamic>> _savedBusinesses = [];

  Future<void> loadSavedBusinesses() async {
    final supabase = Supabase.instance.client;
    _savedBusinesses = await supabase.from('business_data').select('*');
  }

  void buildMarkers(List results,
      void Function(String, String, business_data?) onMarkerTap) {
    markers.clear();
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

  Map<String, dynamic>? getMatchedBusiness(double lat, double lng) {
    const tolerance = 0.0001;
    for (var biz in _savedBusinesses) {
      if (biz['lat'] == null || biz['lng'] == null || biz['lat'].toString().isEmpty || biz['lng'].toString().isEmpty) {
        continue;
      }

      final savedLat = double.parse(biz['lat'].toString());
      final savedLng = double.parse(biz['lng'].toString());

      if ((lat - savedLat).abs() < tolerance && (lng - savedLng).abs() < tolerance) {
        return biz;
      }
    }
    return null;
  }
}
