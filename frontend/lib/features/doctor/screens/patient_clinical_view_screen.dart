import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/patient_clinical_view_response.dart';
import '../../../models/doctor_portal_responses.dart';
import '../providers/clinical_view_provider.dart';
import '../providers/doctor_dashboard_provider.dart';
import '../providers/doctor_screen_providers.dart';
import '../../patient/widgets/documents_tab_widget.dart';

class PatientClinicalViewScreen extends ConsumerStatefulWidget {
  final String? sessionId;
  final String? patientId;
  final String? patientName;
  final String? abhaId;
  final String? token;

  const PatientClinicalViewScreen({
    super.key,
    this.sessionId,
    this.patientId,
    this.patientName,
    this.abhaId,
    this.token,
  });

  @override
  ConsumerState<PatientClinicalViewScreen> createState() =>
      _PatientClinicalViewScreenState();
}

class _PatientClinicalViewScreenState
    extends ConsumerState<PatientClinicalViewScreen> {
  int _selectedTab = 3; 
  int _selectedNav = 1; 

  
  
  
  PatientClinicalViewResponse? _view;

  @override
  Widget build(BuildContext context) {
    String? sessionId = widget.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      final dashboardAsync = ref.watch(doctorDashboardProvider);
      final queue = dashboardAsync.valueOrNull?.patientQueue ?? const [];
      if (queue.isNotEmpty) {
        final item = queue.firstWhere(
          (p) => p.isRedFlag == true,
          orElse: () => queue.first,
        );
        sessionId = item.sessionId;
      }
    }

    if (sessionId != null && sessionId.isNotEmpty) {
      final activeSessionId = sessionId;
      final async = ref.watch(clinicalViewProvider(activeSessionId));
      _view = async.valueOrNull;

      if (async.isLoading && _view == null) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F8),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF0B6B6A)),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      }

      if (async.hasError && _view == null) {
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
                          const Text(
                            'Could not load this patient\'s clinical record.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.invalidate(clinicalViewProvider(activeSessionId)),
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
                    _buildQuickInfo(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildRedFlagScreeningCard(),
                    ),
                    _buildTabBar(),
                    _buildTabContent(),
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

  
  
  String get _patientName =>
      _view?.patientName ?? widget.patientName ?? 'Patient';

  String get _abhaId => (_view?.abhaId.isNotEmpty ?? false)
      ? _view!.abhaId
      : (widget.abhaId ?? 'Not linked');

  
  
  
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
            width: 32,
            height: 32,
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
                onPressed: () => context.push('/red-flag-alert', extra: {'sessionId': widget.sessionId}),
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

  
  
  
  Widget _buildPatientInfoCard() {
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
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_patientName)}'
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
                      _patientName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A2332)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ABHA: $_abhaId',
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
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _view != null && (_view!.prakritiSnapshot.isNotEmpty) ? 'AYUSH' : 'General',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
              Text(
                'OPD Token: ${widget.token ?? '#1024'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (_view?.ageGenderAbha != null && _view!.ageGenderAbha.isNotEmpty)
                      ? _view!.ageGenderAbha
                      : '—',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/edit-clinical-summary', extra: {
                      'sessionId': widget.sessionId,
                      'patientName': _patientName,
                      'abhaId': _abhaId,
                    });
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF0B6B6A)),
                  label: const Text(
                    'Edit Summary',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0B6B6A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFF0B6B6A)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/consultation-notes', extra: {
                      'sessionId': widget.sessionId,
                      'patientName': _patientName,
                      'abhaId': _abhaId,
                    });
                  },
                  icon: const Icon(Icons.description_outlined, size: 16, color: Colors.white),
                  label: const Text(
                    'Consultation Rx',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6B6A),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildQuickInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 48,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _view?.consentStatusBanner.isNotEmpty == true ? _view!.consentStatusBanner : 'Consent: Granted',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, size: 14, color: Color(0xFF22C55E)),
                    ],
                  ),
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B6B6A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _view != null
                      ? (_view!.prakritiSnapshot.isNotEmpty ? 'Session: AYUSH' : 'Session: General OPD')
                      : 'Session: OPD',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTabBar() {
    final tabs = [
      _TabData(Icons.description_outlined, 'Medical History'),
      _TabData(Icons.favorite_border_rounded, 'Vitals'),
      _TabData(Icons.chat_bubble_outline_rounded, 'Complaints'),
      _TabData(Icons.spa_rounded, 'Ayush Data'),
      _TabData(Icons.folder_outlined, 'Documents'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0B6B6A) : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tabs[i].icon,
                      size: 20,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0B6B6A) : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    Container(
                      height: 2,
                      width: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B6B6A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  else
                    const SizedBox(height: 2),
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
    
    
    final List<Widget> body;
    switch (_selectedTab) {
      case 0:
        body = [
          _buildListCard(
            'Past Medical History',
            Icons.description_outlined,
            _view?.pastMedicalHistory.isNotEmpty == true
                ? _view!.pastMedicalHistory
                : (_view?.familyHistory ?? const []),
            emptyText: 'No past history captured at the kiosk.',
          ),
          const SizedBox(height: 12),
          _buildListCard(
            'Current Medications',
            Icons.medication_outlined,
            _view?.currentMedications ?? const [],
            emptyText: 'No medications reported.',
          ),
          const SizedBox(height: 12),
          _buildListCard(
            'Allergies',
            Icons.warning_amber_rounded,
            _view?.allergies ?? const [],
            emptyText: 'No known allergies reported.',
            isCritical: true,
          ),
          if (_view?.familyHistory.isNotEmpty == true &&
              _view?.pastMedicalHistory.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _buildListCard(
              'Family History',
              Icons.people_outline_rounded,
              _view!.familyHistory,
              emptyText: 'No family history reported.',
            ),
          ],
        ];
        break;
      case 1:
        body = [_buildVitalsCard()];
        break;
      case 2:
        body = [
          _buildListCard('Chief Complaints', Icons.chat_bubble_outline_rounded,
              _view?.chiefComplaints ?? const [],
              emptyText: 'The patient has not completed the interview yet.'),
          const SizedBox(height: 12),
          _buildRedFlagScreeningCard(),
        ];
        break;
      case 4:
        body = [DocumentsTabWidget(sessionId: widget.sessionId)];
        break;
      default:
        body = [
          _buildAyushAssessmentCard(),
          const SizedBox(height: 12),
          _buildDrugInteractionCard(),
          const SizedBox(height: 12),
          _buildRedFlagScreeningCard(),
          const SizedBox(height: 12),
          _buildKioskProgressCard(),
        ];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        children: [
          ...body,
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  
  
  Widget _buildVitalsCard() {
    final vitals = _view?.vitalsGrid ?? const <String, String>{};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite_border_rounded, size: 18, color: Color(0xFF0B6B6A)),
              SizedBox(width: 8),
              Text('Vitals',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2332))),
            ],
          ),
          const SizedBox(height: 12),
          if (vitals.isEmpty)
            const Text('No vitals recorded for this session.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: vitals.entries.map((e) {
                final measured = e.value != 'Not Checked';
                return Container(
                  width: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: measured ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: measured
                          ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.key,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      const SizedBox(height: 3),
                      Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: measured ? FontWeight.w700 : FontWeight.w400,
                          color: measured ? const Color(0xFF166534) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    String title,
    IconData icon,
    List<String> items, {
    required String emptyText,
    bool isCritical = false,
  }) {
    final accent = isCritical ? const Color(0xFFDC2626) : const Color(0xFF0B6B6A);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCritical && items.isNotEmpty
              ? accent.withValues(alpha: 0.4)
              : const Color(0xFFE5E7EB),
          width: isCritical && items.isNotEmpty ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2332))),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(emptyText, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))
          else
            ...items.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: TextStyle(color: accent)),
                      Expanded(
                        child: Text(t,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  
  
  
  Widget _buildAyushAssessmentCard() {
    final snapshot = _view?.prakritiSnapshot ?? '';
    final hasAyush = snapshot.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🌿', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('AYUSH Prakriti Assessment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2332))),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasAyush)
            const Text(
              'AYUSH assessment was not completed during this kiosk session (patient chose General OPD path).',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
              ),
              child: Text(
                snapshot,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'View Full AYUSH Report →',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0B6B6A)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(width: 6),
        Flexible(
          child: Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF374151))),
        ),
      ],
    );
  }

  
  
  
  Widget _buildDrugInteractionCard() {
    
    return const SizedBox.shrink();
  }

  
  
  
  Widget _buildRedFlagScreeningCard() {
    final sid = widget.sessionId;
    if (sid == null || sid.isEmpty) return const SizedBox.shrink();

    final alertAsync = ref.watch(doctorRedFlagProvider(sid));
    final alert = alertAsync.valueOrNull ?? const DoctorRedFlagAlert();

    final viewHasRedFlags =
        _view != null && (_view!.hasRedFlag || _view!.redFlags.isNotEmpty);
    final isFlagged = viewHasRedFlags || alert.hasFlags;
    final isCrit = alert.isCritical ||
        (viewHasRedFlags &&
            _view!.redFlags.any((f) {
              final lower = f.toLowerCase();
              return lower.contains('critical') ||
                  lower.contains('emergency') ||
                  lower.contains('severe') ||
                  lower.contains('high');
            }));

    final badgeColor = isCrit
        ? const Color(0xFFFEE2E2)
        : (isFlagged ? const Color(0xFFFEF3C7) : const Color(0xFFF0FDF4));
    final badgeTextColor = isCrit
        ? const Color(0xFFDC2626)
        : (isFlagged ? const Color(0xFFB45309) : const Color(0xFF166534));

    final flagCount = alert.hasFlags
        ? alert.allAlerts.length
        : (_view?.redFlags.length ?? 0);
    final badgeText = isFlagged
        ? '$flagCount Flag${flagCount == 1 ? '' : 's'} Active'
        : 'No Red Flags';

    final List<Widget> flagItems = [];
    if (_view?.redFlags.isNotEmpty == true) {
      for (final flag in _view!.redFlags) {
        final flagLower = flag.toLowerCase();
        final flagIsCrit = flagLower.contains('critical') ||
            flagLower.contains('emergency') ||
            flagLower.contains('severe') ||
            flagLower.contains('high');
        final dotColor =
            flagIsCrit ? const Color(0xFFDC2626) : const Color(0xFFF59E0B);
        final textColor =
            flagIsCrit ? const Color(0xFFDC2626) : const Color(0xFF92400E);
        flagItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(flag,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151)))),
                Text(flagIsCrit ? '(High Risk)' : '(Flagged)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
              ],
            ),
          ),
        );
      }
    } else if (alert.hasFlags) {
      for (final f in alert.detectedFlags) {
        final isCritFlag = f.severity.toUpperCase() == 'CRITICAL';
        final dotColor =
            isCritFlag ? const Color(0xFFDC2626) : const Color(0xFFF59E0B);
        final textColor =
            isCritFlag ? const Color(0xFFDC2626) : const Color(0xFF92400E);
        flagItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(f.symptom,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151)))),
                Text('(${f.severity ?? 'Unknown'})',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor)),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Red Flag Clinical Alerts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2332))),
              ),
              if (alertAsync.isLoading && _view == null)
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(badgeText,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor)),
                ),
            ],
          ),
          if (alert.hasFlags) ...[
            const SizedBox(height: 12),
            ...alert.allAlerts.map((f) {
              final isCrit = f.severity.toUpperCase() == 'CRITICAL';
              final cardBg = isCrit ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB);
              final borderColor = isCrit ? const Color(0xFFFCA5A5) : const Color(0xFFFCD34D);
              final textColor = isCrit ? const Color(0xFF991B1B) : const Color(0xFF92400E);
              final titleText = f.ruleName.isNotEmpty ? f.ruleName : (f.symptom.isNotEmpty ? f.symptom : 'Red Flag Alert');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isCrit ? Icons.warning_amber_rounded : Icons.info_outline,
                          color: textColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            titleText,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCrit ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            f.severity.isNotEmpty ? f.severity.toUpperCase() : 'HIGH',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (f.triggeredBy.isNotEmpty || f.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Triggered by: ${f.triggeredBy.isNotEmpty ? f.triggeredBy : f.description}',
                        style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.9)),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(color: borderColor),
                          ),
                        ),
                        onPressed: f.alertId.isEmpty
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final targetAlertId = f.alertId;
                                try {
                                  await ref.read(apiServiceProvider).acknowledgeRedFlagAlert(alertId: targetAlertId);
                                  ref.invalidate(doctorRedFlagProvider(sid));
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Red Flag Alert Acknowledged and Cleared'),
                                      backgroundColor: Color(0xFF0B6B6A),
                                    ),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to acknowledge alert: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.check_circle_outline, size: 14),
                        label: const Text('Acknowledge & Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else if (viewHasRedFlags) ...[
            const SizedBox(height: 12),
            ..._view!.redFlags.map((rf) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFF92400E), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rf, style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)))),
                ],
              ),
            )),
          ] else if (!alertAsync.isLoading) ...[
            const SizedBox(height: 8),
            const Text('No active red-flag symptoms detected during intake.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ],
        ],
      ),
    );
  }

  
  
  
  Widget _buildKioskProgressCard() {
    
    
    
    final allDone = _view != null;
    final steps = ['Registration', 'Consent', 'Interview', 'Documents', 'Summary'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kiosk Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2332))),
          const SizedBox(height: 12),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(steps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF22C55E)),
                  );
                }
                final stepIndex = i ~/ 2;
                return Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: allDone ? const Color(0xFFF0FDF4) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: allDone
                          ? const Color(0xFF22C55E).withValues(alpha: 0.3)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        steps[stepIndex],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: allDone ? const Color(0xFF166534) : const Color(0xFF9CA3AF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        allDone ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 10,
                        color: allDone ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  
  
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go('/ai-clinical-summary', extra: {
                'patientName': _patientName,
                'abhaId': _abhaId,
                'sessionId': widget.sessionId,
              });
            },
            icon: const Icon(Icons.description_rounded, size: 20),
            label: const Text('OPEN CLINICAL SUMMARY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B6B6A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        SizedBox(
          width: double.infinity, height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              context.go('/medical-timeline', extra: {
                'patientName': _patientName,
                'abhaId': _abhaId,
                'sessionId': widget.sessionId,
              });
            },
            icon: const Icon(Icons.schedule_rounded, size: 20),
            label: const Text('VIEW TIMELINE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B6B6A),
              side: const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', isSelected: _selectedNav == 0, onTap: () { setState(() => _selectedNav = 0); context.go('/doctor-dashboard'); }),
              _NavItem(icon: Icons.people_outline_rounded, label: 'Patients', isSelected: _selectedNav == 1, onTap: () => setState(() => _selectedNav = 1)),
              _NavItem(icon: Icons.notifications_outlined, label: 'Alerts', isSelected: _selectedNav == 2, onTap: () { setState(() => _selectedNav = 2); context.go('/red-flag-alert', extra: {'patientName': _patientName, 'abhaId': _abhaId, 'sessionId': widget.sessionId}); }, hasDot: true),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', isSelected: _selectedNav == 3, onTap: () => setState(() => _selectedNav = 3)),
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
  const _TabData(this.icon, this.label);
}




class _DonutSegment {
  final double value;
  final Color color;
  const _DonutSegment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  const _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;

    double startAngle = -3.14159 / 2; 

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}




class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasDot;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap, this.hasDot = false});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF0B6B6A) : const Color(0xFF9CA3AF);
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
                    top: 0, right: -2,
                    child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}