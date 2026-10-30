import 'package:http/http.dart' as http;
import 'base_service.dart';

class DashboardService extends BaseService {
  Future<http.Response> fetchDashboardData() async {
    final url = Uri.parse('${BaseService.baseUrl}/dashboard');
    return await http.get(url, headers: await getHeaders());
  }
}
