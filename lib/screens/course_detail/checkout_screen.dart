import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../common/webview_screen.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'offline_payment_screen.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/course.dart';
import '../../services/course_service.dart';
import 'enrollment_success_screen.dart';
import '../auth/auth_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Course course;
  final bool isBundle;
  const CheckoutScreen({super.key, required this.course, this.isBundle = false});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Razorpay _razorpay;
  String? _selectedPaymentMethod;
  final TextEditingController _couponController = TextEditingController();
  int? _lastEnrollmentId;
  bool _isProcessing = false;
  bool _isVerifying = false;
  late double _originalPrice;
  late double _discount;
  late double _discountPercent;
  String? _molliePaymentId;
  bool _molliePending = false;
  String? _paystackReference;
  bool _paystackPending = false;
  String? _bkashPaymentId;
  bool _bkashPending = false;

  @override
  void initState() {
    super.initState();
    _originalPrice = widget.course.price ?? 0.0;
    _discount =
        _originalPrice - (widget.course.discountedPrice ?? _originalPrice);
    _discountPercent = _originalPrice > 0
        ? (_discount / _originalPrice) * 100
        : 0.0;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifyRazorpayPayment(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        enrollmentId: _lastEnrollmentId!,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      debugPrint('Verify Razorpay Response: ${verifyResponse.body}');
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        final List<Course> bundleCourses = _parseBundleCourses(data);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EnrollmentSuccessScreen(
                enrollmentId: data['enrollment_id'] ?? _lastEnrollmentId,
                course: widget.course,
                bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
                bundleTitle: data['bundle_title']?.toString(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Payment verification failed'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  // Removed _handlePaymentSuccess as it was a duplicate/incomplete method.

  Future<void> _processRazorpay(Map<String, dynamic> data) async {
    try {
      _lastEnrollmentId = data['enrollment_id'];

      final String key = data['key']?.toString() ?? '';
      final int amount = data['amount'] ?? 0;
      final String currency = data['currency']?.toString() ?? 'INR';
      final String orderId = data['order_id']?.toString() ?? '';
      final String name = data['name']?.toString() ?? 'Eduex';
      final String description = data['description']?.toString() ?? '';

      final prefillMap = data['prefill'] as Map<String, dynamic>? ?? {};
      final String prefillName = prefillMap['name']?.toString() ?? '';
      final String prefillEmail = prefillMap['email']?.toString() ?? '';
      final String prefillContact = prefillMap['contact']?.toString() ?? '';

      final options = {
        'key': key,
        'amount': amount,
        'currency': currency,
        'name': name,
        'order_id': orderId,
        'description': description,
        'prefill': {
          if (prefillName.isNotEmpty) 'name': prefillName,
          if (prefillEmail.isNotEmpty) 'email': prefillEmail,
          if (prefillContact.isNotEmpty) 'contact': prefillContact,
        },
        'timeout': 300, // 5 minutes
      };

      // Add a small delay to ensure loading dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 500));

      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error initializing payment: $e')));
    }
  }

  Future<void> _processSslCommerz(Map<String, dynamic> data) async {
    try {
      _lastEnrollmentId = data['enrollment_id'];

      final String storeId = data['store_id']?.toString() ?? '';
      final String storePassword = data['store_password']?.toString() ?? '';
      final String mode = data['mode']?.toString().toLowerCase() ?? 'sandbox';
      final bool isSandbox = mode == 'test' || mode == 'sandbox';

      final String tranId = data['tran_id']?.toString() ?? '';
      final double amount = (data['amount'] ?? 0).toDouble();

      SSLCommerzInitialization sslCommerzInitialization =
          SSLCommerzInitialization(
            currency: SSLCurrencyType.BDT,
            product_category: "Education",
            sdkType: isSandbox ? SSLCSdkType.TESTBOX : SSLCSdkType.LIVE,
            store_id: storeId,
            store_passwd: storePassword,
            total_amount: amount,
            tran_id: tranId,
          );

      Sslcommerz sslcz = Sslcommerz(initializer: sslCommerzInitialization);
      var result = await sslcz.payNow();

      if (result.status?.toLowerCase() == 'valid' ||
          result.status?.toLowerCase() == 'success') {
        _handleSslCommerzSuccess(result);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment ${result.status ?? 'Failed'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _processStripe(Map<String, dynamic> data) async {
    try {
      _lastEnrollmentId = data['enrollment_id'];
      final String clientSecret = data['client_secret'] ?? '';
      final String publishableKey = data['publishable_key'] ?? '';

      if (publishableKey.isNotEmpty) {
        Stripe.publishableKey = publishableKey;
        await Stripe.instance.applySettings();
      }

      if (!mounted) return;
      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'EduEx',
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      // If we reach here, payment was successful
      _handleStripeSuccess(data['payment_intent_id']);
    } catch (e) {
      if (e is StripeException) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _processPaystack(Map<String, dynamic> data) async {
    try {
      _lastEnrollmentId = data['enrollment_id'];
      final String accessCode = data['access_code'] ?? '';
      final String reference = data['reference'] ?? '';

      if (accessCode.isEmpty) {
        throw Exception('Invalid Paystack configuration');
      }

      final checkoutUrl = 'https://checkout.paystack.com/$accessCode';

      setState(() {
        _paystackReference = reference;
        _paystackPending = true;
      });

      // Open Paystack checkout in WebView (same pattern as Mollie/PayPal)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            url: checkoutUrl,
            title: 'Paystack Payment',
            shouldExit: (url) {
              return url.contains('/payment/paystack/callback') ||
                  url.contains('paystack.com/close');
            },
          ),
        ),
      );

      // On return from WebView, trigger verification
      if (_paystackPending &&
          _paystackReference != null &&
          _paystackReference!.isNotEmpty) {
        _paystackPending = false;
        _handlePaystackSuccess(_paystackReference!);
      } else if (_paystackPending) {
        // If no reference was provided, use the access code as reference
        _paystackPending = false;
        _handlePaystackSuccess(accessCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _processPaypal(Map<String, dynamic> data) async {
    final orderId = data['order_id'];
    final enrollmentId = data['enrollment_id'];
    final approveUrl = data['approve_url'];

    if (orderId == null || enrollmentId == null || approveUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid PayPal data')));
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: approveUrl,
          title: 'Paypal Payment',
          shouldExit: (url) {
            return url.contains('/payment/paypal/callback');
          },
        ),
      ),
    );

    if (result != null && result is String) {
      if (!mounted) return;
      if (result.contains('success=true') || result.contains('token=')) {
        _handlePaypalSuccess(orderId, enrollmentId);
      } else if (result.contains('success=false')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment Cancelled')));
      }
    }
  }

  void _handlePaypalSuccess(String orderId, int enrollmentId) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifyPaypalPayment(
        orderId: orderId,
        enrollmentId: enrollmentId,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      debugPrint('Verify Paypal Response: ${verifyResponse.body}');
      if (!mounted) return;
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        final List<Course> bundleCourses = _parseBundleCourses(data);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnrollmentSuccessScreen(
              enrollmentId: data['enrollment_id'] ?? enrollmentId,
              course: widget.course,
              bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
              bundleTitle: data['bundle_title']?.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment verification failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _processMollie(Map<String, dynamic> data) async {
    try {
      _lastEnrollmentId = data['enrollment_id'];
      final String checkoutUrl = data['checkout_url'] ?? '';
      final String paymentId = data['payment_id'] ?? '';

      if (checkoutUrl.isEmpty || paymentId.isEmpty) {
        throw Exception('Invalid Mollie configuration');
      }

      setState(() {
        _molliePaymentId = paymentId;
        _molliePending = true;
      });

      // Open in in-app WebView
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            url: checkoutUrl,
            title: 'Mollie Payment',
            shouldExit: (url) {
              // Exit if we hit the callback URL
              return url.contains('/payment/mollie/callback');
            },
          ),
        ),
      );

      // On return from WebView, check if still pending and trigger verification
      if (_molliePending && _molliePaymentId != null) {
        _molliePending = false;
        _handleMollieSuccess(_molliePaymentId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleStripeSuccess(String paymentIntentId) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifyStripePayment(
        paymentIntentId: paymentIntentId,
        enrollmentId: _lastEnrollmentId!,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      debugPrint('Verify Stripe Response: ${verifyResponse.body}');
      if (!mounted) return;
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        final List<Course> bundleCourses = _parseBundleCourses(data);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnrollmentSuccessScreen(
              enrollmentId: data['enrollment_id'] ?? _lastEnrollmentId,
              course: widget.course,
              bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
              bundleTitle: data['bundle_title']?.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment verification failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _handleSslCommerzSuccess(SSLCTransactionInfoModel response) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifySslCommerzPayment(
        tranId: response.tranId!,
        valId: response.valId!,
        amount: response.amount!,
        enrollmentId: _lastEnrollmentId!,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      if (!mounted) return;
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        final List<Course> bundleCourses = _parseBundleCourses(data);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnrollmentSuccessScreen(
              enrollmentId: _lastEnrollmentId,
              course: widget.course,
              bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
              bundleTitle: data['bundle_title']?.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment verification failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _handlePaystackSuccess(String reference) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifyPaystackPayment(
        reference: reference,
        enrollmentId: _lastEnrollmentId!,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      if (!mounted) return;
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnrollmentSuccessScreen(
              enrollmentId: _lastEnrollmentId,
              course: widget.course,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment verification failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Parses the bundle_courses list from an API success response into Course objects.
  List<Course> _parseBundleCourses(Map<String, dynamic> data) {
    final raw = data['bundle_courses'];
    if (raw == null || raw is! List) return [];
    return raw.map<Course>((item) {
      // Safely parse rating — may come back as a string or num from JSON
      double? rating;
      final ratingRaw = item['rating'];
      if (ratingRaw != null) {
        rating = ratingRaw is num
            ? ratingRaw.toDouble()
            : double.tryParse(ratingRaw.toString());
      }

      // Safely parse students_count — same potential string/int issue
      int studentsCount = 0;
      final scRaw = item['students_count'];
      if (scRaw != null) {
        studentsCount = scRaw is num
            ? scRaw.toInt()
            : int.tryParse(scRaw.toString()) ?? 0;
      }

      return Course(
        id: item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0,
        title: item['title']?.toString() ?? '',
        thumbnail: item['thumbnail']?.toString(),
        instructorName: item['instructor_name']?.toString(),
        rating: rating,
        studentsCount: studentsCount,
      );
    }).toList();
  }

  void _handleMollieSuccess(String paymentId) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifyMolliePayment(
        paymentId: paymentId,
        enrollmentId: _lastEnrollmentId!,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      if (!mounted) return;
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        final List<Course> bundleCourses = _parseBundleCourses(data);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnrollmentSuccessScreen(
              enrollmentId: _lastEnrollmentId,
              course: widget.course,
              bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
              bundleTitle: data['bundle_title']?.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment verification failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_isProcessing) return;
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to continue')));
      return;
    }

    if (_selectedPaymentMethod?.toLowerCase() == 'offline') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OfflinePaymentScreen(course: widget.course, isBundle: widget.isBundle),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final response = widget.isBundle 
          ? await courseService.enrollBundle(
              widget.course.id,
              _selectedPaymentMethod!,
              confirmDuplicate: true,
            )
          : await courseService.enrollCourse(
              widget.course.id,
              _selectedPaymentMethod!,
            );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      setState(() {
        _isProcessing = false;
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (_selectedPaymentMethod?.toLowerCase() == 'razorpay') {
          await _processRazorpay(data);
        } else if (_selectedPaymentMethod?.toLowerCase() == 'sslcommerz') {
          await _processSslCommerz(data);
        } else if (_selectedPaymentMethod?.toLowerCase() == 'stripe') {
          await _processStripe(data);
        } else if (_selectedPaymentMethod?.toLowerCase() == 'paystack') {
          await _processPaystack(data);
        } else if (_selectedPaymentMethod?.toLowerCase() == 'mollie') {
          await _processMollie(data);
        } else if (_selectedPaymentMethod?.toLowerCase() == 'paypal') {
          await _processPaypal(data);
        } else if (_selectedPaymentMethod?.toLowerCase() == 'bkash') {
          await _processBkash(data);
        } else if (data['message'] != null && data['success'] == true) {
          // Probably free or offline
          final List<Course> bundleCourses = _parseBundleCourses(data);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EnrollmentSuccessScreen(
                enrollmentId: data['enrollment_id'],
                course: widget.course,
                bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
                bundleTitle: data['bundle_title']?.toString(),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Enrollment failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  double get _finalPrice => _originalPrice - _discount;

  // ─── bKash ───────────────────────────────────────────────────────────────

  Future<void> _processBkash(Map<String, dynamic> data) async {
    try {
      _lastEnrollmentId = data['enrollment_id'];
      final String checkoutUrl = data['checkout_url'] ?? '';
      final String paymentId   = data['payment_id']   ?? '';

      if (checkoutUrl.isEmpty || paymentId.isEmpty) {
        throw Exception('Invalid bKash configuration');
      }

      setState(() {
        _bkashPaymentId = paymentId;
        _bkashPending   = true;
      });

      // Open bKash checkout in in-app WebView (same pattern as Mollie)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(
            url: checkoutUrl,
            title: 'bKash Payment',
            shouldExit: (url) {
              return url.contains('/payment/bkash/callback');
            },
          ),
        ),
      );

      // On return from WebView, trigger verification
      if (_bkashPending && _bkashPaymentId != null) {
        _bkashPending = false;
        _handleBkashSuccess(_bkashPaymentId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleBkashSuccess(String paymentId) async {
    if (_isVerifying) return;
    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final courseService = CourseService();
      final verifyResponse = await courseService.verifyBkashPayment(
        paymentId:    paymentId,
        enrollmentId: _lastEnrollmentId!,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
      }

      if (!mounted) return;
      final data = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 200 && data['success'] == true) {
        final List<Course> bundleCourses = _parseBundleCourses(data);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnrollmentSuccessScreen(
              enrollmentId: _lastEnrollmentId,
              course: widget.course,
              bundleCourses: bundleCourses.isNotEmpty ? bundleCourses : null,
              bundleTitle: data['bundle_title']?.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Payment verification failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to verify payment: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      });
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final paymentMethods = settingsProvider.paymentMethods;
    if (_selectedPaymentMethod == null && paymentMethods.isNotEmpty) {
      _selectedPaymentMethod = paymentMethods.first.identifier;
    }

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: <Widget>[
          // Background decorative shapes
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3,
            child: CustomPaint(
              painter: _BackgroundPainter(
                color1: AppTheme.getMint100(context),
                color2: AppTheme.getMint200(context),
              ),
              child: Container(),
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                // App Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          size: 20,
                          color: AppTheme.getTextColor(context),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Text(
                          'Checkout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Balance for back button
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Course Summary and Price Breakdown Card
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.getCardColor(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Course Summary',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Course Thumbnail
                                    Container(
                                      width: 100,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[200],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: widget.course.thumbnail != null
                                            ? Image.network(
                                                widget.course.thumbnail!,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/img/courses/course5.jpg',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Course Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.course.title,
                                            style: TextStyle(
                                              color: AppTheme.getTextColor(
                                                context,
                                              ),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: AppTheme.softOrange800,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedStar,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                widget.course.rating
                                                        ?.toStringAsFixed(1) ??
                                                    '0.0',
                                                style: TextStyle(
                                                  color: AppTheme.getTextColor(
                                                    context,
                                                  ).withValues(alpha: 0.7),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: HugeIcon(
                                                    icon: HugeIcons
                                                        .strokeRoundedAiUser,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${widget.course.studentsCount ?? 0} Students',
                                                style: TextStyle(
                                                  color: AppTheme.getTextColor(
                                                    context,
                                                  ).withValues(alpha: 0.7),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Price Breakdown',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _PriceRow(
                                  label: 'Course Price',
                                  amount: settingsProvider.formatPrice(
                                    _originalPrice,
                                  ),
                                  isTotal: false,
                                ),
                                if (_discount > 0) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.local_offer,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Discount (${_discountPercent.toStringAsFixed(0)}%)',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '-${settingsProvider.formatPrice(_discount)}',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 12),
                                _PriceRow(
                                  label: 'Total',
                                  amount: settingsProvider.formatPrice(
                                    _finalPrice,
                                  ),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                          // Payment Method
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.getCardColor(context),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Payment Method',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ...paymentMethods.map((method) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _PaymentMethodOption(
                                      icon: method.identifier == 'razorpay'
                                          ? Icons.payment
                                          : method.identifier == 'offline'
                                          ? Icons.account_balance
                                          : method.identifier == 'paystack'
                                          ? Icons.credit_card_rounded
                                          : method.identifier == 'mollie'
                                          ? Icons.payment_outlined
                                          : method.identifier == 'paypal'
                                          ? Icons.paypal_outlined
                                          : Icons.credit_card,
                                      title: method.name,
                                      subtitle:
                                          method.description ??
                                          'Pay with ${method.name}',
                                      isSelected:
                                          _selectedPaymentMethod ==
                                          method.identifier,
                                      onTap: () {
                                        setState(() {
                                          _selectedPaymentMethod =
                                              method.identifier;
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 100,
                          ), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom fixed bar with total and confirm button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppTheme.getCardColor(context).withValues(alpha: 0.0),
                    AppTheme.getCardColor(context).withValues(alpha: 0.5),
                    AppTheme.getCardColor(context),
                  ],
                  stops: const <double>[0.0, 0.5, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Total',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              settingsProvider.formatPrice(_finalPrice),
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                              onPressed: _confirmPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.mint100,
                                foregroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Confirm Payment',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.color1, required this.color2});

  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.6,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    final Paint paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    final Path path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width,
        size.height * 0.7,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    required this.isTotal,
  });

  final String label;
  final String amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? AppTheme.getTextColor(context)
                : AppTheme.getTextColor(context).withValues(alpha: 0.7),
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isTotal
                ? AppTheme.getTextColor(context)
                : AppTheme.getTextColor(context).withValues(alpha: 0.7),
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getMint100(context)
              : AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.getPrimaryColor(context)
                    : AppTheme.getMint100(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.getTextColor(context),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.getPrimaryColor(context)
                      : AppTheme.getTextColor(context).withValues(alpha: 0.3),
                  width: 2,
                ),
                color: isSelected
                    ? AppTheme.getPrimaryColor(context)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
