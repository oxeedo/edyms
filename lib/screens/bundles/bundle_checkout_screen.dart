import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/bundle.dart';
import '../../services/course_service.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class BundleCheckoutScreen extends StatefulWidget {
  final Bundle bundle;
  const BundleCheckoutScreen({super.key, required this.bundle});

  @override
  State<BundleCheckoutScreen> createState() => _BundleCheckoutScreenState();
}

class _BundleCheckoutScreenState extends State<BundleCheckoutScreen> {
  bool _isProcessing = false;

  void _enrollOffline() async {
    setState(() { _isProcessing = true; });
    try {
      final courseService = CourseService();
      final response = await courseService.enrollBundle(
        widget.bundle.id,
        'offline',
        transactionId: 'TEST-TX-${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['is_duplicate_warning'] == true) {
            bool? proceed = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                    title: const Text('Duplicate Courses'),
                    content: Text(data['message']),
                    actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Proceed Anyway')),
                    ],
                )
            );
            if (!mounted) return;
            if (proceed == true) {
                final confirmResponse = await courseService.enrollBundle(
                    widget.bundle.id,
                    'offline',
                    transactionId: 'TEST-TX-${DateTime.now().millisecondsSinceEpoch}',
                    confirmDuplicate: true,
                );

                if (!mounted) return;
                final finalData = jsonDecode(confirmResponse.body);
                if (confirmResponse.statusCode == 200) {
                    messenger.showSnackBar(SnackBar(content: Text(finalData['message'] ?? 'Enrolled!')));
                    nav.pop();
                } else {
                    messenger.showSnackBar(SnackBar(content: Text(finalData['message'] ?? 'Failed')));
                }
            }
        } else {
            messenger.showSnackBar(SnackBar(content: Text(data['message'] ?? 'Enrollment requested!')));
            nav.pop();
        }
      } else {
        messenger.showSnackBar(SnackBar(content: Text(data['message'] ?? 'Failed')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Bundle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Checkout for ${widget.bundle.title}'),
            const SizedBox(height: 20),
            Text('Total: ${Provider.of<SettingsProvider>(context, listen: false).formatPrice(widget.bundle.price)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _isProcessing
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _enrollOffline,
                    child: const Text('Pay with Offline Payment'),
                  )
          ],
        ),
      ),
    );
  }
}
