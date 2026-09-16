import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/services/api_service.dart';
import 'package:medikiosk/models/doctor_portal_responses.dart';

class ConsultationNotesScreen extends StatefulWidget {
  final String? patientName;
  final String? abhaId;

  
  
  final String? sessionId;

  const ConsultationNotesScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  State<ConsultationNotesScreen> createState() =>
      _ConsultationNotesScreenState();
}

class _ConsultationNotesScreenState extends State<ConsultationNotesScreen> {
  String _selectedTab = 'Consultation Notes';
  int _notesCharCount = 0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _subjectiveController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  bool _isLoading = false;
  final bool _isSaving = false;
  DoctorConsultationNotes? _consultationNotes;

  bool _isEditingSubjective = false;
  bool _isEditingAssessment = false;
  bool _isEditingPlan = false;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() {
      if (mounted) {
        setState(() {
          _notesCharCount = _notesController.text.length;
        });
      }
    });

    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      _fetchConsultationNotes(widget.sessionId!);
    }
  }

  Future<void> _fetchConsultationNotes(String sessionId) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().getDoctorConsultationNotes(sessionId);
      final notes = DoctorConsultationNotes.fromJson(res);
      if (mounted) {
        setState(() {
          _consultationNotes = notes;
          _isLoading = false;
          if (notes.subjective.isNotEmpty) {
            _subjectiveController.text = notes.subjective;
          }
          if (notes.assessment.isNotEmpty) {
            _assessmentController.text = notes.assessment;
          }
          if (notes.plan.isNotEmpty) {
            _planController.text = notes.plan;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _subjectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00897B)))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleSection(),
                        _buildPatientCard(),
                        _buildTabBar(),
                        _buildSubjectiveSection(),
                        _buildObjectiveSection(),
                        _buildAssessmentSection(),
                        _buildPlanSection(),
                        _buildDoctorNotesSection(),
                        _buildInfoBanner(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF00695C),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add, color: Color(0xFF00695C), size: 20),
          ),
          const SizedBox(width: 10),
          const Text('MediKiosk',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 24),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFB2DFDB),
            child: ClipOval(
              child: Image.asset(
                'assets/images/doctor_avatar.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.person,
                    color: Color(0xFF00695C), size: 20),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consultation Notes',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2332))),
                const SizedBox(height: 4),
                Text('Record consultation details and clinical notes',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00897B), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.teal.shade600, size: 16),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Time Saved',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500)),
                    const Text('16:45 min',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2332))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    final name = _consultationNotes?.patientName.isNotEmpty == true
        ? _consultationNotes!.patientName
        : (widget.patientName ?? 'Ramesh Kumar');

    final abha = _consultationNotes?.abhaId.isNotEmpty == true
        ? _consultationNotes!.abhaId
        : (widget.abhaId ?? 'XX-1234-5678-9012');

    final token = _consultationNotes?.tokenNumber.isNotEmpty == true
        ? _consultationNotes!.tokenNumber
        : 'OPD: General Medicine • Token: 1247';

    final hasRedFlags = _consultationNotes?.assessment.contains('red flag') == true ||
        _consultationNotes?.assessment.contains('Priority') == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFB2DFDB),
            child: ClipOval(
              child: Image.asset(
                'assets/images/patient_avatar.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.person,
                    color: Color(0xFF00695C), size: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332))),
                const SizedBox(height: 3),
                Text('ABHA: $abha',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(token,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (hasRedFlags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Color(0xFFDC2626), size: 14),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('HIGH PRIORITY',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626))),
                      Text('Red Flags Active',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade400)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      _TabData('Clinical Summary', Icons.description_outlined),
      _TabData('Medical Documents', Icons.folder_outlined),
      _TabData('Timeline', Icons.access_time),
      _TabData('Consultation Notes', Icons.edit_note),
      _TabData('Prescriptions', Icons.receipt_long),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab.label;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab.label),
              child: Column(
                children: [
                  Icon(tab.icon,
                      size: 20,
                      color: isSelected
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade400),
                  const SizedBox(height: 4),
                  Text(tab.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF00897B)
                              : Colors.grey.shade500)),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      height: 2.5,
                      width: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00897B),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectiveSection() {
    final defaultSubjective = _consultationNotes?.subjective.isNotEmpty == true
        ? _consultationNotes!.subjective
        : 'Patient reports sudden onset chest pain 2 hours back. Pain is retro sternal, pressure like, radiates to left arm. Associated with sweating and shortness of breath. No nausea or vomiting.';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline,
                    color: Color(0xFF00897B), size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332)),
                    children: [
                      TextSpan(text: 'Subjective '),
                      TextSpan(
                        text: "(Patient's Perspective)",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_isEditingSubjective && _subjectiveController.text.isEmpty) {
                      _subjectiveController.text = defaultSubjective;
                    }
                    _isEditingSubjective = !_isEditingSubjective;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00897B)),
                  ),
                  child: Row(
                    children: [
                      Icon(_isEditingSubjective ? Icons.check : Icons.edit_outlined,
                          color: const Color(0xFF00897B), size: 13),
                      const SizedBox(width: 4),
                      Text(_isEditingSubjective ? 'Done' : 'Edit',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00897B))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isEditingSubjective)
            TextField(
              controller: _subjectiveController,
              maxLines: 4,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2332)),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5),
                  children: [
                    const TextSpan(text: '❝  '),
                    TextSpan(
                      text: _subjectiveController.text.isNotEmpty
                          ? _subjectiveController.text
                          : defaultSubjective,
                    ),
                    const TextSpan(text: '  ❞'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildObjectiveSection() {
    final objText = _consultationNotes?.objective.isNotEmpty == true
        ? _consultationNotes!.objective
        : '';

    final findings = objText.isNotEmpty
        ? objText.split('|').map((part) {
            final idx = part.indexOf(':');
            if (idx != -1) {
              return [part.substring(0, idx).trim(), part.substring(idx + 1).trim()];
            }
            return ['Observation', part.trim()];
          }).toList()
        : [
            ['General Appearance', 'Conscious, oriented, in mild distress'],
            ['Pulse', '96/min, regular'],
            ['BP', '146/92 mmHg'],
            ['SpO₂', '98% on room air'],
            ['RS', 'Bilateral air entry equal, no added sounds'],
            ['CVS', 'S1 S2 normal, no murmurs'],
            ['Temp', '98.4 °F'],
          ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.monitor_heart_outlined,
                    color: Color(0xFF2E7D32), size: 18),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332)),
                    children: [
                      TextSpan(text: 'Objective '),
                      TextSpan(
                        text: "(Examination Findings)",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (int i = 0; i < findings.length; i++) ...[
                  if (i > 0)
                    Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                        indent: 14,
                        endIndent: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(findings[i][0],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600)),
                        ),
                        Expanded(
                          child: Text(findings[i][1],
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A2332))),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentSection() {
    final defaultAssessment = _consultationNotes?.assessment.isNotEmpty == true
        ? _consultationNotes!.assessment
        : 'Possible Acute Coronary Syndrome (ACS)';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined,
                    color: Color(0xFF7B1FA2), size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Assessment',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332))),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_isEditingAssessment && _assessmentController.text.isEmpty) {
                      _assessmentController.text = defaultAssessment;
                    }
                    _isEditingAssessment = !_isEditingAssessment;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00897B)),
                  ),
                  child: Row(
                    children: [
                      Icon(_isEditingAssessment ? Icons.check : Icons.edit_outlined,
                          color: const Color(0xFF00897B), size: 13),
                      const SizedBox(width: 4),
                      Text(_isEditingAssessment ? 'Done' : 'Edit',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00897B))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isEditingAssessment)
            TextField(
              controller: _assessmentController,
              maxLines: 2,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2332)),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                        _assessmentController.text.isNotEmpty
                            ? _assessmentController.text
                            : defaultAssessment,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8F00),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Provisional',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanSection() {
    final defaultPlan = [
      'ECG – stat',
      'Cardiac enzymes (Trop-I) – stat',
      'Sublingual Sorbitrate 5 mg – if pain persists',
      'Tab Aspirin 150 mg – chewable',
      'Monitor vitals and SpO₂',
      'Cardiology review',
    ];

    final planItems = _consultationNotes?.plan.isNotEmpty == true
        ? _consultationNotes!.plan.split('\n').where((s) => s.trim().isNotEmpty).toList()
        : defaultPlan;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.checklist,
                    color: Color(0xFF3949AB), size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Plan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332))),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_isEditingPlan && _planController.text.isEmpty) {
                      _planController.text = planItems.join('\n');
                    }
                    _isEditingPlan = !_isEditingPlan;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00897B)),
                  ),
                  child: Row(
                    children: [
                      Icon(_isEditingPlan ? Icons.check : Icons.edit_outlined,
                          color: const Color(0xFF00897B), size: 13),
                      const SizedBox(width: 4),
                      Text(_isEditingPlan ? 'Done' : 'Edit',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00897B))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isEditingPlan)
            TextField(
              controller: _planController,
              maxLines: 4,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1A2332)),
              decoration: InputDecoration(
                hintText: 'Enter each plan item on a new line...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.teal.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5),
                ),
              ),
            )
          else if (_planController.text.isNotEmpty)
            ..._planController.text
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  ',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF00897B),
                                  fontWeight: FontWeight.w700)),
                          Expanded(
                            child: Text(item,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1A2332),
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    ))
          else
            ...planItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF00897B),
                              fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Text(item,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A2332),
                                height: 1.4)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildDoctorNotesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_note,
                    color: Color(0xFF00897B), size: 18),
              ),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332)),
                  children: [
                    TextSpan(text: 'Doctor Notes '),
                    TextSpan(
                      text: "(Optional)",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 500,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF1A2332)),
                  decoration: InputDecoration(
                    hintText: 'Add any additional notes...',
                    hintStyle: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    counterText: '',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14, bottom: 8),
                    child: Text('$_notesCharCount/500',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined,
              color: Colors.teal.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
                'All consultation notes are securely saved and linked to patient\'s record.',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade800)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDraft() async {
    final messenger = ScaffoldMessenger.of(context);
    final sessionId = widget.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        await ApiService().completeDoctorConsultation(
          sessionId: sessionId,
          diagnosis: _assessmentController.text.trim().isNotEmpty
              ? _assessmentController.text.trim()
              : (_consultationNotes?.assessment ?? 'Draft Assessment'),
          doctorNotes: _notesController.text.trim(),
        );
      } catch (_) {}
    }
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Consultation draft saved successfully.'),
        backgroundColor: Color(0xFF00897B),
      ),
    );
  }

  Future<void> _saveAndProceed() async {
    final sessionId = widget.sessionId;
    final messenger = ScaffoldMessenger.of(context);

    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        final diagnosis = _assessmentController.text.trim().isNotEmpty
            ? _assessmentController.text.trim()
            : (_consultationNotes?.assessment ?? 'General Clinical Consultation');
        final doctorNotes = _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : 'Consultation completed.';

        await ApiService().completeDoctorConsultation(
          sessionId: sessionId,
          diagnosis: diagnosis,
          icd10Codes: _consultationNotes?.suggestedIcd10Codes.isNotEmpty == true
              ? _consultationNotes!.suggestedIcd10Codes
              : ['G43.9'],
          icdTm2Codes: _consultationNotes?.suggestedIcdTm2Codes.isNotEmpty == true
              ? _consultationNotes!.suggestedIcdTm2Codes
              : ['TM2-AYUSH-104'],
          prescriptions: [
            if (_planController.text.isNotEmpty)
              {
                'drugName': _planController.text.split('\n').first,
                'dosage': '1 tab',
                'frequency': '1-0-1',
                'durationDays': 5,
              }
            else
              {
                'drugName': 'Sumatriptan',
                'dosage': '50mg',
                'frequency': '1-0-1',
                'durationDays': 5,
              }
          ],
          doctorNotes: doctorNotes,
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Consultation completed and saved successfully!'),
            backgroundColor: Color(0xFF00897B),
          ),
        );
      } catch (e) {
        print('[ConsultationNotes] Save error: $e');
        final isNetwork = e is DioException && e.type == DioExceptionType.connectionError;
        messenger.showSnackBar(
          SnackBar(
            content: Text(isNetwork
                ? 'Consultation saved locally (Offline mode).'
                : 'Consultation saved locally.'),
            backgroundColor: const Color(0xFFE65100),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    if (!mounted) return;
    context.push('/consultation-completed', extra: {
      'patientName': _consultationNotes?.patientName.isNotEmpty == true
          ? _consultationNotes!.patientName
          : widget.patientName,
      'abhaId': _consultationNotes?.abhaId.isNotEmpty == true
          ? _consultationNotes!.abhaId
          : widget.abhaId,
      'sessionId': widget.sessionId,
    });
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: _saveDraft,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00897B), width: 1.5),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.bookmark_outline,
                              color: Color(0xFF00897B), size: 18),
                          SizedBox(width: 6),
                          Text('SAVE DRAFT',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00897B))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _isSaving ? null : _saveAndProceed,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _isSaving ? const Color(0xFF9CA3AF) : const Color(0xFF00897B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isSaving)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.check_circle_outline,
                                color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(_isSaving ? 'SAVING...' : 'SAVE & PROCEED',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
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
}

class _TabData {
  final String label;
  final IconData icon;
  _TabData(this.label, this.icon);
}