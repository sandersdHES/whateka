import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ContextService {
  /// Get the current position.
  /// Request permission if needed.
  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Fetch weather data from Open-Meteo API
  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        return {
          'temperature': current['temperature_2m'],
          'weather_code': current['weather_code'],
          // Optional: Add mapping for weather codes to human readable string if needed by AI,
          // but AI likely understands WMO codes.
        };
      } else {
        return {'error': 'Failed to fetch weather'};
      }
    } catch (e) {
      return {'error': 'Exception fetching weather'};
    }
  }

  /// Get the full context (location, weather, date)
  Future<Map<String, dynamic>> getFullContext() async {
    final position = await determinePosition();
    Map<String, dynamic> weather = {};

    if (position != null) {
      weather = await getWeather(position.latitude, position.longitude);
    }

    return {
      'location': position != null
          ? {
              'latitude': position.latitude,
              'longitude': position.longitude,
            }
          : null,
      'weather': weather,
      'dateTime': DateTime.now().toIso8601String(),
    };
  }
}
