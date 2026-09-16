import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/providers/locale_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/features/patient/providers/patient_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _abhaController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();

  String? _selectedGender;
  String _preferredLanguage = 'English';
  bool _isMinor = false;
  bool _agreedToTerms = false;
  bool _submitted = false;

  @override
  void dispose() {
    _abhaController.dispose();
    _fullnameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  
  String? _validateAbha(String? v) {
    if (v == null || v.trim().isEmpty) return 'ABHA ID is required';
    final digits = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d{14}$').hasMatch(digits)) return 'ABHA ID must be exactly 14 digits';
    return null;
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateDob(String? v) {
    if (v == null || v.trim().isEmpty) return 'Date of birth is required';
    return null;
  }

  String? _validateGender(String? v) {
    if (v == null || v.isEmpty) return 'Please select a gender';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    final digits = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(digits)) return 'Phone number must be exactly 10 digits';
    return null;
  }

  String? _validateAddress(String? v) {
    if (v == null || v.trim().isEmpty) return 'Address is required';
    if (v.trim().length < 5) return 'Please enter a complete address';
    return null;
  }

  String? _validateGuardianName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Parent/Guardian name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateGuardianPhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Guardian phone number is required';
    final digits = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d{10}$').hasMatch(digits)) return 'Phone number must be exactly 10 digits';
    return null;
  }

  void _onRegister() async {
    
    FocusScope.of(context).unfocus();

    setState(() => _submitted = true);

    
    final formValid = _formKey.currentState?.validate() ?? false;

    
    final genderValid = _validateGender(_selectedGender) == null;

    
    bool guardianValid = true;
    if (_isMinor) {
      final gNameErr = _validateGuardianName(_guardianNameController.text);
      final gPhoneErr = _validateGuardianPhone(_guardianPhoneController.text);
      guardianValid = gNameErr == null && gPhoneErr == null;
    }

    
    if (!formValid || !genderValid || !guardianValid || !_agreedToTerms) {
      if (!_agreedToTerms && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms & Conditions'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    
    try {
      final regNotifier = ref.read(registrationProvider.notifier);
      final success = await regNotifier.register(
        abhaId: _abhaController.text.trim(),
        name: _fullnameController.text.trim(),
        dateOfBirth: _dobController.text.trim(),
        gender: _selectedGender!,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        isMinor: _isMinor,
        preferredLanguage: _preferredLanguage,
        guardianName: _isMinor ? _guardianNameController.text.trim() : null,
        guardianPhone: _isMinor ? _guardianPhoneController.text.trim() : null,
      );

      if (!mounted) return;

      if (success) {
        
        final patient = ref.read(registrationProvider).patient;
        if (patient != null && patient.id != null) {
          await ref.read(sessionProvider.notifier).createSession(
            patientId: patient.id!,
            language: _preferredLanguage == 'हिन्दी' ? 'hi' : 'en',
          );
          
          ref.read(sessionProvider.notifier).setPatient(
            patientId: patient.id!,
            patientName: patient.name ?? _fullnameController.text.trim(),
          );
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Color(0xFF166534),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/consent');
      } else {
        final errorMsg = ref.read(registrationProvider).errorMessage ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: ${e.toString()}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale.languageCode == 'hi';
    final genderError = _submitted ? _validateGender(_selectedGender) : null;
    final regState = ref.watch(registrationProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),
      body: Stack(
        children: [
          Column(
            children: [
              
              Container(
                color: const Color(0xFFF5F7F7),
                padding: const EdgeInsets.only(top: 52, left: 8, right: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2332), size: 24),
                      onPressed: () => context.go('/role-selection'),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A2332)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.read(localeProvider.notifier).setLanguageCode(isHindi ? 'en' : 'hi'),
                      child: Text(
                        isHindi ? 'English' : 'हिन्दी',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF00796B)),
                      ),
                    ),
                  ],
                ),
              ),

              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildLogo(),
                        const SizedBox(height: 16),
                        _buildSectionHeader(isHindi),
                        const SizedBox(height: 16),

                        
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00796B), Color(0xFF004D40)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00796B).withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.fingerprint, color: Colors.white, size: 28),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isHindi ? 'आधार OTP से ABHA बनाएं (30 Sec)' : 'Create ABHA via Aadhaar OTP',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isHindi ? 'Aadhaar OTP से 30 सेकंड में ऑटो-फिल ABHA अकाउंट बनाएं' : 'Instant 14-digit ABHA creation with Aadhaar auto-fetched profile',
                                style: const TextStyle(color: Color(0xFFB2DFDB), fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: () => context.go('/aadhaar-register'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF004D40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    isHindi ? 'आधार रजिस्ट्रेशन शुरू करें' : 'Start Aadhaar Registration ➔',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        
                        _FieldContainer(
                          label: 'ABHA ID',
                          required: true,
                          prefixIcon: Icons.badge_outlined,
                          suffixIcon: Icons.document_scanner_outlined,
                          child: TextFormField(
                            controller: _abhaController,
                            keyboardType: TextInputType.number,
                            validator: _validateAbha,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                            decoration: _inputDecoration(isHindi ? 'अपनी 14 अंकों की ABHA ID दर्ज करें' : 'Enter your 14 digit ABHA ID'),
                          ),
                        ),
                        _FieldError(error: _submitted ? _validateAbha(_abhaController.text) : null),
                        const SizedBox(height: 10),

                        
                        _FieldContainer(
                          label: 'Full Name',
                          required: true,
                          prefixIcon: Icons.person_outline_rounded,
                          child: TextFormField(
                            controller: _fullnameController,
                            keyboardType: TextInputType.name,
                            validator: _validateName,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                            decoration: _inputDecoration(isHindi ? 'अपना पूरा नाम दर्ज करें' : 'Enter your full name'),
                          ),
                        ),
                        _FieldError(error: _submitted ? _validateName(_fullnameController.text) : null),
                        const SizedBox(height: 10),

                        
                        _FieldContainer(
                          label: 'Date of Birth',
                          required: true,
                          prefixIcon: Icons.calendar_today_outlined,
                          suffixIcon: Icons.calendar_today_outlined,
                          onSuffixTap: () => _selectDate(context),
                          child: TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                            validator: _validateDob,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                            decoration: _inputDecoration('DD / MM / YYYY'),
                          ),
                        ),
                        _FieldError(error: _submitted ? _validateDob(_dobController.text) : null),
                        const SizedBox(height: 10),

                        
                        _FieldContainer(
                          label: 'Gender',
                          required: true,
                          prefixIcon: Icons.people_outline,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              hint: Text(
                                isHindi ? 'लिंग चुनें' : 'Select gender',
                                style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                              ),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                              items: [
                                DropdownMenuItem(value: 'male', child: Text(isHindi ? 'पुरुष' : 'Male')),
                                DropdownMenuItem(value: 'female', child: Text(isHindi ? 'महिला' : 'Female')),
                                DropdownMenuItem(value: 'other', child: Text(isHindi ? 'अन्य' : 'Other')),
                              ],
                              onChanged: (val) => setState(() => _selectedGender = val),
                            ),
                          ),
                        ),
                        _FieldError(error: genderError),
                        const SizedBox(height: 10),

                        
                        _PhoneField(
                          controller: _phoneController,
                          validator: _validatePhone,
                          hintText: 'Enter 10 digit mobile number',
                        ),
                        _FieldError(error: _submitted ? _validatePhone(_phoneController.text) : null),
                        const SizedBox(height: 10),

                        
                        _FieldContainer(
                          label: 'Address',
                          required: true,
                          prefixIcon: Icons.location_on_outlined,
                          child: TextFormField(
                            controller: _addressController,
                            keyboardType: TextInputType.streetAddress,
                            validator: _validateAddress,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                            decoration: _inputDecoration(isHindi ? 'अपना पूरा पता दर्ज करें' : 'Enter your complete address'),
                          ),
                        ),
                        _FieldError(error: _submitted ? _validateAddress(_addressController.text) : null),
                        const SizedBox(height: 10),

                        
                        _buildMinorField(isHindi),

                        
                        if (_isMinor) ...[
                          const SizedBox(height: 10),
                          _FieldContainer(
                            label: 'Parent/Guardian Name',
                            required: true,
                            prefixIcon: Icons.supervisor_account_outlined,
                            child: TextFormField(
                              controller: _guardianNameController,
                              keyboardType: TextInputType.name,
                              validator: _validateGuardianName,
                              style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                              decoration: _inputDecoration(isHindi ? 'अभिभावक का नाम दर्ज करें' : 'Enter parent/guardian name'),
                            ),
                          ),
                          _FieldError(error: _submitted ? _validateGuardianName(_guardianNameController.text) : null),
                          const SizedBox(height: 10),
                          _PhoneField(
                            controller: _guardianPhoneController,
                            validator: _validateGuardianPhone,
                            hintText: isHindi ? 'अभिभावक का मोबाइल नंबर' : 'Enter guardian mobile number',
                          ),
                          _FieldError(error: _submitted ? _validateGuardianPhone(_guardianPhoneController.text) : null),
                          const SizedBox(height: 6),
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: Color(0xFF087F8C)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isHindi
                                        ? 'किशोर (18 वर्ष से कम) के लिए माता-पिता/अभिभावक की सहमति आवश्यक है'
                                        : 'Parental consent is required for minors (under 18 years)',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF087F8C), fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        
                        _FieldContainer(
                          label: 'Preferred Language',
                          required: true,
                          prefixIcon: Icons.language,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _preferredLanguage,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                              style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                              items: const [
                                DropdownMenuItem(value: 'English', child: Text('English')),
                                DropdownMenuItem(value: 'हिन्दी', child: Text('हिन्दी')),
                                DropdownMenuItem(value: 'தமிழ்', child: Text('தமிழ்')),
                                DropdownMenuItem(value: 'বাংলা', child: Text('বাংলা')),
                                DropdownMenuItem(value: 'తెలుగు', child: Text('తెలుగు')),
                                DropdownMenuItem(value: 'मराठी', child: Text('मराठी')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _preferredLanguage = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        
                        _buildTermsCheckbox(isHindi),
                        if (_submitted && !_agreedToTerms)
                          const Padding(
                            padding: EdgeInsets.only(top: 6, left: 34),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'You must agree to the terms',
                                style: TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        
                        if (regState.status == RegistrationStatus.error && regState.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, size: 18, color: Color(0xFFDC2626)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      regState.errorMessage!,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        
                        _buildRegisterButton(isHindi, regState.status == RegistrationStatus.loading),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 80),
              painter: _WavePainter(),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE0F2F1)),
          child: const Icon(Icons.favorite_rounded, size: 44, color: Color(0xFF00796B)),
        ),
        const SizedBox(height: 8),
        const Text('Medikiosk', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF00796B), letterSpacing: -0.5)),
        const SizedBox(height: 2),
        const Text('Your Health, Our Priority', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildSectionHeader(bool isHindi) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isHindi ? 'अपना खाता बनाएं' : 'Create Your Account',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF00796B))),
          const SizedBox(height: 4),
          Text(isHindi ? 'शुरू करने के लिए विवरण भरें' : 'Fill in the details to get started',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildMinorField(bool isHindi) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 22, color: Color(0xFF6B7280)),
          const SizedBox(width: 10),
          const Text('Is Minor? ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
          const Text('*', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isMinor = true),
            child: Row(children: [
              Icon(_isMinor ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 22, color: _isMinor ? const Color(0xFF00796B) : const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(isHindi ? 'हाँ' : 'Yes', style: const TextStyle(fontSize: 15, color: Color(0xFF374151))),
            ]),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => setState(() {
              _isMinor = false;
              _guardianNameController.clear();
              _guardianPhoneController.clear();
            }),
            child: Row(children: [
              Icon(!_isMinor ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 22, color: !_isMinor ? const Color(0xFF00796B) : const Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(isHindi ? 'नहीं' : 'No', style: const TextStyle(fontSize: 15, color: Color(0xFF374151))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isHindi) {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24, margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: _agreedToTerms ? const Color(0xFF00796B) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _agreedToTerms ? const Color(0xFF00796B) : const Color(0xFF9CA3AF), width: 2),
            ),
            child: _agreedToTerms ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w400),
                children: [
                  TextSpan(text: isHindi ? 'मैं ' : 'I agree to the '),
                  TextSpan(text: isHindi ? 'नियम और शर्तें' : 'Terms & Conditions',
                      style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.w600)),
                  TextSpan(text: isHindi ? ' और ' : ' and '),
                  TextSpan(text: isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                      style: const TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(bool isHindi, bool isLoading) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF0B8A94).withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(isHindi ? 'पंजीकरण करें' : 'Register',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFF00796B), onPrimary: Colors.white, surface: Colors.white, onSurface: Color(0xFF1A2332)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
      });
    }
  }
}




