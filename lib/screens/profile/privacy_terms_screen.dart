import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../theme/app_theme.dart';
import '../../services/custom_page_service.dart';

class PrivacyTermsScreen extends StatefulWidget {
  const PrivacyTermsScreen({
    super.key,
    required this.title,
    required this.slug,
  });

  final String title;
  final String slug;

  @override
  State<PrivacyTermsScreen> createState() => _PrivacyTermsScreenState();
}

class _PrivacyTermsScreenState extends State<PrivacyTermsScreen> {
  final CustomPageService _customPageService = CustomPageService();
  String? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final page = await _customPageService.getPageDetails(widget.slug);
      if (mounted) {
        setState(() {
          _content = page.content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load content';
          _isLoading = false;
        });
      }
      debugPrint('Error loading page content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /*
                              Text(
                                'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context)
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              */
                          Html(
                            data: _content ?? '',
                            style: {
                              "body": Style(
                                color: AppTheme.getTextColor(context),
                                fontSize: FontSize(14),
                                fontWeight: FontWeight.w400,
                                lineHeight: LineHeight(1.6),
                                fontFamily: 'Montserrat',
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "p": Style(margin: Margins.only(bottom: 16)),
                            },
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
