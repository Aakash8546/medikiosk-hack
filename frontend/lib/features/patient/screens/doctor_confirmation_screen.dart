import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/doctor_portal_responses.dart';
import '../../doctor/providers/doctor_screen_providers.dart';

class DoctorConfirmationScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? abhaId;

  
  
  final String? sessionId;

  const DoctorConfirmationScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  ConsumerState<DoctorConfirmationScreen> createState() =>
      _DoctorConfirmationScreenState();
}

class _DoctorConfirmationScreenState
    extends ConsumerState<DoctorConfirmationScreen> {
  int _selectedTab = 0; 
  int _selectedNav = 1; 

  DoctorConfirmation? _review;

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      final async = ref.watch(doctorConfirmationProvider(sessionId));
      _review = async.valueOrNull;
      if (async.isLoading && _review == null) {
        return const Scaffold(
          backgroundColor: Color(0xFFF4F6F8),
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0B6B6A))),
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    _buildPatientInfoCard(),
                    _buildTabBar(),
                    _buildAiSummaryBanner(),
                    _buildClinicalSections(),
                    _buildJudgmentCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
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
            onPressed: () => context.go('/doctor-dashboard'),
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
              child: Icon(Icons.add_rounded, color: Colors.white, size: 20),
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
                onPressed: () {
                  
                },
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
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 20),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doctor Confirmation',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review, confirm and save the clinical summary',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0B6B6A)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16, color: Color(0xFF0B6B6A)),
                SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time Saved',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280))),
                    Text('14:32 min',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B6B6A))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildPatientInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0F5F5),
              image: DecorationImage(
                image: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_patientName)}&background=0F9FA8&color=fff&size=128'),
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
                  _patientName,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332)),
                ),
                const SizedBox(height: 4),
                const Text(
                  '54 Y • Male • ABHA: XX-1234-5678-9012',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'OPD: General Medicine • Token: 1247',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_rounded,
                        size: 12, color: Color(0xFFDC2626)),
                    const SizedBox(width: 4),
                    const Text('HIGH PRIORITY',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFDC2626))),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Red Flags: 3',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTabBar() {
    final tabs = [
      _TabData(icon: Icons.description_outlined, label: 'Clinical Summary'),
      _TabData(icon: Icons.folder_outlined, label: 'Medical Documents'),
      _TabData(icon: Icons.schedule_rounded, label: 'Timeline'),
      _TabData(icon: Icons.monitor_heart_outlined, label: 'AI Health Summary'),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Icon(
                    tabs[i].icon,
                    size: 20,
                    color: isSelected
                        ? const Color(0xFF0B6B6A)
                        : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0B6B6A)
                          : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    Container(
                      height: 3,
                      width: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B6B6A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  else
                    const SizedBox(height: 3),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  
  
  
  Widget _buildAiSummaryBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 24, color: Color(0xFF22C55E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Generated Summary',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332))),
                const SizedBox(height: 2),
                const Text(
                    'Please review all sections carefully before confirming.',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280))),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0B6B6A)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined,
                    size: 14, color: Color(0xFF0B6B6A)),
                SizedBox(width: 4),
                Text('Edit Summary',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  String get _patientName =>
      (_review?.patientName.isNotEmpty ?? false)
          ? _review!.patientName
          : (widget.patientName ?? 'Patient');

  
  
  
  Widget _buildClinicalSections() {
    final r = _review;
    final sections = [
      _SectionData(
        icon: Icons.person_outline_rounded,
        iconBgColor: const Color(0xFFE0F5F5),
        iconColor: const Color(0xFF0B6B6A),
        title: 'Chief Complaint',
        subtitle: _orNone(r?.chiefComplaintSummary, 'No complaint captured'),
        isChecked: (r?.chiefComplaintSummary.isNotEmpty ?? false),
      ),
      _SectionData(
        icon: Icons.medication_outlined,
        iconBgColor: const Color(0xFFE0F5F5),
        iconColor: const Color(0xFF0B6B6A),
        title: 'Medications',
        subtitle: _joinOrNone(r?.prescribedMedications, 'None reported'),
        isChecked: (r?.prescribedMedications.isNotEmpty ?? false),
      ),
      _SectionData(
        icon: Icons.warning_amber_rounded,
        iconBgColor: const Color(0xFFFEF3C7),
        iconColor: const Color(0xFFD97706),
        title: 'Allergies',
        subtitle: _joinOrNone(r?.allergies, 'No known drug allergies'),
        isChecked: (r?.allergies.isNotEmpty ?? false),
        badge: (r?.allergies.isNotEmpty ?? false) ? '${r!.allergies.length}' : null,
        badgeColor: const Color(0xFFDC2626),
      ),
      _SectionData(
        icon: Icons.spa_rounded,
        iconBgColor: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF16A34A),
        title: 'AYUSH Assessment',
        subtitle: _orNone(r?.ayushAssessmentSummary, 'Not assessed'),
        isChecked: (r?.ayushAssessmentSummary.isNotEmpty ?? false),
      ),
      _SectionData(
        icon: Icons.dangerous_outlined,
        iconBgColor: const Color(0xFFFEE2E2),
        iconColor: const Color(0xFFDC2626),
        title: 'Drug Interactions',
        subtitle: _joinOrNone(
            r?.drugInteractionWarnings, 'No interactions found'),
        isChecked: false,
        badge: (r?.drugInteractionWarnings.isNotEmpty ?? false)
            ? '${r!.drugInteractionWarnings.length} found'
            : null,
        badgeColor: const Color(0xFFDC2626),
      ),
      _SectionData(
        icon: Icons.assignment_outlined,
        iconBgColor: const Color(0xFFFED7AA),
        iconColor: const Color(0xFFEA580C),
        title: 'ICD Codes',
        subtitle: _joinOrNone(
            r?.icdCodesConfirmed, 'Not yet coded — add on the notes screen'),
        isChecked: (r?.icdCodesConfirmed.isNotEmpty ?? false),
      ),
    ];

    return Column(
      children: sections.map((section) {
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _buildSectionRow(section),
        );
      }).toList(),
    );
  }

  static String _orNone(String? value, String fallback) =>
      (value == null || value.isEmpty) ? fallback : value;

  static String _joinOrNone(List<String>? values, String fallback) =>
      (values == null || values.isEmpty) ? fallback : values.join(' · ');

  Widget _buildSectionRow(_SectionData section) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: section.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(section.icon, size: 20, color: section.iconColor),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(section.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2332))),
                    if (section.badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: section.badgeColor!.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(section.badge!,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: section.badgeColor)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(section.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          if (section.isChecked)
            const Icon(Icons.check_circle,
                size: 20, color: Color(0xFF22C55E))
          else
            const SizedBox(width: 20),
          const SizedBox(width: 4),
          
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  
  
  
  Widget _buildJudgmentCard() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined,
              size: 24, color: Color(0xFF0B6B6A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Clinical Judgment Required',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332))),
                const SizedBox(height: 3),
                const Text(
                    'Please add, modify or remove any information as per your clinical evaluation.',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0B6B6A)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 14, color: Color(0xFF0B6B6A)),
                SizedBox(width: 4),
                Text('Add Note',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/consultation-notes', extra: {
                    'patientName': widget.patientName,
                    'abhaId': widget.abhaId,
                    'sessionId': widget.sessionId,
                  });
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CONFIRM & SAVE SUMMARY',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6B6A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  
                },
                icon: const Icon(Icons.content_paste_rounded, size: 18),
                label: const Text(
                  'SEND FOR REVIEW (SENIOR DOCTOR)',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B6B6A),
                  side: const BorderSide(
                      color: Color(0xFF0B6B6A), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 12, color: Color(0xFF9CA3AF)),
                SizedBox(width: 4),
                Text(
                  'All changes are securely logged with audit trail.',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ],
        ),
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
                  onTap: () {
                    setState(() => _selectedNav = 2);
                    context.go('/red-flag-alert', extra: {
                      'patientName': _patientName,
                      'abhaId': widget.abhaId ?? 'XX-1234-5678-9012',
                    });
                  },
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




class _TabData {
  final IconData icon;
  final String label;
  const _TabData({required this.icon, required this.label});
}




class _SectionData {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isChecked;
  final String? badge;
  final Color? badgeColor;

  const _SectionData({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isChecked,
    this.badge,
    this.badgeColor,
  });
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