import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/patient_queue_detail_response.dart';
import '../providers/patient_detail_provider.dart';

class PatientQueueDetailScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  final String? patientName;
  final String? abhaId;
  final String? token;

  const PatientQueueDetailScreen({
    super.key,
    this.sessionId,
    this.patientName,
    this.abhaId,
    this.token,
  });

  @override
  ConsumerState<PatientQueueDetailScreen> createState() =>
      _PatientQueueDetailScreenState();
}

class _PatientQueueDetailScreenState extends ConsumerState<PatientQueueDetailScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.sessionId == null || widget.sessionId!.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Expanded(
                child: Center(
                  child: Text('Invalid session ID'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final async = ref.watch(patientDetailProvider(widget.sessionId!));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: async.when(
                data: (data) => _buildContent(data),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0B6B6A)),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        const Text(
                          'Could not load patient queue details.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(patientDetailProvider(widget.sessionId!)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B6B6A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PatientQueueDetailResponse data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdentityCard(data),
          _buildIntakeStatusCard(data),
          if (data.hasRedFlag && data.redFlagSymptoms.isNotEmpty)
            _buildRedFlagSection(data.redFlagSymptoms),
          if (data.drugInteractionWarnings.isNotEmpty)
            _buildDrugInteractionSection(data.drugInteractionWarnings),
          const SizedBox(height: 24),
          _buildActionButtons(data),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0B6B6A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/doctor-dashboard'),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('M', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('MediKiosk', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
              ),
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://ui-avatars.com/api/?name=Dr.+Arjun&background=0F9FA8&color=fff&size=128'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(PatientQueueDetailResponse data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0F5F5),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(data.patientName)}'
                      '&background=0F9FA8&color=fff&size=128',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.patientName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A2332)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ABHA: ${data.abhaId.isNotEmpty ? data.abhaId : "Not linked"}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: data.priority == 'HIGH' ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.priority == 'HIGH' ? 'HIGH PRIORITY' : 'NORMAL PRIORITY',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B6B6A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.sessionType == 'AYUSH' ? 'AYUSH' : 'General',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.language,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                data.tokenNumber,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
              ),
              const Spacer(),
              Text(
                '${data.age} yrs • ${data.gender}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeStatusCard(PatientQueueDetailResponse data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Intake Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2332))),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                data.consentGranted ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: data.consentGranted ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              Text(
                data.consentGranted ? 'Consent Granted' : 'Consent Not Granted',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: data.consentGranted ? const Color(0xFF166534) : const Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          if (data.sessionType == 'AYUSH' && data.prakritiBadge.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Prakriti: ${data.prakritiBadge}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRedFlagSection(List<String> symptoms) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF87171)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('Red Flag Symptoms Detected', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF991B1B))),
            ],
          ),
          const SizedBox(height: 10),
          ...symptoms.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDrugInteractionSection(List<String> warnings) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medication_liquid_rounded, size: 20, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('Drug Interaction Warnings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
            ],
          ),
          const SizedBox(height: 10),
          ...warnings.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold)),
                Expanded(child: Text(w, style: const TextStyle(fontSize: 13, color: Color(0xFF78350F)))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PatientQueueDetailResponse data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          context.push('/patient-clinical-view', extra: {
            'sessionId': data.sessionId,
            'patientName': data.patientName,
            'abhaId': data.abhaId,
            'token': data.tokenNumber,
            'patientId': data.patientId,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B6B6A),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Open Clinical Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
    );
  }
}