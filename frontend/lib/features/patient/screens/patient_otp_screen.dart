import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/services/api_service.dart';


class PatientOtpScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? abhaId;
  final String? txnId;
  final String? maskedMobile;
  final bool isAadhaarLogin;

  const PatientOtpScreen({
    super.key,
    this.phoneNumber,
    this.abhaId,
    this.txnId,
    this.maskedMobile,
    this.isAadhaarLogin = false,
  });

  @override
  ConsumerState<PatientOtpScreen> createState() => _PatientOtpScreenState();
}

class _PatientOtpScreenState extends ConsumerState<PatientOtpScreen> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  int _resendCountdown = 28;
  Timer? _timer;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 28);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onVerify() async {
    final otp = _currentOtp;
    if (otp.length < _otpLength) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.otpEnterFull),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    final txnId = widget.txnId;
    final abhaId = widget.abhaId;

    if (widget.isAadhaarLogin && txnId != null) {
      
      setState(() => _isLoading = true);
      try {
        final response = await _apiService.verifyAadhaarOtp(
          txnId: txnId,
          otp: otp,
        );

        if (!mounted) return;

        final patientData = response['patient'] as Map<String, dynamic>?;
        if (patientData != null) {
          final patientId = (patientData['id'] ?? '').toString();
          final fullName = (patientData['fullName'] ?? 'Patient').toString();

          ref.read(sessionProvider.notifier).setPatient(
                patientId: patientId,
                patientName: fullName,
              );
        }

        context.go('/consent');
      } catch (e) {
        if (!mounted) return;
        final msg = _friendlyError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      return;
    }

    if (txnId == null || abhaId == null) {
      
      if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
        
        if (!mounted) return;
        context.go('/consent');
        return;
      }

      
      if (!mounted) return;
      context.go('/identify');
      return;
    }

    setState(() => _isLoading = true);

    try {
      
      final response = await _apiService.verifyAbhaOtp(
        txnId: txnId,
        otp: otp,
        abhaId: abhaId,
      );

      if (!mounted) return;

      
      final patientId = response['id'] as String?;
      final fullName = response['fullName'] as String?;

      ref.read(sessionProvider.notifier).setPatient(
            patientId: patientId ?? abhaId,
            patientName: fullName ?? 'Patient',
          );

      
      context.go('/consent');
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final msg = _friendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.otpVerificationFailed(msg)),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onResendOtp() async {
    if (_resendCountdown > 0) return;

    final abhaId = widget.abhaId;
    if (abhaId == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.generateAbhaOtp(abhaId: abhaId);
      if (!mounted) return;

      final newMaskedMobile = response['maskedMobile'] as String?;
      _startTimer();

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newMaskedMobile != null
                ? l10n.otpSentSuccess(newMaskedMobile)
                : l10n.otpSentGeneric,
          ),
          backgroundColor: const Color(0xFF0F8B8D),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final msg = _friendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.otpResendFailed(msg)),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  
  
  
  String _friendlyError(Object e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      final serverMsg = e.response?.data is Map
          ? (e.response?.data as Map)['message'] as String?
          : null;
      if (serverMsg != null && serverMsg.isNotEmpty) return serverMsg;
      if (statusCode == 404) return 'This ABHA ID is not registered. Please register as a new patient first.';
      if (statusCode == 400) return 'Invalid OTP. Please check and try again.';
      if (statusCode == 409) return 'A patient with this ABHA ID already exists.';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final String displayId = widget.maskedMobile ??
        widget.phoneNumber ??
        widget.abhaId ??
        '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F7F7).withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFDEF2F2).withValues(alpha: 0.4),
                ),
              ),
            ),

            
            Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/identify');
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1E293B),
                          size: 24,
                        ),
                      ),
                      
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'For a',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'Healthier',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                              height: 1.2,
                            ),
                          ),
                          Text(
                            'Tomorrow',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          SizedBox(
                            width: 36,
                            child: Divider(
                              color: Color(0xFF0F8B8D),
                              thickness: 2,
                              height: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF0F8B8D),
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Text(
                                    'M',
                                    style: TextStyle(
                                      color: Color(0xFF0F8B8D),
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Transform.rotate(
                                      angle: 0,
                                      child: const Icon(
                                        Icons.add,
                                        color: Color(0xFFE53E3E),
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Medi',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Kiosk',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F8B8D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Smarter History. Better Care.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 28),

                        
                        SizedBox(
                          width: 200,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              
                              Container(
                                width: 170,
                                height: 170,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFE6F4F4),
                                ),
                              ),
                              
                              Positioned(
                                top: 40,
                                child: Container(
                                  width: 130,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF139A9C),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              
                              Positioned(
                                top: 25,
                                child: Container(
                                  width: 110,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star,
                                          size: 16,
                                          color: Color(0xFF139A9C)),
                                      SizedBox(width: 4),
                                      Icon(Icons.star,
                                          size: 16,
                                          color: Color(0xFF139A9C)),
                                      SizedBox(width: 4),
                                      Icon(Icons.star,
                                          size: 16,
                                          color: Color(0xFF139A9C)),
                                    ],
                                  ),
                                ),
                              ),
                              
                              Positioned(
                                top: 62,
                                child: CustomPaint(
                                  size: const Size(130, 45),
                                  painter: _EnvelopeFlapPainter(),
                                ),
                              ),
                              
                              Positioned(
                                bottom: 20,
                                right: 32,
                                child: Container(
                                  width: 44,
                                  height: 48,
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0D7A7C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F8B8D),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        
                        Text(
                          l10n.otpVerifyYourAccount,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayId.isNotEmpty
                              ? l10n.otpSentTo(displayId)
                              : l10n.otpSentToNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _otpLength,
                            (index) => _buildOtpBox(index),
                          ),
                        ),

                        const SizedBox(height: 28),

                        
                        Text(
                          l10n.otpDidntReceive,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _resendCountdown == 0 ? _onResendOtp : null,
                          child: Text(
                            _resendCountdown > 0
                                ? l10n.otpResendIn(_resendCountdown)
                                : l10n.otpResendNow,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _resendCountdown == 0
                                  ? const Color(0xFF0F8B8D)
                                  : const Color(0xFF0F8B8D),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFF1F5F9),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDF3F3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF0F8B8D),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.otpSecureInfo,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.otpSecureDetail,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _onVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF067A82),
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
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.otpVerifyContinue,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final isFirst = index == 0;
    return Flexible(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        constraints: const BoxConstraints(maxWidth: 44),
        height: 52,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isFirst
                ? const Color(0xFF0F8B8D)
                : const Color(0xFF0F172A),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isFirst && _controllers[index].text.isNotEmpty
                    ? const Color(0xFF0F8B8D)
                    : const Color(0xFFE2E8F0),
                width: isFirst ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0F8B8D),
                width: 2.0,
              ),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < _otpLength - 1) {
                _focusNodes[index + 1].requestFocus();
              } else {
                _focusNodes[index].unfocus();
              }
            } else {
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            }
            setState(() {});
          },
        ),
      ),
    );
  }
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F8B8D)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}