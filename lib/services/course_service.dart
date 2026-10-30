import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_service.dart';

class CourseService extends BaseService {
  Future<http.Response> fetchRecentCourses({int page = 1}) async {
    final url = Uri.parse('${BaseService.baseUrl}/courses/recent?page=$page');
    return await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchCourseDetail(int id) async {
    final url = Uri.parse('${BaseService.baseUrl}/courses/$id');
    return await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchCourses({
    int page = 1,
    String? search,
    List<int>? categoryIds,
    double? minPrice,
    double? maxPrice,
    int? minDuration,
    int? maxDuration,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page.toString()};

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryIds != null && categoryIds.isNotEmpty) {
      queryParams['categories'] = categoryIds.join(',');
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }
    if (minDuration != null) {
      queryParams['min_duration'] = minDuration.toString();
    }
    if (maxDuration != null) {
      queryParams['max_duration'] = maxDuration.toString();
    }

    final uri = Uri.parse(
      '${BaseService.baseUrl}/courses',
    ).replace(queryParameters: queryParams);

    return await http
        .get(uri, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchCategories() async {
    final url = Uri.parse('${BaseService.baseUrl}/categories');
    return await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> enrollCourse(
    int courseId,
    String paymentMethod, {
    String? transactionId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/courses/$courseId/enroll');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'payment_method': paymentMethod,
            'transaction_id': transactionId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.StreamedResponse> enrollCourseOffline({
    required int courseId,
    required String transactionId,
    required String receiptPath,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/courses/$courseId/enroll');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll(await getHeaders());
    request.fields['payment_method'] = 'offline';
    request.fields['transaction_id'] = transactionId;

    request.files.add(
      await http.MultipartFile.fromPath('receipt_file', receiptPath),
    );

    return await request.send().timeout(const Duration(seconds: 60));
  }

  Future<http.Response> enrollBundle(
    int bundleId,
    String paymentMethod, {
    String? transactionId,
    bool confirmDuplicate = false,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/bundles/$bundleId/checkout');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'payment_method': paymentMethod,
            'transaction_id': transactionId,
            'confirm_duplicate': confirmDuplicate,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.StreamedResponse> enrollBundleOffline({
    required int bundleId,
    required String transactionId,
    required String receiptPath,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/bundles/$bundleId/checkout');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll(await getHeaders());
    request.fields['payment_method'] = 'offline';
    request.fields['transaction_id'] = transactionId;

    request.files.add(
      await http.MultipartFile.fromPath('receipt_file', receiptPath),
    );

    return await request.send().timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchBundles() async {
    final url = Uri.parse('${BaseService.baseUrl}/bundles');
    return await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchBundlesPage({int page = 1, String search = ''}) async {
    final params = <String, String>{'page': '$page'};
    if (search.isNotEmpty) params['search'] = search;
    final url = Uri.parse('${BaseService.baseUrl}/bundles').replace(queryParameters: params);
    return await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchBundleDetail(int bundleId) async {
    final url = Uri.parse('${BaseService.baseUrl}/bundles/$bundleId');
    return await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> fetchMyCourses({String? status, int page = 1}) async {
    final Map<String, dynamic> queryParams = {'page': page.toString()};
    if (status != null) {
      queryParams['status'] = status;
    }
    final uri = Uri.parse(
      '${BaseService.baseUrl}/user/courses',
    ).replace(queryParameters: queryParams);

    return await http
        .get(uri, headers: await getHeaders())
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/razorpay/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'razorpay_order_id': orderId,
            'razorpay_payment_id': paymentId,
            'razorpay_signature': signature,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifySslCommerzPayment({
    required String tranId,
    required String valId,
    required String amount,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/sslcommerz/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'tran_id': tranId,
            'val_id': valId,
            'amount': amount,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifyStripePayment({
    required String paymentIntentId,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/stripe/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'payment_intent_id': paymentIntentId,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifyPaystackPayment({
    required String reference,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/paystack/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'reference': reference,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifyMolliePayment({
    required String paymentId,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/mollie/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'payment_id': paymentId,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifyPaypalPayment({
    required String orderId,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/paypal/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'order_id': orderId,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }

  Future<http.Response> verifyBkashPayment({
    required String paymentId,
    required int enrollmentId,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/payments/bkash/verify');
    return await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode({
            'payment_id': paymentId,
            'enrollment_id': enrollmentId,
          }),
        )
        .timeout(const Duration(seconds: 60));
  }
}
