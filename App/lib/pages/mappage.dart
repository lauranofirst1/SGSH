import 'package:app/models/business.dart';
import 'package:app/services/location_service.dart';
import 'package:app/services/marker_service.dart';
import 'package:app/widgets/storedetailbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';

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
  final TextEditingController _searchController = TextEditingController();

  bool _mapMoved = false;
  Position? _initialPosition;
  PersistentBottomSheetController? _activeBottomSheet;

  List<business_data> _cachedRecommendedStores = [];
  bool _hasClosedRecommendation = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _cachedRecommendedStores = await _markerService.getTopBusinessesByHits(3);
      if (_cachedRecommendedStores.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _activeBottomSheet = _scaffoldKey.currentState?.showBottomSheet(
            (context) => StoreDetailBottomSheet(
              name: '추천 맛집',
              address: '근처',
              store: null,
              recommendedStores: _cachedRecommendedStores,
            ),
            backgroundColor: Colors.transparent,
          );

          _activeBottomSheet?.closed.then((_) {
            if (mounted) {
              setState(() => _hasClosedRecommendation = true);
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
    _searchController.dispose();
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
      onTap: (_) => _activeBottomSheet?.close(),
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

  Future<void> _onMarkerTap(
    String name,
    String address,
    business_data? store,
  ) async {
    _activeBottomSheet?.close();

    if (store != null) {
      _activeBottomSheet = _scaffoldKey.currentState!.showBottomSheet(
        (context) => StoreDetailBottomSheet(
          name: name,
          address: address,
          store: store,
        ),
        backgroundColor: Colors.transparent,
      );
    } else {
      final top3 = await _markerService.getTopBusinessesByHits(3);
      _activeBottomSheet = _scaffoldKey.currentState!.showBottomSheet(
        (context) => StoreDetailBottomSheet(
          name: '추천 맛집',
          address: '근처',
          recommendedStores: top3,
        ),
        backgroundColor: Colors.transparent,
      );
    }
  }

  Widget _zoomButtons() => Positioned(
        bottom: 160,
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

  Widget _searchBar() => Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: '가게 이름 검색',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (query) => _searchAndMove(query),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _searchController.clear(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  _tagChip('가치가게의 추천'),
                  _tagChip('육면'),
                  _tagChip('카페'),
                  _tagChip('한식'),
                  _tagChip('분식'),
                  _tagChip('디저트'),
                  _tagChip('중식'),
                  _tagChip('고기'),
                  _tagChip('샐러드'),
                  _tagChip('베이커리'),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _tagChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () {
          if (label == '가치가게의 추천') {
            _showRecommendationSheet();
          } else {
            _searchController.text = label;
            _searchAndMove(label);
          }
        },
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label == '가치가게의 추천') ...[
                const Icon(Icons.place, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
              ],
              Text('#$label'),
            ],
          ),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: label == '가치가게의 추천' ? Colors.orange : Colors.black12,
          ),
          labelStyle: const TextStyle(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _searchAndMove(String name) {
    final matched = _markerService.savedBusinessList.firstWhereOrNull(
      (b) => b.name.toLowerCase().contains(name.toLowerCase()),
    );

    if (matched != null && matched.latDouble != null && matched.lngDouble != null) {
      final latLng = LatLng(matched.latDouble!, matched.lngDouble!);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 17));
      _onMarkerTap(matched.name, matched.address, matched);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('검색 결과가 없습니다')),
      );
    }
  }

  Future<void> _showRecommendationSheet() async {
    if (_cachedRecommendedStores.isEmpty) {
      _cachedRecommendedStores = await _markerService.getTopBusinessesByHits(3);
    }

    if (_cachedRecommendedStores.isNotEmpty) {
      _activeBottomSheet = _scaffoldKey.currentState?.showBottomSheet(
        (context) => StoreDetailBottomSheet(
          name: '추천 맛집',
          address: '근처',
          store: null,
          recommendedStores: _cachedRecommendedStores,
        ),
        backgroundColor: Colors.transparent,
      );

      _activeBottomSheet?.closed.then((_) {
        if (mounted) {
          setState(() => _hasClosedRecommendation = true);
        }
      });
    }
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
                mapview(),
                _zoomButtons(),
                _searchBar(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}