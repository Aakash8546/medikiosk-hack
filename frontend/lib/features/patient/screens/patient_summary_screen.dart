import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medikiosk/features/doctor/providers/clinical_view_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/features/patient/widgets/vitals_grid_widget.dart';
import 'package:medikiosk/features/patient/widgets/chief_complaints_card.dart';
import 'package:medikiosk/features/patient/widgets/prakriti_snapshot_card.dart';
import 'package:medikiosk/features/patient/widgets/current_medications_card.dart';
import 'package:medikiosk/features/patient/widgets/family_history_card.dart';
import 'package:medikiosk/features/patient/widgets/allergies_banner.dart';
import 'package:medikiosk/features/patient/widgets/documents_tab_widget.dart';

class PatientSummaryScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? abhaId;

  
  
  final String? sessionId;

  const PatientSummaryScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  ConsumerState<PatientSummaryScreen> createState() =>
      _PatientSummaryScreenState();
}

class _PatientSummaryScreenState extends ConsumerState<PatientSummaryScreen> {
  int _selectedTab = 0; 
  int _selectedNav = 1; 

  
  Map<String, String> _vitals(WidgetRef ref) {
    final id = widget.sessionId;
    if (id == null || id.isEmpty) return const {};
    return ref.watch(clinicalViewProvider(id)).valueOrNull?.vitalsGrid ??
        const {};
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildConsentBanner(),
                    _buildTabBar(),
                    _buildTabContent(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomSummaryBar(),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0F5F5),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://ui-avatars.com/api/?name=Ramesh+Kumar&background=0F9FA8&color=fff&size=128'),
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
                  widget.patientName ?? 'Patient',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332)),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ATOD4',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ABHA: ${widget.abhaId ?? 'Not linked'}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildConsentBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: Color(0xFF22C55E)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'ABDM Consent Granted — Data sharing active until 03 Oct 2026',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF166534)),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTabBar() {
    final tabs = [
      _TabData(icon: Icons.description_outlined, label: 'Summary'),
      _TabData(icon: Icons.favorite_border_rounded, label: 'Vitals'),
      _TabData(icon: Icons.chat_bubble_outline_rounded, label: 'Complaints'),
      _TabData(icon: Icons.spa_rounded, label: 'AYUSH'),
      _TabData(icon: Icons.folder_outlined, label: 'Documents'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 14, 0, 0),
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
                  const SizedBox(height: 8),
                  
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0B6B6A)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tabs[i].icon,
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF0B6B6A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  
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

  
  
  
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: 
        return _buildSummaryTab();
      case 1: 
        return _buildVitalsTab();
      case 2: 
        return _buildComplaintsTab();
      case 3: 
        return _buildAyushTab();
      case 4: 
        return DocumentsTabWidget(sessionId: widget.sessionId);
      default:
        return _buildSummaryTab();
    }
  }

  Widget _buildSummaryTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Vitals Grid'),
          const SizedBox(height: 10),
          VitalsGridWidget(vitals: _vitals(ref)),
          const SizedBox(height: 16),
          _buildSectionHeader('Chief Complaints'),
          const SizedBox(height: 10),
          const ChiefComplaintsCard(),
          const SizedBox(height: 16),
          const PrakritiSnapshotCard(),
          const SizedBox(height: 16),
          _buildSectionHeader('Current Medications'),
          const SizedBox(height: 10),
          const CurrentMedicationsCard(),
          const SizedBox(height: 16),
          _buildSectionHeader('Family History'),
          const SizedBox(height: 10),
          const FamilyHistoryCard(),
          const SizedBox(height: 16),
          const AllergiesBanner(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Vitals Grid'),
          const SizedBox(height: 10),
          VitalsGridWidget(vitals: _vitals(ref)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Chief Complaints'),
          const SizedBox(height: 10),
          const ChiefComplaintsCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAyushTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PrakritiSnapshotCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2332)),
    );
  }

  
  
  
  Widget _buildBottomSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        child: Row(
          children: [
            Text(
              widget.patientName ?? 'Patient',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2332)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                context.go('/ai-clinical-summary', extra: {
                  'patientName': widget.patientName,
                  'abhaId': widget.abhaId,
                  'sessionId': widget.sessionId,
                });
              },
              child: const Text(
                'View Full AI Summary →',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B6B6A)),
              ),
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




class _TabData {
  final IconData icon;
  final String label;
  const _TabData({required this.icon, required this.label});
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