import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/services/api_service.dart';

class DoctorRegistrationScreen extends ConsumerStatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  ConsumerState<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState
    extends ConsumerState<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
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

  Future<void> _onRegister() async {
    setState(() => _submitted = true);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final result = await api.registerDoctor(
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      
      print('[DoctorReg] accessToken: ${result['accessToken']}');

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: DesignTokens.success500,
        ),
      );
      context.go('/doctor-login');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMsg = 'Registration failed';
      if (e.response?.data is Map) {
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
          content: Text('Registration failed: $e'),
          backgroundColor: DesignTokens.critical500,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.white,
      body: Column(
        children: [
          
          _buildHeader(),

          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingXL,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    
                    _buildDoctorAvatar(),
                    const SizedBox(height: 16),

                    
                    Text(
                      'Doctor Registration',
                      style: MediKioskTheme.headline2.copyWith(
                        color: DesignTokens.neutral950,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to access the doctor portal',
                      textAlign: TextAlign.center,
                      style: MediKioskTheme.body.copyWith(
                        color: DesignTokens.neutral500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    
                    const Divider(
                      color: DesignTokens.neutral200,
                      thickness: 1,
                    ),
                    const SizedBox(height: 16),

                    
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 20,
                          color: DesignTokens.primary600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your information is secure and will never be shared.',
                            style: MediKioskTheme.body.copyWith(
                              color: DesignTokens.neutral500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    
                    _buildFieldLabel('Username', true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      validator: _validateUsername,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hintText: 'Enter username',
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
                        hintText: 'Enter full name',
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
                      onFieldSubmitted: (_) => _onRegister(),
                      decoration: _inputDecoration(
                        hintText: 'Enter password',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password must be at least 8 characters long and include\nuppercase, lowercase, number & special character.',
                        style: MediKioskTheme.body.copyWith(
                          color: DesignTokens.neutral400,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    
                    _buildRegisterButton(),
                    const SizedBox(height: 20),

                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: MediKioskTheme.body.copyWith(
                            color: DesignTokens.neutral500,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/doctor-login'),
                          child: Text(
                            'Login',
                            style: MediKioskTheme.body.copyWith(
                              color: DesignTokens.primary600,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 50,
        left: 16,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0B6B6A),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: DesignTokens.white,
                size: 20,
              ),
              onPressed: () => context.go('/role-selection'),
            ),
            const SizedBox(width: 4),
            
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: DesignTokens.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: DesignTokens.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediKiosk',
                  style: MediKioskTheme.headline3.copyWith(
                    color: DesignTokens.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Doctor Portal',
                  style: MediKioskTheme.body.copyWith(
                    color: DesignTokens.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorAvatar() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: DesignTokens.primary100,
                width: 3,
              ),
            ),
          ),
          
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: DesignTokens.primary100,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 50,
              color: DesignTokens.primary700,
            ),
          ),
          
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: DesignTokens.primary600,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: DesignTokens.white,
                size: 18,
              ),
            ),
          ),
        ],
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onRegister,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Register',
                    style: MediKioskTheme.headline3.copyWith(
                      color: DesignTokens.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: DesignTokens.white,
                    size: 22,
                  ),
                ],
              ),
      ),
    );
  }
}