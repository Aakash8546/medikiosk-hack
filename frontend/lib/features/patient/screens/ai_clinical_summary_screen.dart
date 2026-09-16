import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/features/patient/providers/patient_provider.dart';

import '../../../models/doctor_portal_responses.dart';
import '../../doctor/providers/doctor_screen_providers.dart';

class AiClinicalSummaryScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? abhaId;

  
  
  final String? sessionId;

  const AiClinicalSummaryScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  ConsumerState<AiClinicalSummaryScreen> createState() =>
      _AiClinicalSummaryScreenState();
}

class _AiClinicalSummaryScreenState
    extends ConsumerState<AiClinicalSummaryScreen> {
  int _selectedNav = 1; 

  DoctorAiSummary? _summary;

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      final async = ref.watch(doctorAiSummaryProvider(sessionId));
      _summary = async.valueOrNull;
      if (async.isLoading && _summary == null) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF0B6B6A))),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      }
      if (async.hasError && _summary == null) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: Color(0xFFEF4444)),
                          const SizedBox(height: 12),
                          const Text('Could not load the AI summary.',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF374151))),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref
                                .invalidate(doctorAiSummaryProvider(sessionId)),
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
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientInfoCard(),
                    _buildTitleSection(),
                    _buildSummarySections(),
                    _buildDisclaimer(),
                    const SizedBox(height: 12),
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
            onPressed: () => context.go('/patient-summary', extra: {
              'patientName': widget.patientName,
              'abhaId': widget.abhaId,
            }),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('M',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('MediKiosk',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 24),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF4444), shape: BoxShape.circle),
                  child: const Center(
                      child: Text('3',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700))),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://ui-avatars.com/api/?name=Dr.+Arjun&background=0F9FA8&color=fff&size=128'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildPatientInfoCard() {
    final pState = ref.watch(patientProvider);
    final pName = _summary?.patientName.isNotEmpty == true
        ? _summary!.patientName
        : (widget.patientName ?? pState?.name ?? 'Patient');
    final pAbha = _summary?.abhaId.isNotEmpty == true
        ? _summary!.abhaId
        : (widget.abhaId ?? pState?.abhaId ?? 'Not linked');
    final avatarUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(pName)}&background=0F9FA8&color=fff&size=128';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0F5F5),
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
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
                  pName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ABHA / ID: $pAbha',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFCA5A5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('ATOD4',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF991B1B))),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('AI Clinical Summary ',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332))),
              const Text('✨', style: TextStyle(fontSize: 18)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  
                },
                child: const Text(
                  'View Full Transcript',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B6B6A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'AI-generated clinical notes for physician review.',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSummarySections() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          _SummarySection(
            number: '1',
            title: 'History of Present Illness',
            confidence: _conf(_summary?.hpiConfidence),
            confidenceColor: _confColor(_summary?.hpiConfidence),
            items: _summary != null
                ? [_summary!.hpiSummary]
                : const ['Summary not loaded.'],
            reviewed: false,
          ),
          const SizedBox(height: 12),

          
          
          _SummarySection(
            number: '2',
            title: 'Vital Signs',
            confidence: _conf(_summary?.vitalsConfidence),
            confidenceColor: _confColor(_summary?.vitalsConfidence),
            items: (_summary?.vitalsSummary.isNotEmpty ?? false)
                ? _summary!.vitalsSummary.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .toList()
                : const ['Not measured at the kiosk — record at consultation.'],
          ),
          const SizedBox(height: 12),

          
          _SummarySection(
            number: '3',
            title: 'Past Medical History',
            confidence: _conf(_summary?.pastHistoryConfidence),
            confidenceColor: _confColor(_summary?.pastHistoryConfidence),
            items: (_summary?.pastMedicalHistory.isNotEmpty ?? false)
                ? _summary!.pastMedicalHistory
                : const ['No past medical history recorded.'],
          ),
          const SizedBox(height: 14),

          
          _buildQuickStatsRow(),
          const SizedBox(height: 14),

          
          _SummarySection(
            number: '4',
            title: 'AYUSH Assessment Summary',
            confidence: _conf(_summary?.ayushConfidence),
            confidenceColor: _confColor(_summary?.ayushConfidence),
            items: _summary != null
                ? [
                    'Prakriti: ${_summary!.prakritiSummary}',
                    'Agni: ${_summary!.agniSummary}',
                    'Vikriti: ${_summary!.vikritiSummary}',
                    'Lifestyle: ${_summary!.lifestyleScore}',
                  ]
                : const ['AYUSH assessment not loaded.'],
          ),
          const SizedBox(height: 12),

          
          if (_summary == null || _summary!.drugInteractions.isNotEmpty)
            _SummarySection(
              number: '5',
              title: 'Drug Interaction Check',
              isAlert: true,
              items: _summary?.drugInteractions ??
                  const ['Interaction check not loaded.'],
            )
          else
            _SummarySection(
              number: '5',
              title: 'Drug Interaction Check',
              items: const ['No interactions found in the reported medications.'],
            ),
        ],
      ),
    );
  }

  
  
  String _conf(int? value) => (value == null || value == 0) ? '—' : '$value';

  Color _confColor(int? value) {
    if (value == null || value == 0) return const Color(0xFF9CA3AF);
    if (value >= 75) return const Color(0xFF059669);
    if (value >= 40) return const Color(0xFFE85D3A);
    return const Color(0xFFDC2626);
  }

  
  
  
  Widget _buildQuickStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickStatBadge(
              label: '${_summary?.totalMedications ?? 0} Medications',
              bgColor: const Color(0xFF0B6B6A),
              textColor: Colors.white),
          const SizedBox(width: 8),
          _QuickStatBadge(
              label: '${_summary?.totalAllergies ?? 0} Allergies',
              bgColor: (_summary?.totalAllergies ?? 0) > 0
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFE5E7EB),
              textColor: (_summary?.totalAllergies ?? 0) > 0
                  ? Colors.white
                  : const Color(0xFF374151)),
          const SizedBox(width: 8),
          _QuickStatBadge(
              label: '${_summary?.totalComplaints ?? 0} Complaints',
              bgColor: const Color(0xFF0B6B6A),
              textColor: Colors.white),
        ],
      ),
    );
  }

  
  
  
  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        _summary?.disclaimer.isNotEmpty == true
            ? _summary!.disclaimer
            : 'This is an AI-generated summary. Final clinical decisions must be made by the physician.',
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: Color(0xFF6B7280),
            height: 1.4),
      ),
    );
  }

  
  
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          
          
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/edit-clinical-summary', extra: {
                'patientName': widget.patientName,
                'abhaId': widget.abhaId,
                'sessionId': widget.sessionId,
              }),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'EDIT SUMMARY',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0B6B6A),
                side: const BorderSide(
                    color: Color(0xFF0B6B6A), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/doctor-confirmation', extra: {
                'patientName': widget.patientName,
                'abhaId': widget.abhaId,
                'sessionId': widget.sessionId,
              }),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text(
                'CONFIRM & PROCEED',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 10,
              offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Dashboard',
                  isSelected: _selectedNav == 0,
                  onTap: () {
                    setState(() => _selectedNav = 0);
                    context.go('/doctor-dashboard');
                  }),
              _NavItem(
                  icon: Icons.people_outline_rounded,
                  label: 'Patients',
                  isSelected: _selectedNav == 1,
                  onTap: () => setState(() => _selectedNav = 1)),
              _NavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Alerts',
                  isSelected: _selectedNav == 2,
                  onTap: () => setState(() => _selectedNav = 2),
                  hasDot: true),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: _selectedNav == 3,
                  onTap: () => setState(() => _selectedNav = 3)),
            ],
          ),
        ),
      ),
    );
  }
}




