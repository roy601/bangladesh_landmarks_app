import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_theme.dart';
import '../utils/constants.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;

  const MapPickerScreen({
    Key? key,
    this.initialLat,
    this.initialLon,
  }) : super(key: key);

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLon != null) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLon!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              tooltip: 'Confirm Location',
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ??
                  const LatLng(
                    AppConstants.bangladeshLat,
                    AppConstants.bangladeshLon,
                  ),
              initialZoom: _selectedLocation != null ? 12 : AppConstants.defaultZoom,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.bangladesh_landmarks_app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Instructions banner
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.touch_app, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap anywhere on the map to select location',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected coordinates display
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Latitude: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Longitude: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, _selectedLocation);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Use This Location'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}