import 'package:app/models/business.dart';
import 'package:app/services/location_service.dart';
import 'package:app/services/marker_service.dart';
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
    _markerService.debugPrintMarkers();

    final position = await _locationService.getCurrentLocation();
    _initialPosition = position;

    if (mounted) {
      setState(() {});
    }

    _moveToLocation(position);
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

  void _onMarkerTap(String name, String address, business_data? store) {
    widget.onMarkerTap(name, address, store);
  }

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
                GoogleMap(
                  key: const ValueKey('GoogleMap'), // 중복 생성 방지
                  onMapCreated: (controller) {
                    if (_mapController == null) {
                      _mapController = controller;
                    }
                  },
                  onCameraMove: (_) {
                    if (!_mapMoved) {
                      setState(() => _mapMoved = true);
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _initialPosition?.latitude ?? 0.0,
                      _initialPosition?.longitude ?? 0.0,
                    ),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  markers: _markerService.markers,
                  zoomControlsEnabled: false,
                ),
                _zoomButtons(),
                if (_mapMoved) _recenterButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recenterButton() => Positioned(
        bottom: 30,
        left: 0,
        right: 0,
        child: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_searching, size: 20),
            label: const Text('현재 위치로 이동', style: TextStyle(fontSize: 14)),
            onPressed: () async {
              if (_mapController != null) {
                final position = await _locationService.getCameraCenterPosition(
                  _mapController!,
                  context,
                );
                _moveToLocation(position);
                setState(() => _mapMoved = false);
              }
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
