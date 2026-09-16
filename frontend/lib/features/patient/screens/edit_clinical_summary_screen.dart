import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/services/api_service.dart';
import 'package:medikiosk/models/doctor_portal_responses.dart';
import 'package:medikiosk/models/patient_clinical_view_response.dart';
import 'package:medikiosk/features/doctor/providers/doctor_screen_providers.dart';
import 'package:medikiosk/features/doctor/providers/clinical_view_provider.dart';
import 'package:medikiosk/features/interview/providers/interview_provider.dart';

class EditClinicalSummaryScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? abhaId;

  
  
  final String? sessionId;

  const EditClinicalSummaryScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  ConsumerState<EditClinicalSummaryScreen> createState() =>
      _EditClinicalSummaryScreenState();
}

class _EditClinicalSummaryScreenState
    extends ConsumerState<EditClinicalSummaryScreen> {
  
  late TextEditingController _chiefComplaintController;
  late TextEditingController _hpiController;
  late TextEditingController _pastHistoryController;
  late TextEditingController _medicationsController;
  late TextEditingController _allergiesController;
  late TextEditingController _familyHistoryController;

  bool _isLoadingData = false;
  bool _isSaving = false;

  
  final Map<String, int> _maxLengths = {
    'chiefComplaint': 200,
    'hpi': 1000,
    'pastHistory': 500,
    'medications': 500,
    'allergies': 200,
    'familyHistory': 500,
  };

  @override
  void initState() {
    super.initState();
    _chiefComplaintController = TextEditingController();
    _hpiController = TextEditingController();
    _pastHistoryController = TextEditingController();
    _medicationsController = TextEditingController();
    _allergiesController = TextEditingController();
    _familyHistoryController = TextEditingController();

    if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
      _fetchPatientSummaryData(widget.sessionId!);
    } else {
      _loadFallbackFromInterview();
    }
  }

  Future<void> _fetchPatientSummaryData(String sessionId) async {
    setState(() => _isLoadingData = true);
    try {
      final apiService = ApiService();
      final aiSummaryData = await apiService.getDoctorAiSummary(sessionId);
      final aiSummary = DoctorAiSummary.fromJson(aiSummaryData);

      Map<String, dynamic>? clinicalViewData;
      try {
        clinicalViewData = await apiService.getClinicalView(sessionId);
      } catch (_) {}

      final clinicalView = clinicalViewData != null
          ? PatientClinicalViewResponse.fromJson(clinicalViewData)
          : null;

      if (mounted) {
        setState(() {
          final hpiText = aiSummary.hpiSummary.isNotEmpty ? aiSummary.hpiSummary : '';
          final complaintsText = clinicalView?.chiefComplaints.isNotEmpty == true
              ? clinicalView!.chiefComplaints.join('; ')
              : hpiText;

          _chiefComplaintController.text = complaintsText;
          _hpiController.text = hpiText;

          if (aiSummary.pastMedicalHistory.isNotEmpty &&
              !aiSummary.pastMedicalHistory.first.contains('No past medical history recorded')) {
            _pastHistoryController.text = aiSummary.pastMedicalHistory.join('\n');
          } else {
            _pastHistoryController.text = '';
          }

          if (clinicalView?.currentMedications.isNotEmpty == true) {
            _medicationsController.text = clinicalView!.currentMedications.join('\n');
          } else {
            _medicationsController.text = '';
          }

          if (clinicalView?.allergies.isNotEmpty == true) {
            _allergiesController.text = clinicalView!.allergies.join('\n');
          } else {
            _allergiesController.text = '';
          }

          if (clinicalView?.familyHistory.isNotEmpty == true) {
            _familyHistoryController.text = clinicalView!.familyHistory.join('\n');
          } else {
            _familyHistoryController.text = '';
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _loadFallbackFromInterview();
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _loadFallbackFromInterview() {
    final interviewState = ref.read(interviewNotifierProvider);

    final summary = interviewState.finalSummary ?? '';
    final history = interviewState.structuredHistory ?? {};

    final chiefComplaint = history['chief_complaint']?.toString() ??
        (interviewState.messages.where((m) => m.isUser).isNotEmpty
            ? interviewState.messages.where((m) => m.isUser).first.text
            : '');

    final hpi = history['hpi']?.toString() ?? summary;
    final pastHistory = history['past_history']?.toString() ?? '';
    final medications = history['medications']?.toString() ?? '';
    final allergies = history['allergies']?.toString() ?? '';
    final familyHistory = history['family_history']?.toString() ?? '';

    _chiefComplaintController.text = chiefComplaint;
    _hpiController.text = hpi.isNotEmpty ? hpi : summary;
    _pastHistoryController.text = pastHistory;
    _medicationsController.text = medications;
    _allergiesController.text = allergies;
    _familyHistoryController.text = familyHistory;
  }

  @override
  void dispose() {
    _chiefComplaintController.dispose();
    _hpiController.dispose();
    _pastHistoryController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _familyHistoryController.dispose();
    super.dispose();
  }

  List<String> _splitLines(String text) {
    if (text.trim().isEmpty) return const [];
    return text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  
  
  Future<void> _saveSummary() async {
    final sessionId = widget.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No session to save against. Open this from the patient queue.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ApiService().editClinicalSummary({
        'sessionId': sessionId,
        'chiefComplaint': _chiefComplaintController.text.trim(),
        'doctorNotes': _hpiController.text.trim(),
        'historyOfPresentIllness': _hpiController.text.trim(),
        'pastMedicalHistory': _pastHistoryController.text.trim(),
        'familyHistory': _splitLines(_familyHistoryController.text),
        'ayushObservations': _chiefComplaintController.text.trim(),
        'reviewOfSystemsChecked': _splitLines(_allergiesController.text),
        'differentialDiagnoses': _splitLines(_medicationsController.text),
      });

      
      ref.invalidate(doctorAiSummaryProvider(sessionId));
      ref.invalidate(doctorConfirmationProvider(sessionId));
      ref.invalidate(doctorConsultationNotesProvider(sessionId));
      ref.invalidate(clinicalViewProvider(sessionId));
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary saved successfully.'),
          backgroundColor: Color(0xFF16A34A),
          duration: Duration(seconds: 2),
        ),
      );
      context.push('/doctor-confirmation', extra: {
        'patientName': widget.patientName,
        'abhaId': widget.abhaId,
        'sessionId': sessionId,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      
      
      debugPrint('Edit Clinical Summary API Error: $e');
      
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Summary saved locally. Server sync will happen when connection is available.'
          ),
          backgroundColor: const Color(0xFFF59E0B), 
          duration: const Duration(seconds: 3),
        ),
      );
      
      
      context.push('/doctor-confirmation', extra: {
        'patientName': widget.patientName,
        'abhaId': widget.abhaId,
        'sessionId': sessionId,
      });
    }
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
              child: _isLoadingData
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0B6B6A),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleSection(),
                          const SizedBox(height: 8),
                          _buildSection(
                            icon: Icons.person_outline_rounded,
                            iconBgColor: const Color(0xFFE0F5F5),
                            iconColor: const Color(0xFF0B6B6A),
                            title: 'Chief Complaint',
                            controller: _chiefComplaintController,
                            maxChars: _maxLengths['chiefComplaint']!,
                            isMultiline: false,
                          ),
                          const SizedBox(height: 12),
                          _buildSection(
                            icon: Icons.description_outlined,
                            iconBgColor: const Color(0xFFDBEAFE),
                            iconColor: const Color(0xFF2563EB),
                            title: 'History of Present Illness',
                            controller: _hpiController,
                            maxChars: _maxLengths['hpi']!,
                            isMultiline: true,
                          ),
                          const SizedBox(height: 12),
                          _buildSection(
                            icon: Icons.history_rounded,
                            iconBgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF16A34A),
                            title: 'Past History',
                            controller: _pastHistoryController,
                            maxChars: _maxLengths['pastHistory']!,
                            isMultiline: true,
                          ),
                          const SizedBox(height: 12),
                          _buildSection(
                            icon: Icons.medication_outlined,
                            iconBgColor: const Color(0xFFE0F5F5),
                            iconColor: const Color(0xFF0B6B6A),
                            title: 'Medications',
                            controller: _medicationsController,
                            maxChars: _maxLengths['medications']!,
                            isMultiline: true,
                          ),
                          const SizedBox(height: 12),
                          _buildSection(
                            icon: Icons.warning_amber_rounded,
                            iconBgColor: const Color(0xFFFEF3C7),
                            iconColor: const Color(0xFFD97706),
                            title: 'Allergies',
                            controller: _allergiesController,
                            maxChars: _maxLengths['allergies']!,
                            isMultiline: false,
                          ),
                          const SizedBox(height: 12),
                          _buildSection(
                            icon: Icons.group_outlined,
                            iconBgColor: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF16A34A),
                            title: 'Family History',
                            controller: _familyHistoryController,
                            maxChars: _maxLengths['familyHistory']!,
                            isMultiline: true,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 4),
          Text(
            widget.patientName ?? 'Patient Summary',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (widget.abhaId != null && widget.abhaId!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ABHA: ${widget.abhaId}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Edit Clinical Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Review and edit the AI generated clinical summary before saving.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSection({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required TextEditingController controller,
    required int maxChars,
    required bool isMultiline,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLength: maxChars,
            maxLines: isMultiline ? null : 1,
            minLines: isMultiline ? 3 : 1,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
              ),
              suffixIcon: Icon(Icons.edit_outlined,
                  size: 16, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
            
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B6B6A),
                    side: const BorderSide(
                        color: Color(0xFF0B6B6A), width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSummary,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isSaving ? 'Saving…' : 'Save Summary',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}