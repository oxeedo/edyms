import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/app_theme.dart';

void showShareAppSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _ShareAppSheet();
    },
  );
}

class _ShareAppSheet extends StatelessWidget {
  final List<Map<String, dynamic>> _shareOptions = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'WhatsApp',
      'icon': Icons.chat,
      'color': Color(0xFF25D366),
    },
    <String, dynamic>{
      'name': 'Facebook',
      'icon': Icons.facebook,
      'color': Color(0xFF1877F2),
    },
    <String, dynamic>{
      'name': 'Twitter',
      'icon': Icons.alternate_email,
      'color': Color(0xFF1DA1F2),
    },
    <String, dynamic>{
      'name': 'Email',
      'icon': Icons.email,
      'color': AppTheme.primary,
    },
    <String, dynamic>{
      'name': 'Copy Link',
      'icon': Icons.link,
      'color': AppTheme.primary,
    },
    <String, dynamic>{
      'name': 'More',
      'icon': Icons.more_horiz,
      'color': AppTheme.getTextColor,
    },
  ];

  void _shareToPlatform(BuildContext context, String platform) {
    Navigator.of(context).pop();

    // Using share_plus to share the app link
    // ignore: deprecated_member_use
    Share.share('Check out EduEx App! https://eduex.example.com');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Share EduEx App',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share with friends and family',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              // Share Options Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _shareOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> option = _shareOptions[index];
                  final Color optionColor = option['color'] is Function
                      ? (option['color'] as Function)(context)
                      : option['color'] as Color;

                  return GestureDetector(
                    onTap: () =>
                        _shareToPlatform(context, option['name'] as String),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: optionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Icon(
                              option['icon'] as IconData,
                              size: 28,
                              color: optionColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // App Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.getPrimaryColor(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.school, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'EduEx App',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Learn anytime, anywhere',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