class _FieldContainer extends StatelessWidget {
  final String label;
  final bool required;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final Widget child;

  const _FieldContainer({
    required this.label,
    required this.prefixIcon,
    required this.child,
    this.required = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(prefixIcon, size: 22, color: const Color(0xFF6B7280)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                    if (required)
                      const Text(' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                  ]),
                  child,
                ],
              ),
            ),
          ),
          if (suffixIcon != null)
            GestureDetector(
              onTap: onSuffixTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(suffixIcon, size: 20, color: const Color(0xFF00796B)),
              ),
            ),
        ],
      ),
    );
  }
}




class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String hintText;

  const _PhoneField({required this.controller, required this.validator, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.phone_outlined, size: 22, color: Color(0xFF6B7280)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: const Row(children: [
              Text('+91', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1A2332))),
              Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
            ]),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                    Text(' *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                  ]),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    validator: validator,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF1A2332)),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
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




class _FieldError extends StatelessWidget {
  final String? error;
  const _FieldError({this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: Color(0xFFDC2626)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              error!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}




class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE0F2F1).withValues(alpha: 0.6)..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.4)
        ..quadraticBezierTo(size.width * 0.15, 0, size.width * 0.3, size.height * 0.3)
        ..quadraticBezierTo(size.width * 0.45, size.height * 0.6, size.width * 0.55, size.height * 0.35)
        ..quadraticBezierTo(size.width * 0.7, 0, size.width * 0.85, size.height * 0.3)
        ..quadraticBezierTo(size.width * 0.95, size.height * 0.5, size.width, size.height * 0.35)
        ..lineTo(size.width, size.height)..lineTo(0, size.height)..close(),
      paint,
    );
    final paint2 = Paint()..color = const Color(0xFFB2DFDB).withValues(alpha: 0.4)..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(size.width * 0.2, size.height * 0.3, size.width * 0.4, size.height * 0.55)
        ..quadraticBezierTo(size.width * 0.6, size.height * 0.8, size.width * 0.8, size.height * 0.5)
        ..quadraticBezierTo(size.width * 0.9, size.height * 0.35, size.width, size.height * 0.55)
        ..lineTo(size.width, size.height)..lineTo(0, size.height)..close(),
      paint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}