import 'package:app/models/business.dart';
import 'package:app/services/location_service.dart';
import 'package:app/services/marker_service.dart';
import 'package:app/services/places_service.dart';
import 'package:app/widgets/search_bar.dart' as custom;
import 'package:app/widgets/category_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  final void Function(String name, String address, business_data? store) onMarkerTap;

  const MapPage({super.key, required this.onMarkerTap});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final MarkerService _markerService = MarkerService();
  final PlacesService _placesService = PlacesService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _mapMoved = false;
  Position? _initialPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    await _markerService.loadSavedBusinesses();
    final position = await _locationService.getCurrentLocation();
    _initialPosition = position;
    setState(() {}); // 위치 초기화 후 빌드
    _moveToLocation(position);
    await _fetchPlaces(position);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
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
    widget.onMarkerTap(name, address, store);
  }

  Future<void> _search(String keyword) async {
    final position = await _locationService.getCurrentLocation();
    await _fetchPlaces(position, keyword: keyword);
  }

  Future<void> _searchThisLocation() async {
    if (_mapController == null) {
      print('맵 컨트롤러 없음');
      return;
    }
    final position = await _locationService.getCameraCenterPosition(
      _mapController!,
      context,
    );

    await _fetchPlaces(position, keyword: _searchController.text.trim());

    setState(() {
      _mapMoved = false;
      print('버튼 숨김 완료');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              onCameraMove: (_) {
                if (!_mapMoved) {
                  setState(() => _mapMoved = true);
                }
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(_initialPosition!.latitude, _initialPosition!.longitude),
                zoom: 15,
              ),
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
            if (_mapMoved) _currentLocationSearchButton(),
          ],
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
            onPressed: () async {
              print('버튼 눌림!');
              await _searchThisLocation();
            },
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
