import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String apiKey = "AIzaSyDInW_AkHCMhKsF6OcavbZMHOvZI6oaREM";

  /// 🔍 Autocomplete (OLX style)
  static Future<List<String>> searchCities(String query, String state) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$query"
        "&types=(cities)"
        "&components=country:in"
        "&key=$apiKey";

    final res = await http.get(Uri.parse(url));

    final data = jsonDecode(res.body);

    return (data['predictions'] as List)
        .map((e) => e['description'].toString())
        .toList();
  }
}
