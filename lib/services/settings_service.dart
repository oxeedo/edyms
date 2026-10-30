import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import '../models/platform_settings.dart';

class SettingsService extends BaseService {
  Future<PlatformSettings?> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${BaseService.baseUrl}/settings'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return PlatformSettings.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      return null;
    }
  }
}
