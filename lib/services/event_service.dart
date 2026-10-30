import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';

class EventService extends BaseService {
  Future<http.Response> fetchEvents({
    String filter = 'upcoming',
    int page = 1,
  }) async {
    final url = Uri.parse(
      '${BaseService.baseUrl}/events?filter=$filter&page=$page',
    );
    try {
      final response = await http.get(url, headers: await getHeaders());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> fetchEventDetails(int id) async {
    final url = Uri.parse('${BaseService.baseUrl}/events/$id');
    try {
      final response = await http.get(url, headers: await getHeaders());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> bookEvent({
    required int eventId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/events/$eventId/book');
    try {
      final response = await http.post(
        url,
        headers: await getHeaders(),
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> getMyBookings({int page = 1}) async {
    final url = Uri.parse('${BaseService.baseUrl}/user/bookings?page=$page');
    try {
      final response = await http.get(url, headers: await getHeaders());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> getBookingDetails(int id) async {
    final url = Uri.parse('${BaseService.baseUrl}/user/bookings/$id');
    try {
      final response = await http.get(url, headers: await getHeaders());
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
