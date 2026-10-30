import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/config.dart';
import '../models/payment.dart';
import 'auth_service.dart';

class PaymentService {
  Future<List<Payment>> getMyPayments({int page = 1}) async {
    final token = await AuthService().getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/user/payments?page=$page'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> paymentsData = data['data']['data'];
        return paymentsData.map((json) => Payment.fromJson(json)).toList();
      }
    }
    return [];
  }

  Future<String?> downloadReceipt(int paymentId, String fileName) async {
    final token = await AuthService().getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/user/payments/$paymentId/receipt'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      // debugPrint('Download error: $e');
      return null;
    }
  }
}
