import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/consultation_pass_model.dart';
import '../../utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FacilityMapScreen extends StatefulWidget {
  final ConsultationPassModel pass;

  const FacilityMapScreen({super.key, required this.pass});

  @override
  State<FacilityMapScreen> createState() => _FacilityMapScreenState();
}

class _FacilityMapScreenState extends State<FacilityMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _createMarkers();
    setState(() {
      _isLoadingLocation = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _createMarkers() {
    _markers = {
      // Facility marker
      Marker(
        markerId: const MarkerId('facility'),
        position: LatLng(
          widget.pass.facilityLatitude!,
          widget.pass.facilityLongitude!,
        ),
        infoWindow: InfoWindow(
          title: widget.pass.facilityName ?? 'Établissement',
          snippet: widget.pass.facilityAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      // Current location marker (if available)
      if (_currentPosition != null)
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Votre position'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
    };

    // Draw line between current position and facility
    if (_currentPosition != null) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            LatLng(
              widget.pass.facilityLatitude!,
              widget.pass.facilityLongitude!,
            ),
          ],
          color: AppColors.primary,
          width: 3,
        ),
      };
    }
  }

  Future<void> _launchGoogleMaps() async {
    final lat = widget.pass.facilityLatitude;
    final lng = widget.pass.facilityLongitude;

    // Try Google Maps app first, fallback to browser
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir Google Maps'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  double? _calculateDistance() {
    if (_currentPosition == null) return null;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.pass.facilityLatitude!,
      widget.pass.facilityLongitude!,
    ) / 1000; // Convert to kilometers
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Localisation'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final facilityLocation = LatLng(
      widget.pass.facilityLatitude!,
      widget.pass.facilityLongitude!,
    );

    final distance = _calculateDistance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation de l\'Établissement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: facilityLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;

              // Adjust camera to show both markers if current location available
              if (_currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        _currentPosition!.latitude < facilityLocation.latitude
                            ? _currentPosition!.latitude
                            : facilityLocation.latitude,
                        _currentPosition!.longitude < facilityLocation.longitude
                            ? _currentPosition!.longitude
                            : facilityLocation.longitude,
                      ),
                      northeast: LatLng(
                        _currentPosition!.latitude > facilityLocation.latitude
                            ? _currentPosition!.latitude
                            : facilityLocation.latitude,
                        _currentPosition!.longitude > facilityLocation.longitude
                            ? _currentPosition!.longitude
                            : facilityLocation.longitude,
                      ),
                    ),
                    100, // Padding
                  ),
                );
              }
            },
          ),

          // Bottom info card
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.pass.facilityName ?? 'Établissement',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.pass.facilityAddress != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.pass.facilityAddress!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (distance != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Distance : ${distance.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _launchGoogleMaps,
                        icon: const Icon(Icons.navigation),
                        label: const Text('Lancer la navigation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}