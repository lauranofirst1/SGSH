// ✅ MapPage 리팩토링: 독립적으로 바텀시트 포함 & 외부 onMarkerTap 제거
import 'package:app/models/business.dart';
import 'package:app/services/location_service.dart';
import 'package:app/services/marker_service.dart';
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
  final LocationService _locationService = LocationService();
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
    _markerService.buildSavedBusinessMarkers(_onMarkerTap);

    final position = await _locationService.getCurrentLocation();
    _initialPosition = position;

    if (mounted) setState(() {});

    _moveToLocation(position);

    // 추천 가게 2개 바텀시트로 띄우기
    final recommendations = _markerService.getRecommendations(limit: 2);
    if (recommendations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState?.showBottomSheet(
          (context) => _buildRecommendationSheet(recommendations),
          backgroundColor: Colors.transparent,
        );
      });
    }
  }

  Widget _buildRecommendationSheet(List<business_data> list) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list
            .map((store) => ListTile(
                  title: Text(store.name ?? '이름 없음'),
                  subtitle: Text(store.address ?? '주소 없음'),
                  onTap: () => _onMarkerTap(store.name ?? '', store.address ?? '', store),
                ))
            .toList(),
      ),
    );
  }

  void _onMarkerTap(String name, String address, business_data? store) {
    final controller = _scaffoldKey.currentState!.showBottomSheet(
      (context) => StoreDetailBottomSheet(
        name: name,
        address: address,
        store: store,
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
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

  Future<void> _onCameraIdle() async {
    if (_mapController != null) {
      final bounds = await _mapController!.getVisibleRegion();
      _markerService.updateVisibleMarkers(bounds);
      setState(() {});
    }
  }

  GoogleMap mapview() {
    return GoogleMap(
      key: const ValueKey('GoogleMap'),
      onMapCreated: (controller) {
        if (_mapController == null) {
          _mapController = controller;
        }
      },
      onCameraMove: (_) {
        if (!_mapMoved) setState(() => _mapMoved = true);
      },
      onCameraIdle: _onCameraIdle,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _initialPosition?.latitude ?? 0.0,
          _initialPosition?.longitude ?? 0.0,
        ),
        zoom: 15,
      ),
      myLocationEnabled: true,
      markers: _markerService.visibleMarkers,
      zoomControlsEnabled: false,
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _initialPosition == null ? 0 : 1,
          children: [
            const Center(child: CircularProgressIndicator()),
            Stack(
              children: [
                mapview(),
                _zoomButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
