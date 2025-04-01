import 'dart:convert';
import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  late List<Map<String, dynamic>> _savedBusinesses = [];
  Set<Marker> _markers = {};
  TextEditingController _searchController = TextEditingController();
  final String _apiKey = dotenv.env['SGSH_API_KEY'] ?? '';
  final List<String> _categories = ['춘천시 교통', '데이트', '당일치기', '전시회'];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSavedBusinesses();
    final position = await _getCurrentLocation();
    await _moveToLocation(position);
    await _fetchPlaces(position);
  }

  Future<void> _moveToLocation(Position position) async {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('위치 서비스 꺼져 있음');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한 거부됨');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _loadSavedBusinesses() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('business_data').select('*');
    setState(() {
      _savedBusinesses = response;
    });
  }

  Map<String, dynamic>? getMatchedBusiness(double lat, double lng) {
    const tolerance = 0.0001;
    print('찾으려는 위치: lat=$lat, lng=$lng');

    for (var biz in _savedBusinesses) {
      if (biz['lat'] == null ||
          biz['lng'] == null ||
          biz['lat'].toString().isEmpty ||
          biz['lng'].toString().isEmpty) {
        print('위치 정보 없음: $biz');
        continue;
      }

      final savedLat = double.parse(biz['lat'].toString());
      final savedLng = double.parse(biz['lng'].toString());

      final latDiff = (lat - savedLat).abs();
      final lngDiff = (lng - savedLng).abs();

      print(
        '비교중인 위치: bizLat=$savedLat, bizLng=$savedLng (lat차이=$latDiff, lng차이=$lngDiff)',
      );

      if (latDiff < tolerance && lngDiff < tolerance) {
        print('✅ 매칭된 비즈니스 발견: $biz');
        return biz;
      }
    }

    print('❌ 매칭된 비즈니스가 없습니다.');
    return null;
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;
    final position = await _getCurrentLocation();
    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&location=${position.latitude},${position.longitude}&radius=1000&key=$_apiKey";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _markers.clear();
        for (var result in data['results']) {
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];
          final name = result['name'];
          final address = result['formatted_address'];
          final matchedBiz = getMatchedBusiness(lat, lng);
          _markers.add(
            Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name, snippet: address),
              icon:
                  matchedBiz != null
                      ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      )
                      : BitmapDescriptor.defaultMarker,
              onTap: () => _onMarkerTap(name, address, matchedBiz),
            ),
          );
        }
      });
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<void> _fetchPlaces(Position position, {String keyword = ''}) async {
    final url =
        keyword.isEmpty
            ? "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=1000&type=restaurant&key=$_apiKey"
            : "https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(keyword)}&location=${position.latitude},${position.longitude}&radius=1000&key=$_apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _markers.clear();
        for (var result in data['results']) {
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];
          final name = result['name'];
          final address = result['vicinity'] ?? result['formatted_address'];
          final matchedBiz = getMatchedBusiness(lat, lng);

          _markers.add(
            Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name, snippet: address),
              icon:
                  matchedBiz != null
                      ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      )
                      : BitmapDescriptor.defaultMarker,
              onTap: () => _onMarkerTap(name, address, matchedBiz),
            ),
          );
        }
      });
    } else {
      throw Exception('Failed to load places');
    }
  }

  void _onMarkerTap(String name, String address, Map<String, dynamic>? biz) {
    if (biz != null) {
      try {
        final store = business_data.fromMap(biz);
        _showInfoCard(name, address, store: store);
      } catch (e) {
        print("fromMap 에러: $e");
      }
    } else {
      _showInfoCard(name, address);
    }
  }

  void _showInfoCard(String name, String description, {business_data? store}) {
    final displayStore =
        store ??
        business_data(
          id: -1,
          name: name,
          address: description,
          image: '',
          time: '정보 없음',
          lat: '',
          lng: '',
          number: '',
          description: '',
          url: '',
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: StoreCard(
                store: displayStore,
                onTap: () {
                  Navigator.pop(context);
                  if (store != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoreDetailPage(store: store),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.8868, 127.7376),
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              zoomControlsEnabled: false,
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  SearchBar(),
                  const SizedBox(height: 12),
                  CategoryButton(),
                ],
              ),
            ),
            mybuttons(),

            currentLocationSearchButton(), // <-- 추가된 부분
          ],
        ),
      ),
    );
  }

  Positioned mybuttons() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        children: [
          _zoomButton(
            Icons.add,
            () => _mapController.animateCamera(CameraUpdate.zoomIn()),
            'zoom-in',
          ),
          const SizedBox(height: 12),
          _zoomButton(
            Icons.remove,
            () => _mapController.animateCamera(CameraUpdate.zoomOut()),
            'zoom-out',
          ),
        ],
      ),
    );
  }

  Positioned currentLocationSearchButton() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 5,
            shadowColor: Colors.black.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          icon: const Icon(Icons.refresh, size: 20),
          label: const Text('이 위치에서 검색', style: TextStyle(fontSize: 14)),
          onPressed: () async {
            final center = await _mapController.getLatLng(
              ScreenCoordinate(
                x: MediaQuery.of(context).size.width ~/ 2,
                y: MediaQuery.of(context).size.height ~/ 2,
              ),
            );
            await _fetchPlaces(
              Position(
                latitude: center.latitude,
                longitude: center.longitude,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                altitudeAccuracy: 0,
                heading: 0,
                headingAccuracy: 0,
                speed: 0,
                speedAccuracy: 0,
              ),
              keyword: _searchController.text.trim(),
            );
          },
        ),
      ),
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed, String tag) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: tag,
        onPressed: onPressed,
        child: Icon(icon, color: Colors.black, size: 30),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  SizedBox CategoryButton() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder:
            (context, index) => Chip(
              label: Text(_categories[index]),
              backgroundColor: Colors.green.shade100,
            ),
      ),
    );
  }

  Row SearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '찾고 싶은 장소를 입력하세요.',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) async {
                      final position = await _getCurrentLocation();
                      await _fetchPlaces(
                        position,
                        keyword: _searchController.text.trim(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune, color: Colors.white),
        ),
      ],
    );
  }
}
