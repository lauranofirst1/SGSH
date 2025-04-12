import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class PlacesService {
  final String _apiKey = dotenv.env['SGSH_API_KEY']!;

  Future<List> getPlaces(position, {String keyword = ''}) async {
    final url = keyword.isEmpty
        ? "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=1000&type=restaurant&key=$_apiKey"
        : "https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(keyword)}&location=${position.latitude},${position.longitude}&radius=1000&key=$_apiKey";

    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    }
    throw Exception('Failed to load places');
  }
}