class _SummarySection extends StatelessWidget {
  final String number;
  final String title;
  final String? confidence;
  final Color? confidenceColor;
  final List<String> items;
  final bool reviewed;
  final bool isAlert;
  final String? extraLabel;

  const _SummarySection({
    required this.number,
    required this.title,
    this.confidence,
    this.confidenceColor,
    required this.items,
    this.reviewed = false,
    this.isAlert = false,
  }) : extraLabel = null;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isAlert ? const Color(0xFFF59E0B) : const Color(0xFF22C55E);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      children: [
                        Text(
                          '$number. $title',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2332)),
                        ),
                        const Spacer(),
                        if (isAlert)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    size: 12, color: Color(0xFFF59E0B)),
                                SizedBox(width: 3),
                                Text('Alert',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF92400E))),
                              ],
                            ),
                          )
                        else if (confidence != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Confidence $confidence%',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: confidenceColor),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    ...items.map((item) {
                      final isHighRisk = item.contains('HIGH RISK');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text('•',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF374151))),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: isHighRisk
                                  ? _buildHighRiskText(item)
                                  : Text(
                                      item,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF374151),
                                          height: 1.4),
                                    ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    if (reviewed) ...[
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Reviewed ✓',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF22C55E)),
                        ),
                      ),
                    ],
                    
                    if (extraLabel != null && !isAlert) ...[
                      const SizedBox(height: 4),
                      Text(
                        extraLabel!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                    if (extraLabel != null && isAlert) ...[
                      const SizedBox(height: 2),
                      Text(
                        extraLabel!,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighRiskText(String text) {
    
    final parts = text.split('HIGH RISK:');
    if (parts.length == 2) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
              height: 1.4),
          children: [
            TextSpan(text: parts[0]),
            const TextSpan(
              text: 'HIGH RISK:',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFDC2626)),
            ),
            TextSpan(text: parts[1]),
          ],
        ),
      );
    }
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
            height: 1.4));
  }
}




class _QuickStatBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _QuickStatBadge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor),
      ),
    );
  }
}




class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasDot;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color(0xFF0B6B6A) : const Color(0xFF9CA3AF);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (hasDot)
                  Positioned(
                    top: 0,
                    right: -2,
                    child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: color)),
          ],
        ),
      ),
    );
  }
}