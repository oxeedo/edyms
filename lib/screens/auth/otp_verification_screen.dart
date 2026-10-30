import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'auth_screen.dart';
// import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.email});

  final String? email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 60;
  bool _canResend = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field - verify if all fields are filled
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (!mounted) return;
    final String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.verifyOtp(widget.email!, otp);

      if (!mounted) return;

      if (result['success']) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: const Text('Verification Successful'),
          autoCloseDuration: const Duration(seconds: 2),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text('Verification Failed'),
          description: Text(result['message']),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _resendCode() async {
    if (!mounted || !_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resendOtp(widget.email!);

    if (!mounted) return;

    if (result['success']) {
      setState(() {
        _canResend = false;
        _resendCountdown = 60;
        // Clear all fields
        for (final controller in _controllers) {
          controller.clear();
        }
        if (mounted) {
          _focusNodes[0].requestFocus();
        }
      });
      _startCountdown();

      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: const Text('Code Resent'),
        description: const Text('Check your email for the new code'),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Resend Failed'),
        description: Text(result['message']),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _BackgroundDecoration(size: size),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 80),
                  // Header with logo and branding - centered
                  _HeaderSection(),
                  const SizedBox(height: 40),
                  // OTP verification card
                  _OtpVerificationCard(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    onOtpChanged: _onOtpChanged,
                    onVerify: _verifyOtp,
                    onResend: _resendCode,
                    canResend: _canResend,
                    resendCountdown: _resendCountdown,
                    email: widget.email,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppTheme.getBackgroundColor(context),
            AppTheme.getCardColor(context),
          ],
          stops: const <double>[0.0, 0.5],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode
        ? 'assets/img/logo_white.svg'
        : 'assets/img/logo.svg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[SvgPicture.asset(logoPath, width: 142, height: 44)],
      ),
    );
  }
}

class _OtpVerificationCard extends StatelessWidget {
  const _OtpVerificationCard({
    required this.controllers,
    required this.focusNodes,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
    required this.canResend,
    required this.resendCountdown,
    this.email,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int, String) onOtpChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final bool canResend;
  final int resendCountdown;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 20,
                color: AppTheme.getTextColor(context),
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 16),

            Text(
              context.l10n.otpVerificationTitle,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              context.l10n.otpVerificationSubtitle,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            if (email != null) ...[
              const SizedBox(height: 8),
              Text(
                email!,
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 40),
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 48,
                  height: 64,
                  child: TextField(
                    controller: controllers[index],
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                          : Colors.grey[50],
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
                      contentPadding: EdgeInsets.zero,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (String value) => onOtpChanged(index, value),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Verify button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getTextColor(context),
                  foregroundColor: AppTheme.getCardColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.verify,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Resend code section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  context.l10n.didntReceiveCode,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: canResend ? onResend : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    canResend
                        ? context.l10n.resendCode
                        : '${context.l10n.resendCode} (${resendCountdown}s)',
                    style: TextStyle(
                      color: canResend
                          ? AppTheme.getTextColor(context)
                          : AppTheme.getTextColor(context).withValues(alpha: 0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Back to Login link
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  context.l10n.backToLogin,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
