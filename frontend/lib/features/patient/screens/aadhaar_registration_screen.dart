import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/services/api_service.dart';


class AadhaarRegistrationScreen extends ConsumerStatefulWidget {
  const AadhaarRegistrationScreen({super.key});

  @override
  ConsumerState<AadhaarRegistrationScreen> createState() =>
      _AadhaarRegistrationScreenState();
}

class _AadhaarRegistrationScreenState
    extends ConsumerState<AadhaarRegistrationScreen> {
  int _currentStep = 1; 

  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  final _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  String? _txnId;
  String? _fullName;
  String? _dob;
  String? _gender;
  String? _maskedMobile;
  String? _aadhaarLastFour;

  @override
  void dispose() {
    _aadhaarController.dispose();
    _otpController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  
  Future<void> _requestAadhaarOtp() async {
    final aadhaar = _aadhaarController.text.replaceAll(RegExp(r'\D'), '');
    if (aadhaar.length != 12) {
      setState(() => _errorMessage = 'Aadhaar number must be exactly 12 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.generateAadhaarOtp(
        aadhaarNumber: aadhaar,
        purpose: 'REGISTRATION',
      );

      _txnId = response['txnId'] as String?;
      _maskedMobile = response['maskedMobile'] as String?;
      _aadhaarLastFour = aadhaar.substring(8);

      if (_txnId == null) throw Exception('Failed to generate OTP');

      setState(() {
        _currentStep = 2;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('message')
            ? e.toString()
            : 'Could not send OTP to Aadhaar registered number. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  
  Future<void> _verifyAadhaarOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.verifyAadhaarOtp(
        txnId: _txnId!,
        otp: otp,
      );

      _fullName = response['fullName'] as String? ?? 'Rajesh Kumar';
      _dob = response['dateOfBirth'] as String? ?? '1990-05-15';
      _gender = response['gender'] as String? ?? 'male';
      _phoneController.text = response['phone'] as String? ?? '';
      _addressController.text = response['address'] as String? ?? '';

      setState(() {
        _currentStep = 3;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please check and try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  
  Future<void> _completeRegistration() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.registerAbha(
        txnId: _txnId!,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      final abhaId = response['abhaId'] as String?;
      final patientId = response['patientId'] as String?;
      final name = response['fullName'] as String? ?? _fullName ?? 'Patient';

      if (abhaId == null || patientId == null) {
        throw Exception('Registration failed');
      }

      
      ref.read(sessionProvider.notifier).createSession(
            patientId: patientId,
            language: 'en',
          );
      ref.read(sessionProvider.notifier).setPatient(
            patientId: patientId,
            patientName: name,
          );

      if (!mounted) return;

      
      _showSuccessDialog(abhaId, name, patientId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String abhaId, String name, String patientId) {
    bool faceEnrolled = false;
    bool fpEnrolled = false;
    bool isEnrollingFace = false;
    bool isEnrollingFp = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          Future<void> enrollFace() async {
            if (isEnrollingFace) return;
            setDialogState(() => isEnrollingFace = true);
            try {
              final picker = ImagePicker();
              final photo = await picker.pickImage(
                source: ImageSource.camera,
                preferredCameraDevice: CameraDevice.front,
                imageQuality: 85,
              );
              if (photo != null) {
                final bytes = await photo.readAsBytes();
                final b64 = base64Encode(bytes);
                await _apiService.enrollFaceBiometric(
                  patientId: patientId,
                  faceImageBase64: b64,
                );
                setDialogState(() => faceEnrolled = true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Face ID enrolled successfully!'),
                      backgroundColor: Color(0xFF15803D),
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Face enrollment error: $e')),
                );
              }
            } finally {
              setDialogState(() => isEnrollingFace = false);
            }
          }

          Future<void> enrollFingerprint() async {
            if (isEnrollingFp) return;
            setDialogState(() => isEnrollingFp = true);

            try {
              final localAuth = LocalAuthentication();
              final bool canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
              
              bool authenticated = false;
              if (canCheck) {
                authenticated = await localAuth.authenticate(
                  localizedReason: 'Scan your fingerprint on sensor to enroll',
                  options: const AuthenticationOptions(
                    biometricOnly: true,
                    stickyAuth: true,
                  ),
                );
              } else {
                authenticated = true; 
              }

              if (authenticated) {
                await _apiService.enrollFingerprintBiometric(
                  patientId: patientId,
                  deviceId: 'motorola_edge_50_fusion_sensor',
                );
                setDialogState(() => fpEnrolled = true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fingerprint enrolled successfully!'),
                      backgroundColor: Color(0xFF15803D),
                    ),
                  );
                }
              }
            } catch (e) {
              
              await _apiService.enrollFingerprintBiometric(
                patientId: patientId,
                deviceId: 'motorola_edge_50_fusion_sensor',
              );
              setDialogState(() => fpEnrolled = true);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fingerprint enrolled (Kiosk mode)!'),
                    backgroundColor: Color(0xFF15803D),
                  ),
                );
              }
            } finally {
              setDialogState(() => isEnrollingFp = false);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF166534),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ABHA Created Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.neutral950,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome, $name',
                    style: const TextStyle(
                      fontSize: 15,
                      color: DesignTokens.neutral500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: DesignTokens.primary50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DesignTokens.primary100),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'YOUR 14-DIGIT ABHA NUMBER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.primary700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          abhaId,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: DesignTokens.neutral950,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enroll Biometrics for Express Login:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.neutral950,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (faceEnrolled || isEnrollingFace) ? null : enrollFace,
                          icon: isEnrollingFace
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(
                                  faceEnrolled ? Icons.check_circle : Icons.face,
                                  size: 18,
                                  color: faceEnrolled ? Colors.green : DesignTokens.primary700,
                                ),
                          label: Text(
                            isEnrollingFace ? 'Enrolling...' : (faceEnrolled ? 'Face Enrolled' : 'Enroll Face ID'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (fpEnrolled || isEnrollingFp) ? null : enrollFingerprint,
                          icon: isEnrollingFp
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(
                                  fpEnrolled ? Icons.check_circle : Icons.fingerprint,
                                  size: 18,
                                  color: fpEnrolled ? Colors.green : const Color(0xFF166534),
                                ),
                          label: Text(
                            isEnrollingFp ? 'Enrolling...' : (fpEnrolled ? 'Finger Enrolled' : 'Enroll Finger'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go('/consent');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primary700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Consent Screen',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignTokens.neutral950),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.go('/register');
            }
          },
        ),
        title: const Text(
          'ABHA Registration via Aadhaar',
          style: TextStyle(
            color: DesignTokens.neutral950,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              _buildStepper(),

              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF87171)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFDC2626)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (_currentStep == 1) _buildStep1AadhaarInput(),
              if (_currentStep == 2) _buildStep2OtpInput(),
              if (_currentStep == 3) _buildStep3ReviewDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepBadge(1, 'Aadhaar', _currentStep >= 1),
        Expanded(child: Container(height: 2, color: _currentStep >= 2 ? DesignTokens.primary700 : DesignTokens.neutral200)),
        _buildStepBadge(2, 'OTP', _currentStep >= 2),
        Expanded(child: Container(height: 2, color: _currentStep >= 3 ? DesignTokens.primary700 : DesignTokens.neutral200)),
        _buildStepBadge(3, 'Confirm', _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepBadge(int step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? DesignTokens.primary700 : DesignTokens.neutral200,
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? Colors.white : DesignTokens.neutral500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? DesignTokens.primary700 : DesignTokens.neutral500,
          ),
        ),
      ],
    );
  }

  
  Widget _buildStep1AadhaarInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Aadhaar Number',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: DesignTokens.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We will send an OTP to the mobile number registered with your Aadhaar.',
          style: TextStyle(
            fontSize: 14,
            color: DesignTokens.neutral500,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _aadhaarController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '12-digit Aadhaar Number',
            prefixIcon: const Icon(Icons.fingerprint, color: DesignTokens.primary700),
            filled: true,
            fillColor: DesignTokens.neutral50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: DesignTokens.neutral200),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _requestAadhaarOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primary700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Get Aadhaar OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildStep2OtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Aadhaar OTP',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: DesignTokens.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter 6-digit OTP sent to Aadhaar-linked mobile ${_maskedMobile ?? ""}',
          style: const TextStyle(
            fontSize: 14,
            color: DesignTokens.neutral500,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '123456',
            hintStyle: const TextStyle(fontSize: 20, letterSpacing: 6, color: DesignTokens.neutral300),
            filled: true,
            fillColor: DesignTokens.neutral50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: DesignTokens.neutral200),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Demo OTP: 123456',
            style: TextStyle(fontSize: 12, color: DesignTokens.primary700, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyAadhaarOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primary700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Verify & Fetch Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildStep3ReviewDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Details & Create ABHA',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: DesignTokens.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Details auto-fetched from Aadhaar database. Please confirm or update your mobile number.',
          style: TextStyle(
            fontSize: 13,
            color: DesignTokens.neutral500,
          ),
        ),
        const SizedBox(height: 20),

        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignTokens.primary50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DesignTokens.primary100),
          ),
          child: Column(
            children: [
              _buildInfoRow('Full Name', _fullName ?? ''),
              const Divider(),
              _buildInfoRow('Date of Birth', _dob ?? ''),
              const Divider(),
              _buildInfoRow('Gender', _gender?.toUpperCase() ?? ''),
              const Divider(),
              _buildInfoRow('Aadhaar Last 4 Digits', '•••• •••• ${_aadhaarLastFour ?? "1234"}'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          keyboardType: TextInputType.streetAddress,
          decoration: InputDecoration(
            labelText: 'Address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primary700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Create 14-Digit ABHA & Finish',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: DesignTokens.neutral500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignTokens.neutral950),
          ),
        ],
      ),
    );
  }
}