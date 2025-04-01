import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/services/location_service.dart';
import 'package:app/services/marker_service.dart';
import 'package:app/services/places_service.dart';
import 'package:app/widgets/store_card.dart';
import 'package:app/widgets/search_bar.dart' as custom;
import 'package:app/widgets/category_button.dart';
import 'package:app/widgets/storedetailbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final MarkerService _markerService = MarkerService();
  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    // 맵 컨트롤러를 정리합니다.
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _markerService.loadSavedBusinesses();
    final position = await _locationService.getCurrentLocation();
    _moveToLocation(position);
    await _fetchPlaces(position);
  }

  void _moveToLocation(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
  }

  Future<void> _fetchPlaces(Position position, {String keyword = ''}) async {
    final results = await _placesService.getPlaces(position, keyword: keyword);
    setState(() {
      _markerService.buildMarkers(results, _onMarkerTap);
    });
  }

  void _onMarkerTap(String name, String address, business_data? store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => StoreDetailBottomSheet(
            name: name,
            address: address,
            store: store,
          ),
    );
  }

  Future<void> _search(String keyword) async {
    final position = await _locationService.getCurrentLocation();
    await _fetchPlaces(position, keyword: keyword);
  }

  Future<void> _searchThisLocation() async {
    if (_mapController == null) return;

    // 현재 지도 중심 위치를 가져오기
    final position = await _locationService.getCameraCenterPosition(
      _mapController!,
      context,
    );

    // 해당 위치를 기준으로 장소를 검색
    await _fetchPlaces(position, keyword: _searchController.text.trim());

    // 지도 카메라를 검색된 위치로 이동
    _moveToLocation(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Position>(
          future: _locationService.getCurrentLocation(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return Center(child: Text('위치를 가져올 수 없습니다.'));
            }

            final position = snapshot.data!;

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  markers: _markerService.markers,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      custom.SearchBar(
                        controller: _searchController,
                        onSubmitted: _search,
                      ),
                      const SizedBox(height: 12),
                      const CategoryButton(),
                    ],
                  ),
                ),
                _zoomButtons(),
                _currentLocationSearchButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _currentLocationSearchButton() => Positioned(
    bottom: 30,
    left: 0,
    right: 0,
    child: Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text('이 위치에서 검색', style: TextStyle(fontSize: 14)),
        onPressed: _searchThisLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    ),
  );

  Widget _zoomButtons() => Positioned(
    bottom: 100,
    right: 16,
    child: Column(
      children: [
        _zoomButton(
          Icons.add,
          () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
          'zoom-in',
        ),
        const SizedBox(height: 12),
        _zoomButton(
          Icons.remove,
          () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
          'zoom-out',
        ),
      ],
    ),
  );

  Widget _zoomButton(IconData icon, VoidCallback onPressed, String tag) =>
      FloatingActionButton(
        heroTag: tag,
        onPressed: onPressed,
        backgroundColor: Colors.white,
        child: Icon(icon, color: Colors.black, size: 30),
      );
}
