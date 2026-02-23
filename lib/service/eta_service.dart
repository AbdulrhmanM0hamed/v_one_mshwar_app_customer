import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ETAService {
  final String apiKey;
  final double destLat;
  final double destLng;
  final StreamController<String> _etaController = StreamController.broadcast();
  StreamSubscription<Position>? _positionSubscription;

  ETAService({
    required this.apiKey,
    required this.destLat,
    required this.destLng,
  });

  Stream<String> get etaStream => _etaController.stream;

  Future<void> startTracking() async {
    // Check permissions
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _etaController.add('Location permission denied');
      return;
    }

    // Start listening to position changes
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // every 10 meters
      ),
    ).listen((position) async {
      final eta = await _getETA(
        originLat: position.latitude,
        originLng: position.longitude,
      );
      _etaController.add(eta);
    });
  }

  Future<String> _getETA({
    required double originLat,
    required double originLng,
  }) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&key=$apiKey'
      '&mode=driving',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        return data['routes'][0]['legs'][0]['duration']['text'];
      }
    }
    return 'ETA unavailable';
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _etaController.close();
  }
}
