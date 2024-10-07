import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesApi {
  final String apiKey;

  GooglePlacesApi(this.apiKey);

  Future<List<String>> fetchSuggestions(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      List<String> suggestions = [];
      for (var prediction in result['predictions']) {
        suggestions.add(prediction['description']);
      }
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}
