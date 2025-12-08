import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/landmark_provider.dart';
import '../models/landmark_model.dart';
import '../widgets/landmark_bottom_sheet.dart';
import '../widgets/loading_indicator.dart';
import '../utils/constants.dart';
import '../config/app_theme.dart';
import 'form_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarkers();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _loadMarkers() {
    final provider = context.read<LandmarkProvider>();
    _updateMarkers(provider.landmarks);
  }

  void _updateMarkers(List<Landmark> landmarks) {
    final markers = <Marker>{};

    for (var landmark in landmarks) {
      if (landmark.id != null) {
        markers.add(
          Marker(
            markerId: MarkerId(landmark.id.toString()),
            position: LatLng(landmark.lat, landmark.lon),
            infoWindow: InfoWindow(
              title: landmark.title.isEmpty ? 'Untitled' : landmark.title,
              snippet: 'Tap for options',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            onTap: () {
              _showLandmarkBottomSheet(landmark);
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _showLandmarkBottomSheet(Landmark landmark) {
    LandmarkBottomSheet.show(
      context,
      landmark: landmark,
      onEdit: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormScreen(landmark: landmark),
          ),
        );
      },
      onDelete: () {
        _confirmDelete(landmark);
      },
    );
  }

  void _confirmDelete(Landmark landmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Landmark'),
        content: Text(
          'Are you sure you want to delete "${landmark.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (landmark.id != null) {
                final provider = context.read<LandmarkProvider>();
                final success = await provider.deleteLandmark(landmark.id!);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Landmark deleted successfully'
                          : 'Failed to delete landmark'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );

                  if (success) {
                    _loadMarkers();
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final provider = context.read<LandmarkProvider>();
    final location = await provider.getCurrentLocation();

    if (location != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location['lat']!, location['lon']!),
            zoom: 14,
          ),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Moved to your location'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() => _isLoadingLocation = false);
  }

  void _goToBangladesh() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: LatLng(
            AppConstants.bangladeshLat,
            AppConstants.bangladeshLon,
          ),
          zoom: AppConstants.defaultZoom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoadingLocation ? null : _goToCurrentLocation,
            tooltip: 'Go to my location',
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _goToBangladesh,
            tooltip: 'Center on Bangladesh',
          ),
        ],
      ),
      body: Consumer<LandmarkProvider>(
        builder: (context, provider, child) {
          // Update markers when landmarks change
          if (_markers.length != provider.landmarks.length) {
            _updateMarkers(provider.landmarks);
          }

          if (provider.isLoading && provider.landmarks.isEmpty) {
            return const LoadingIndicator(message: 'Loading map...');
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    AppConstants.bangladeshLat,
                    AppConstants.bangladeshLon,
                  ),
                  zoom: AppConstants.defaultZoom,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                compassEnabled: true,
                mapType: MapType.normal,
              ),

              // Offline indicator
              if (provider.isOfflineMode)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.wifi_off, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline Mode - Showing cached data',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading indicator
              if (_isLoadingLocation)
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Getting location...'),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}