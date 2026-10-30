import 'package:http/http.dart' as http;
import 'base_service.dart';

class HomeService extends BaseService {
  Future<http.Response> fetchHomeData() async {
    final url = Uri.parse('${BaseService.baseUrl}/home');
    return await http.get(url, headers: await getHeaders());
  }
}
