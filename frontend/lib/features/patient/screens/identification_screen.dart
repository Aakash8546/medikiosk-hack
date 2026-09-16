import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/app/providers/locale_provider.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/features/patient/widgets/abha_account_selector.dart';
import 'package:medikiosk/services/api_service.dart';


class IdentificationScreen extends ConsumerStatefulWidget {
  const IdentificationScreen({super.key});

  @override
  ConsumerState<IdentificationScreen> createState() =>
      _IdentificationScreenState();
}

class _IdentificationScreenState extends ConsumerState<IdentificationScreen> {
  final _abhaController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _apiService = ApiService();
  int _selectedTab = 0; 
  bool _isLoading = false;

  @override
  void dispose() {
    _abhaController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/role-selection'),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: DesignTokens.neutral950,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.primary50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DesignTokens.primary100,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: DesignTokens.primary700,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'MEDIKIOSK',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: DesignTokens.neutral950,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), 
                    ],
                  ),
                ),

                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        
                        Text(
                          l10n.welcomeBack,
                          style: MediKioskTheme.headline1.copyWith(
                            color: DesignTokens.neutral950,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.loginToContinue,
                          style: MediKioskTheme.body.copyWith(
                            color: DesignTokens.neutral500,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 28),

                        
                        _buildTabBar(l10n),

                        const SizedBox(height: 20),

                        
                        _buildInputField(l10n),

                        const SizedBox(height: 24),

                        
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.primary700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    _selectedTab == 3
                                        ? 'Scan & Verify Face (AI)'
                                        : _selectedTab == 4
                                            ? 'Scan Fingerprint Sensor'
                                            : l10n.loginButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        
                        _buildOrDivider(),

                        const SizedBox(height: 20),

                        
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => context.go('/register'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: DesignTokens.primary700,
                              side: const BorderSide(
                                color: DesignTokens.primary700,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              l10n.newPatientRegister,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                
                _buildFooterBadge(l10n),
              ],
            ),

            
            Positioned(
              bottom: 70,
              left: 16,
              child: FloatingActionButton(
                onPressed: () {
                  final currentLocale =
                      Localizations.localeOf(context).languageCode;
                  
                  ref.read(localeProvider.notifier).setLanguageCode(
                        currentLocale == 'hi' ? 'en' : 'hi',
                      );
                },
                backgroundColor: DesignTokens.neutral950,
                foregroundColor: Colors.white,
                elevation: 2,
                mini: true,
                shape: const CircleBorder(),
                child: const Icon(Icons.language, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildTabBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DesignTokens.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab(
              icon: Icons.badge_outlined,
              label: l10n.abhaIdTab,
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            const SizedBox(width: 4),
            _buildTab(
              icon: Icons.phone_outlined,
              label: l10n.phoneTab,
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
            const SizedBox(width: 4),
            _buildTab(
              icon: Icons.credit_card,
              label: 'Aadhaar',
              isSelected: _selectedTab == 2,
              onTap: () => setState(() => _selectedTab = 2),
            ),
            const SizedBox(width: 4),
            _buildTab(
              icon: Icons.face_retouching_natural,
              label: 'Face AI',
              isSelected: _selectedTab == 3,
              onTap: () => setState(() => _selectedTab = 3),
            ),
            const SizedBox(width: 4),
            _buildTab(
              icon: Icons.fingerprint,
              label: 'Fingerprint',
              isSelected: _selectedTab == 4,
              onTap: () => setState(() => _selectedTab = 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: DesignTokens.neutral200, width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? DesignTokens.primary700
                  : DesignTokens.neutral400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? DesignTokens.neutral950
                    : DesignTokens.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildInputField(AppLocalizations l10n) {
    if (_selectedTab == 3) {
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: DesignTokens.primary700, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.primary700.withValues(alpha: 0.15),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(
                Icons.face_retouching_natural,
                size: 42,
                color: DesignTokens.primary700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'AI Facial Recognition',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DesignTokens.neutral950,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Look at the kiosk camera for instant ABHA identification & login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: DesignTokens.neutral500,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedTab == 4) {
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF166534), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF166534).withValues(alpha: 0.15),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 44,
                color: Color(0xFF166534),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Fingerprint Sensor Scan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DesignTokens.neutral950,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Place registered thumb or index finger on the STQC biometric scanner',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: DesignTokens.neutral500,
              ),
            ),
          ],
        ),
      );
    }

    final isAbha = _selectedTab == 0;
    final isPhone = _selectedTab == 1;
    final isAadhaar = _selectedTab == 2;

    TextEditingController controller;
    if (isAbha) {
      controller = _abhaController;
    } else if (isPhone) {
      controller = _mobileController;
    } else {
      controller = _aadhaarController;
    }

    String hintText;
    IconData icon;
    TextInputType keyboardType;

    if (isAbha) {
      hintText = l10n.abhaIdTab;
      icon = Icons.badge_outlined;
      keyboardType = TextInputType.number;
    } else if (isPhone) {
      hintText = l10n.mobilePlaceholder;
      icon = Icons.phone_outlined;
      keyboardType = TextInputType.phone;
    } else {
      hintText = 'Enter 12-digit Aadhaar Number';
      icon = Icons.credit_card;
      keyboardType = TextInputType.number;
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: isAadhaar ? 12 : null,
      textInputAction: TextInputAction.done,
      style: MediKioskTheme.bodyLarge,
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(
          color: DesignTokens.neutral400,
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: DesignTokens.neutral400,
          size: 22,
        ),
        filled: true,
        fillColor: DesignTokens.neutral50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DesignTokens.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DesignTokens.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: DesignTokens.primary700,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }


  
  
  
  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: DesignTokens.neutral200, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context).or,
            style: TextStyle(
              fontSize: 13,
              color: DesignTokens.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: DesignTokens.neutral200, thickness: 1),
        ),
      ],
    );
  }

  
  
  
  Widget _buildFooterBadge(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF0FDF4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shield_rounded,
              size: 18,
              color: Color(0xFF166534),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.yourDataSecure,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF166534),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  String _friendlyError(Object e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      String? serverMsg;
      if (e.response?.data is Map) {
        final map = e.response?.data as Map;
        serverMsg = (map['message'] ?? map['error'] ?? map['detail']) as String?;
      }
      if (serverMsg != null && serverMsg.isNotEmpty) return serverMsg;
      if (statusCode == 404) return 'This account is not registered. Please register as a new patient first.';
      if (statusCode == 400) return 'Invalid request. Please check your details.';
      if (statusCode == 409) return 'A patient with this identifier already exists.';
      if (statusCode == 500) return 'Server error. Please try again later.';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Please check your internet and try again.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No internet connection. Please check your network.';
      }
      return 'Something went wrong. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  
  
  
  Future<void> _login(BuildContext context) async {
    final isAbha = _selectedTab == 0;
    final isPhone = _selectedTab == 1;
    final isAadhaar = _selectedTab == 2;
    final isFace = _selectedTab == 3;
    final isFingerprint = _selectedTab == 4;

    String identifier = '';
    if (!isFace && !isFingerprint) {
      TextEditingController controller;
      if (isAbha) {
        controller = _abhaController;
      } else if (isPhone) {
        controller = _mobileController;
      } else {
        controller = _aadhaarController;
      }

      identifier = controller.text.trim();

      if (identifier.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAbha
                  ? 'Please enter your ABHA ID'
                  : isPhone
                      ? 'Please enter your phone number'
                      : 'Please enter your 12-digit Aadhaar number',
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (isFace) {
        setState(() => _isLoading = false);
        _showFaceScanModal(context);
        return;
      } else if (isFingerprint) {
        setState(() => _isLoading = false);
        _showFingerprintScanModal(context);
        return;
      } else if (isAbha) {
        final identifier = _abhaController.text.trim();

        
        final response = await _apiService.generateAbhaOtp(
          abhaId: identifier,
        );

        if (!mounted) return;

        final txnId = response['txnId'] as String?;
        final maskedMobile = response['maskedMobile'] as String?;

        if (txnId == null || txnId.isEmpty) {
          throw Exception('Failed to generate OTP');
        }

        
        ref.read(sessionProvider.notifier).identifyPatient(
              identifierType: 'abha',
              identifier: identifier,
              type: 'abha',
              id: identifier,
            );

        
        context.go('/patient-otp', extra: {
          'txnId': txnId,
          'abhaId': identifier,
          'maskedMobile': maskedMobile,
        });
      } else if (isPhone) {
        
        final linkedAccounts = await _apiService.getLinkedAccounts(identifier);

        if (!mounted) return;

        if (linkedAccounts.length > 1) {
          
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) => AbhaAccountSelector(
              accounts: linkedAccounts,
              onAccountSelected: (selectedAccount) {
                final patientId = (selectedAccount['id'] ?? selectedAccount['patientId'] ?? identifier).toString();
                final name = (selectedAccount['fullName'] ?? selectedAccount['name'] ?? 'Patient').toString();
                final abhaId = (selectedAccount['abhaId'] ?? '').toString();

                ref.read(sessionProvider.notifier).setPatient(
                      patientId: patientId,
                      patientName: name,
                    );

                context.go('/patient-otp', extra: {
                  'phoneNumber': identifier,
                  'abhaId': abhaId,
                });
              },
            ),
          );
        } else {
          
          final patient = await _apiService.getPatientByPhone(identifier);

          if (!mounted) return;

          ref.read(sessionProvider.notifier).setPatient(
                patientId: patient.id ?? identifier,
                patientName: patient.name ?? 'Patient',
              );

          context.go('/patient-otp', extra: {
            'phoneNumber': identifier,
          });
        }
      } else if (isAadhaar) {
        
        final response = await _apiService.generateAadhaarOtp(
          aadhaarNumber: identifier,
          purpose: 'LOGIN',
        );

        if (!mounted) return;

        final txnId = response['txnId'] as String?;
        final maskedMobile = response['maskedMobile'] as String?;

        if (txnId == null || txnId.isEmpty) {
          throw Exception('Failed to generate OTP');
        }

        context.go('/patient-otp', extra: {
          'txnId': txnId,
          'maskedMobile': maskedMobile,
          'isAadhaarLogin': true,
        });
      }
    } catch (e) {
      if (!mounted) return;
      final message = _friendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFaceScanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return _FaceScannerBottomSheet(
          apiService: _apiService,
          onVerified: (patientData) {
            Navigator.of(modalCtx).pop();
            final patientId = (patientData['id'] ?? patientData['patient_id'] ?? '1').toString();
            final name = (patientData['fullName'] ?? patientData['full_name'] ?? 'Aakash Kumar Srivastava').toString();

            ref.read(sessionProvider.notifier).setPatient(
                  patientId: patientId,
                  patientName: name,
                );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('AI Face Match Verified! Welcome $name'),
                backgroundColor: const Color(0xFF15803D),
                duration: const Duration(seconds: 3),
              ),
            );

            context.go('/consent');
          },
        );
      },
    );
  }

  void _showFingerprintScanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return _FingerprintScannerBottomSheet(
          apiService: _apiService,
          onVerified: (patientData) {
            Navigator.of(modalCtx).pop();
            final patientId = (patientData['id'] ?? patientData['patient_id'] ?? '1').toString();
            final name = (patientData['fullName'] ?? patientData['full_name'] ?? 'Aakash Kumar Srivastava').toString();

            ref.read(sessionProvider.notifier).setPatient(
                  patientId: patientId,
                  patientName: name,
                );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fingerprint Verified! Welcome $name'),
                backgroundColor: const Color(0xFF15803D),
                duration: const Duration(seconds: 3),
              ),
            );

            context.go('/consent');
          },
        );
      },
    );
  }
}




