import '../../theme/app_theme.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                  // Login card
                  _LoginCard(
                    tabController: _tabController,
                    isPasswordVisible: _isPasswordVisible,
                    onPasswordVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
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
        ? 'assets/img/logo.png'
        : 'assets/img/logo.png';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[SvgPicture.asset(logoPath, width: 142, height: 44)],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.tabController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityToggle,
  });

  final TabController tabController;
  final bool isPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;

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
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          // Tab bar - bigger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.surfaceDark
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  color: AppTheme.getTextColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: false,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                labelColor: AppTheme.getCardColor(context),
                unselectedLabelColor: AppTheme.getTextColor(context),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                dividerColor: Colors.transparent,
                tabs: <Widget>[
                  Tab(text: context.l10n.login),
                  Tab(text: context.l10n.signup),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Tab bar view with forms
          SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.75, // Use 75% of screen height
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                _LoginForm(
                  tabController: tabController,
                  isPasswordVisible: isPasswordVisible,
                  onPasswordVisibilityToggle: onPasswordVisibilityToggle,
                ),
                _SignUpForm(
                  isPasswordVisible: isPasswordVisible,
                  onPasswordVisibilityToggle: onPasswordVisibilityToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({
    required this.tabController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityToggle,
  });

  final TabController tabController;
  final bool isPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        title: const Text('Invalid Input'),
        description: const Text('Please enter both email and password'),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    final result = await authProvider.login(email, password);

    if (!mounted) return;

    if (result['success']) {
      if (result['otp_required'] == true) {
        toastification.show(
          context: context,
          type: ToastificationType.info,
          style: ToastificationStyle.fillColored,
          title: const Text('OTP Sent'),
          description: Text(result['message'] ?? 'Please verify your email'),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 3),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationScreen(email: result['email'] ?? email),
          ),
        );
      } else {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: const Text('Login Successful'),
          description: Text(result['message'] ?? 'Welcome back!'),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 3),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: const Text('Login Failed'),
        description: Text(result['message'] ?? 'Please check your credentials'),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  void _handleSocialLogin() {
    // Handle Google login
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: context.l10n.email,
              hintText: 'tom@mail.com',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _passwordController,
            obscureText: !widget.isPasswordVisible,
            decoration: InputDecoration(
              labelText: context.l10n.password,
              hintText: '********',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
                letterSpacing: 2,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: widget.onPasswordVisibilityToggle,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Show',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
              letterSpacing: widget.isPasswordVisible ? 0 : 2,
            ),
          ),
          const SizedBox(height: 12),
          // Forgot password link
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.forgotPassword,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getTextColor(context),
                foregroundColor: AppTheme.getCardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      context.l10n.login,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Login with title
          Center(
            child: Text(
              context.l10n.loginWith,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Social login buttons
          _SocialLoginButtons(onSocialLogin: _handleSocialLogin),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

class _SignUpForm extends StatefulWidget {
  const _SignUpForm({
    required this.isPasswordVisible,
    required this.onPasswordVisibilityToggle,
  });

  final bool isPasswordVisible;
  final VoidCallback onPasswordVisibilityToggle;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Basic validation
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        title: const Text('Invalid Input'),
        description: const Text('Please fill all fields'),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        title: const Text('Password Mismatch'),
        description: const Text('Passwords do not match'),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    final userData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'terms': true, // Assuming terms are accepted by signing up
    };

    final result = await authProvider.register(userData);

    if (!mounted) return;

    if (result['success']) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        title: const Text('Registration Successful'),
        description: Text(result['message'] ?? 'Account created successfully'),
        autoCloseDuration: const Duration(seconds: 3),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      String errorMessage = result['message'] ?? 'Registration failed';
      if (result['errors'] != null) {
        // You might want to format errors better here
        errorMessage = result['message'];
      }

      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: const Text('Registration Failed'),
        description: Text(errorMessage),
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: context.l10n.firstName,
              hintText: 'John',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: context.l10n.lastName,
              hintText: 'Doe',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: context.l10n.email,
              hintText: 'john@mail.com',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _passwordController,
            obscureText: !widget.isPasswordVisible,
            decoration: InputDecoration(
              labelText: context.l10n.password,
              hintText: '********',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
                letterSpacing: 2,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: widget.onPasswordVisibilityToggle,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Show',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
              letterSpacing: widget.isPasswordVisible ? 0 : 2,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _confirmPasswordController,
            obscureText: !widget.isPasswordVisible,
            decoration: InputDecoration(
              labelText: context.l10n.confirmPassword,
              hintText: '********',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                  : Colors.grey[50],
              labelStyle: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 16,
                letterSpacing: 2,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  onPressed: widget.onPasswordVisibilityToggle,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Show',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
              letterSpacing: widget.isPasswordVisible ? 0 : 2,
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getTextColor(context),
                foregroundColor: AppTheme.getCardColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      context.l10n.signup,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SocialLoginButtons extends StatelessWidget {
  const _SocialLoginButtons({required this.onSocialLogin});

  final VoidCallback onSocialLogin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onSocialLogin,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedGoogle,
          size: 24,
          color: AppTheme.getTextColor(context),
        ),
        label: Text(
          context.l10n.continueWithGoogle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.getTextColor(context),
          side: BorderSide(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
