import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

void showRateAppSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return _RateAppSheet();
    },
  );
}

class _RateAppSheet extends StatefulWidget {
  @override
  State<_RateAppSheet> createState() => _RateAppSheetState();
}

class _RateAppSheetState extends State<_RateAppSheet> {
  int _selectedRating = 0;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating > 0) {
      Navigator.of(context).pop();

      // If 5 stars, redirect to store
      if (_selectedRating == 5) {
        // Replace with actual app store / play store URL
        final Uri url = Uri.parse('https://play.google.com/store/apps');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thank you for your rating!',
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            backgroundColor: AppTheme.getCardColor(context),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedStar,
                    size: 40,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Rate Our App',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How would you rate your experience?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final int rating = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = rating;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        rating <= _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        size: 40,
                        color: rating <= _selectedRating
                            ? Colors.amber
                            : AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Feedback Text (optional)
              if (_selectedRating > 0 && _selectedRating < 5)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tell us how we can improve...',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                          : Colors.grey[50],
                      hintStyle: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.getTextColor(context),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRating > 0 ? _submitRating : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedRating == 5
                        ? 'Rate on App Store'
                        : 'Submit Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Maybe Later',
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