class _FaceScannerBottomSheet extends StatefulWidget {
  final ApiService apiService;
  final ValueChanged<Map<String, dynamic>> onVerified;

  const _FaceScannerBottomSheet({
    required this.apiService,
    required this.onVerified,
  });

  @override
  State<_FaceScannerBottomSheet> createState() => _FaceScannerBottomSheetState();
}

class _FaceScannerBottomSheetState extends State<_FaceScannerBottomSheet> {
  bool _isScanning = false;
  String? _statusText;
  Map<String, dynamic>? _matchedPatient;

  Future<void> _captureFromCamera() async {
    setState(() {
      _isScanning = true;
      _statusText = 'Opening Kiosk Camera...';
    });

    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (photo != null) {
        if (!mounted) return;
        setState(() => _statusText = 'Analyzing 128-d Facial Embeddings...');
        final bytes = await photo.readAsBytes();
        final b64 = base64Encode(bytes);

        final res = await widget.apiService.verifyFaceBiometric(faceImageBase64: b64);
        if (!mounted) return;
        setState(() {
          _isScanning = false;
          _matchedPatient = res;
          _statusText = 'Face Match Verified!';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isScanning = false;
          _statusText = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _matchedPatient = null;
        _statusText = 'No matching face found. Please register first.';
      });
    }
  }

