import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/services/api_service.dart';
import 'package:medikiosk/services/auth_service.dart';

class DoctorLoginScreen extends ConsumerStatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  ConsumerState<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends ConsumerState<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Must include an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must include a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must include a number';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Must include a special character';
    }
    return null;
  }

  Future<void> _onLogin() async {
    setState(() => _submitted = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final result = await api.loginDoctor(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

        final accessToken = result['accessToken'] ??
          result['access_token'] ??
          result['token'];
      if (accessToken is! String || accessToken.isEmpty) {
        throw StateError('Login response did not include an access token');
      }
      await AuthService().saveAccessToken(accessToken);

      print('[DoctorLogin] role: ${result['role']}');
      print('[DoctorLogin] fullName: ${result['fullName']}');

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${result['fullName']}!'),
          backgroundColor: DesignTokens.success500,
        ),
      );
      
      context.go('/doctor-dashboard');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMsg = 'Login failed';
      if (e.response?.statusCode == 401) {
        errorMsg = 'Invalid username or password';
      } else if (e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Server is taking too long. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'No internet connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: DesignTokens.critical500,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $e'),
          backgroundColor: DesignTokens.critical500,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B6B6A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: DesignTokens.white,
            size: 20,
          ),
          onPressed: () => context.go('/role-selection'),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: DesignTokens.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: DesignTokens.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MediKiosk',
              style: MediKioskTheme.headline3.copyWith(
                color: DesignTokens.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          autovalidateMode:
              _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              
              Center(
                child: Text(
                  'Welcome Back',
                  style: MediKioskTheme.headline2.copyWith(
                    color: DesignTokens.neutral950,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Login to access your doctor dashboard',
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.neutral500,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              
              _buildFieldLabel('Username', true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                validator: _validateUsername,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'Enter your username',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 20),

              
              _buildFieldLabel('Full Name', true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                validator: _validateFullName,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
              ),
              const SizedBox(height: 20),

              
              _buildFieldLabel('Password', true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: _validatePassword,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _onLogin(),
                decoration: _inputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: GestureDetector(
                    onTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: DesignTokens.neutral400,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Password must be at least 8 characters long and include\nuppercase, lowercase, number & special character.',
                style: MediKioskTheme.body.copyWith(
                  color: DesignTokens.neutral400,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              
              _buildLoginButton(),
              const SizedBox(height: 24),

              
              Row(
                children: [
                  const Expanded(
                    child: Divider(color: DesignTokens.neutral200, thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or login with',
                      style: MediKioskTheme.body.copyWith(
                        color: DesignTokens.neutral400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: DesignTokens.neutral200, thickness: 1),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/doctor-register'),
                  icon: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: DesignTokens.primary600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: DesignTokens.white,
                      size: 16,
                    ),
                  ),
                  label: Text(
                    'Doctor Registration',
                    style: MediKioskTheme.bodyMedium.copyWith(
                      color: DesignTokens.primary600,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: DesignTokens.neutral200,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusInput),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: DesignTokens.neutral400,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your data is secure and encrypted',
                    style: MediKioskTheme.body.copyWith(
                      color: DesignTokens.neutral400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool required) {
    return Row(
      children: [
        Text(
          label,
          style: MediKioskTheme.bodyMedium.copyWith(
            color: DesignTokens.neutral900,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: DesignTokens.critical500,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: MediKioskTheme.body.copyWith(
        color: DesignTokens.neutral400,
        fontSize: 15,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: DesignTokens.neutral400,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: DesignTokens.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingMD,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
        borderSide: const BorderSide(
          color: DesignTokens.neutral200,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
        borderSide: const BorderSide(
          color: DesignTokens.neutral200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
        borderSide: const BorderSide(
          color: DesignTokens.primary500,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
        borderSide: const BorderSide(
          color: DesignTokens.critical500,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusInput),
        borderSide: const BorderSide(
          color: DesignTokens.critical500,
          width: 2,
        ),
      ),
      errorStyle: MediKioskTheme.body.copyWith(
        color: DesignTokens.critical500,
        fontSize: 12,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B6B6A),
          foregroundColor: DesignTokens.white,
          disabledBackgroundColor: const Color(0xFF0B6B6A).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: DesignTokens.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'LOGIN',
                style: MediKioskTheme.headline3.copyWith(
                  color: DesignTokens.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}