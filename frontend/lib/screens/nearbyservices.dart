import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/page_header.dart';

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  bool _isLoading = false;

  Future<void> _openNearbyPlaces(String placeType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable location in your device settings.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied. Please allow location access.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied. Please enable them in app settings.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Try multiple URL formats for better compatibility
      final urls = [
        // Google Maps app URL
        Uri.parse('geo:${position.latitude},${position.longitude}?q=$placeType'),
        // Google Maps web URL (fallback)
        Uri.parse(
          'https://www.google.com/maps/search/$placeType/@${position.latitude},${position.longitude},15z',
        ),
      ];

      bool launched = false;
      for (final url in urls) {
        if (await canLaunchUrl(url)) {
          launched = await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
          if (launched) break;
        }
      }

      if (!launched) {
        // If all else fails, try browser fallback
        final browserUrl = Uri.parse(
          'https://www.google.com/maps/search/$placeType+near+me/@${position.latitude},${position.longitude},14z',
        );
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening maps: $e');
      _showError('Could not open maps. Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Standardized Header
              const PageHeader(
                title: 'Nearby Services',
                subtitle: 'Find medical facilities near you',
                icon: Icons.location_on,
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20),

                        // Info message
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF20B2AA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF20B2AA).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF20B2AA),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'We\'ll use your location to show hospitals, clinics, and pharmacies near you',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5A6C7D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Service Cards using StandardCard widget
                        StandardCard(
                          icon: Icons.local_hospital,
                          title: 'Hospitals',
                          subtitle: 'Find nearby hospitals and emergency care',
                          onTap: () => _openNearbyPlaces('hospitals'),
                          iconColor: Color(0xFFE57373),
                          iconBackgroundColor: Color(0xFFE57373),
                        ),

                        SizedBox(height: 16),

                        StandardCard(
                          icon: Icons.medical_services,
                          title: 'Clinics',
                          subtitle: 'Locate clinics and medical centers',
                          onTap: () => _openNearbyPlaces('clinics'),
                          iconColor: Color(0xFF64B5F6),
                          iconBackgroundColor: Color(0xFF64B5F6),
                        ),

                        SizedBox(height: 16),

                        StandardCard(
                          icon: Icons.local_pharmacy,
                          title: 'Pharmacies',
                          subtitle: 'Find pharmacies and drug stores',
                          onTap: () => _openNearbyPlaces('pharmacies'),
                          iconColor: Color(0xFF20B2AA),
                          iconBackgroundColor: Color(0xFF20B2AA),
                        ),

                        SizedBox(height: 24),

                        // Additional Info
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.map,
                                color: Color(0xFF9CA8B4),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Maps will open in your browser or Google Maps app after you grant location permission.',
                                  style: TextStyle(
                                    color: Color(0xFF7B8794),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF20B2AA),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        color: Theme.of(context).cardTheme.color ?? Colors.white,
                        fontSize: 16,
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