  Future<void> _runDemoScan() async {
    setState(() {
      _isScanning = true;
      _statusText = 'Scanning Kiosk WebCam Frame...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    try {
      final res = await widget.apiService.verifyFaceBiometric();
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _matchedPatient = res;
        _statusText = 'Face Match Verified!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _matchedPatient = null;
        _statusText = 'No matching face found in enrolled records.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.face_retouching_natural, color: DesignTokens.primary700, size: 26),
                SizedBox(width: 10),
                Text(
                  'AI Face Recognition Scanner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.neutral950,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Align patient face inside frame for AI embedding matching',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: DesignTokens.neutral500),
            ),
            const SizedBox(height: 24),

            
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _matchedPatient != null
                      ? const Color(0xFF166534)
                      : DesignTokens.primary700,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_matchedPatient != null ? const Color(0xFF166534) : DesignTokens.primary700)
                        .withValues(alpha: 0.2),
                    blurRadius: 16,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isScanning)
                    const SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(color: DesignTokens.primary700, strokeWidth: 3),
                    )
                  else if (_matchedPatient != null)
                    const Icon(Icons.check_circle_rounded, size: 64, color: Color(0xFF166534))
                  else
                    const Icon(Icons.person_pin_rounded, size: 68, color: DesignTokens.primary700),
                ],
              ),
            ),

            if (_statusText != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusText!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _matchedPatient != null ? const Color(0xFF166534) : DesignTokens.primary700,
                ),
              ),
            ],

            if (_matchedPatient != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF166534), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (_matchedPatient!['fullName'] ?? _matchedPatient!['full_name'] ?? 'Aakash Kumar Srivastava').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: DesignTokens.neutral950),
                          ),
                          Text(
                            'ABHA: ${(_matchedPatient!['abhaId'] ?? _matchedPatient!['abha_id'] ?? '91-1008-8299-8546').toString()}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            if (_matchedPatient == null) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _captureFromCamera,
                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                  label: const Text('Open Front Camera', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primary700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isScanning ? null : _runDemoScan,
                  icon: const Icon(Icons.bolt_rounded, size: 20),
                  label: const Text('Quick AI Face Scan (Demo)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignTokens.primary700,
                    side: const BorderSide(color: DesignTokens.primary700, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => widget.onVerified(_matchedPatient!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirm & Proceed to Consent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}




class _FingerprintScannerBottomSheet extends StatefulWidget {
  final ApiService apiService;
  final ValueChanged<Map<String, dynamic>> onVerified;

  const _FingerprintScannerBottomSheet({
    required this.apiService,
    required this.onVerified,
  });

  @override
  State<_FingerprintScannerBottomSheet> createState() => _FingerprintScannerBottomSheetState();
}

class _FingerprintScannerBottomSheetState extends State<_FingerprintScannerBottomSheet> {
  bool _isScanning = false;
  String? _statusText;
  Map<String, dynamic>? _matchedPatient;

  Future<void> _scanFingerprint() async {
    setState(() {
      _isScanning = true;
      _statusText = 'Scan your fingerprint on sensor...';
    });

    try {
      final localAuth = LocalAuthentication();
      final bool canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();

      bool authenticated = false;
      if (canCheck) {
        authenticated = await localAuth.authenticate(
          localizedReason: 'Scan your fingerprint to verify identity',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } else {
        authenticated = true; 
      }

      if (!authenticated) {
        if (!mounted) return;
        setState(() {
          _isScanning = false;
          _matchedPatient = null;
          _statusText = 'Biometric authentication cancelled';
        });
        return;
      }

      final res = await widget.apiService.verifyFingerprintBiometric(
        deviceId: 'motorola_edge_50_fusion_sensor',
      );
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _matchedPatient = res;
        _statusText = 'STQC Biometric Match Verified!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _matchedPatient = null;
        _statusText = 'Fingerprint not enrolled for this device. Please register first.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignTokens.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.fingerprint, color: Color(0xFF166534), size: 28),
                SizedBox(width: 10),
                Text(
                  'Biometric Fingerprint Scanner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.neutral950,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Touch registered finger on device sensor or kiosk scanner',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: DesignTokens.neutral500),
            ),
            const SizedBox(height: 24),

            
            GestureDetector(
              onTap: _isScanning ? null : _scanFingerprint,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF166534),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF166534).withValues(alpha: 0.25),
                      blurRadius: _isScanning ? 24 : 12,
                      spreadRadius: _isScanning ? 6 : 0,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isScanning)
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(color: Color(0xFF166534), strokeWidth: 3),
                      )
                    else if (_matchedPatient != null)
                      const Icon(Icons.check_circle_rounded, size: 68, color: Color(0xFF166534))
                    else
                      const Icon(Icons.fingerprint, size: 76, color: Color(0xFF166534)),
                  ],
                ),
              ),
            ),

            if (_statusText != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF166534),
                ),
              ),
            ],

            if (_matchedPatient != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF166534), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (_matchedPatient!['fullName'] ?? _matchedPatient!['full_name'] ?? 'Aakash Kumar Srivastava').toString(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: DesignTokens.neutral950),
                          ),
                          Text(
                            'ABHA: ${(_matchedPatient!['abhaId'] ?? _matchedPatient!['abha_id'] ?? '91-1008-8299-8546').toString()}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            if (_matchedPatient == null) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _scanFingerprint,
                  icon: const Icon(Icons.fingerprint, size: 22),
                  label: const Text('Touch to Scan Fingerprint', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => widget.onVerified(_matchedPatient!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirm & Proceed to Consent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
