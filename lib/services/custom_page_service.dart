import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/custom_page.dart';

class CustomPageService extends BaseService {
  Future<List<CustomPage>> getPages() async {
    final url = Uri.parse('${BaseService.baseUrl}/settings/pages');
    final headers = await getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CustomPage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pages');
      }
    } catch (e) {
      throw Exception('Error loading pages: $e');
    }
  }

  Future<CustomPage> getPageDetails(String slug) async {
    final url = Uri.parse('${BaseService.baseUrl}/settings/pages/$slug');
    final headers = await getHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return CustomPage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load page details');
      }
    } catch (e) {
      throw Exception('Error loading page details: $e');
    }
  }
}
