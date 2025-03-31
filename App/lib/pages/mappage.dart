import 'dart:convert'; // JSON 디코딩을 위한 패키지
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {}; // 마커 목록
  TextEditingController _searchController = TextEditingController(); // 검색 입력 컨트롤러

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.8868, 127.7376), // 한림대학교
    zoom: 15,
  );

  // Google Places API Key
  final String _apiKey = dotenv.env['API_KEY_IOS'] ?? ''; // .env 파일에서 API 키 읽기
  final List<String> _categories = ['춘천시 교통', '데이트', '당일치기', '전시회'];

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  // Places API를 호출하여 장소 검색
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      return;
    }

    final String url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=37.8868,127.7376&radius=500&key=$_apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _markers.clear(); // 기존 마커 초기화
        for (var result in data['results']) {
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];
          final name = result['name'];
          final address = result['formatted_address'];

          _markers.add(
            Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name, snippet: address),
            ),
          );
        }
      });
    } else {
      throw Exception('Failed to load places');
    }
  }


  // Google Places API로 장소 정보 가져오기
  Future<void> _fetchPlaces() async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=37.8868,127.7376&radius=500&type=restaurant&key=$_apiKey"; // 예시로 한림대 주변 500m 내 음식점 데이터 요청

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // 데이터를 바탕으로 마커 추가
      for (var result in data["results"]) {
        final lat = result["geometry"]["location"]["lat"];
        final lng = result["geometry"]["location"]["lng"];
        final name = result["name"];
        final address = result["vicinity"];

        _markers.add(
          Marker(
            markerId: MarkerId(name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name, snippet: address),
            onTap: () {
              _showInfoCard(name, address); // 마커를 탭하면 카드 UI 변경
            },
          ),
        );
      }
      setState(() {}); // UI 업데이트
    } else {
      throw Exception('Failed to load places');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// 지도 뷰
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers, // 마커 표시
              zoomControlsEnabled: false, // 기본 줌 컨트롤 숨김
            ),

            /// 상단 UI
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // 검색창
                  SearchBar(),
                  const SizedBox(height: 12),
                  // 카테고리 필터 버튼들
                  CategoryButton(),
                ],
              ),
            ),

            /// 하단 카드 추천 리스트
            recommendCard(),

            /// 내 위치 및 확대/축소 버튼
            mybuttons(),
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
          // 확대 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5), // 위치 조정
                ),
              ],
            ),
            child: FloatingActionButton(
                heroTag: 'zoom-in', // 👈 고유한 값!
              onPressed: () {
                _mapController.animateCamera(CameraUpdate.zoomIn());
              },
              child: const Icon(Icons.add, color: Colors.black, size: 30),
              backgroundColor: Colors.white,
              elevation: 0, // 그림자 제거
            ),
          ),
          const SizedBox(height: 12),

          // 축소 버튼
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5), // 위치 조정
                ),
              ],
            ),
            child: FloatingActionButton(
                heroTag: 'zoom-out',

              onPressed: () {
                _mapController.animateCamera(CameraUpdate.zoomOut());
              },
              child: const Icon(Icons.remove, color: Colors.black, size: 30),
              backgroundColor: Colors.white,
              elevation: 0, // 그림자 제거
            ),
          ),
          const SizedBox(height: 12),

          // 내 위치 버튼 (기본 제공)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5), // 위치 조정
                ),
              ],
            ),
            child: FloatingActionButton(
                heroTag: 'my-location',

              onPressed: () {
                _mapController.moveCamera(
                  CameraUpdate.newLatLngZoom(LatLng(37.8868, 127.7376), 15),
                );
              },
              child: const Icon(
                Icons.my_location,
                color: Colors.black,
                size: 30,
              ),
              backgroundColor: Colors.white,
              elevation: 0, // 그림자 제거
            ),
          ),
        ],
      ),
    );
  }

  Positioned recommendCard() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 160,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "AI 추천 코스",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text("지도\n추천 ${1}번", textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
        itemBuilder: (context, index) {
          return Chip(
            label: Text(_categories[index]),
            backgroundColor: Colors.green.shade100,
          );
        },
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
                    onChanged: (query) {
                      _searchPlaces(query); // 입력할 때마다 검색 실행
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


  void _showInfoCard(String name, String description) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(description),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 시 추가 기능 구현 가능
                  Navigator.pop(context);
                },
                child: Text("더 알아보기"),
              ),
            ],
          ),
        );
      },
    );
  }
}
