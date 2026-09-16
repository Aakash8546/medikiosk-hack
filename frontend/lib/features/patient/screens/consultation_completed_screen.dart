import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../doctor/providers/doctor_dashboard_provider.dart';

final _completionProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, sessionId) async {
  return ref.read(apiServiceProvider).getDoctorCompletionStatus(sessionId);
});

class ConsultationCompletedScreen extends ConsumerWidget {
  final String? patientName;
  final String? abhaId;
  final String? sessionId;

  const ConsultationCompletedScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<Map<String, dynamic>>? asyncData;
    if (sessionId != null) {
      asyncData = ref.watch(_completionProvider(sessionId!));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildSuccessAnimation(),
                  _buildTitleSection(),
                  if (sessionId != null && asyncData != null)
                    asyncData.when(
                      data: (data) => Column(
                        children: [
                          _buildStatsRow(data),
                          _buildQueueStatus(data),
                          _buildWhatsNextCard(context, data),
                        ],
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF00897B))),
                      ),
                      error: (e, st) => _buildFallbackContent(context),
                    )
                  else
                    _buildFallbackContent(context),
                  _buildThankYouBanner(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildFallbackContent(BuildContext context) {
    return Column(
      children: [
        _buildStatsRowFallback(),
        _buildWhatsNextCardFallback(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF00695C),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 14),
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
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        
        ..._buildConfettiDots(),
        
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF00897B).withValues(alpha: 0.2), width: 4),
          ),
        ),
        
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFF00897B).withValues(alpha: 0.3), width: 3),
          ),
        ),
        
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF00897B),
            boxShadow: [
              BoxShadow(
                color: Color(0x3300897B),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  List<Widget> _buildConfettiDots() {
    return [
      
      Positioned(
        top: 10,
        left: 80,
        child: Container(
            width: 8, height: 8, decoration: BoxDecoration(color: Colors.pink.shade200, shape: BoxShape.circle)),
      ),
      
      Positioned(
        top: 4,
        left: 140,
        child: Container(
            width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
      ),
      
      Positioned(
        top: 14,
        right: 100,
        child: Container(
            width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF66BB6A), shape: BoxShape.circle)),
      ),
      
      Positioned(
        top: 30,
        right: 70,
        child: Container(
            width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFFB74D), shape: BoxShape.circle)),
      ),
      
      Positioned(
        top: 40,
        left: 70,
        child: Container(
            width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFFFEE58), shape: BoxShape.circle)),
      ),
      
      Positioned(
        top: 8,
        right: 80,
        child: Container(
            width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF26A69A), shape: BoxShape.circle)),
      ),
      
      Positioned(
        top: 20,
        left: 90,
        child: Transform.rotate(
          angle: 0.5,
          child: Container(
              width: 12, height: 4, decoration: BoxDecoration(color: Colors.pink.shade300, borderRadius: BorderRadius.circular(2))),
        ),
      ),
      
      Positioned(
        top: 10,
        right: 90,
        child: Transform.rotate(
          angle: -0.5,
          child: Container(
              width: 12, height: 4, decoration: BoxDecoration(color: const Color(0xFF26A69A), borderRadius: BorderRadius.circular(2))),
        ),
      ),
    ];
  }

  Widget _buildTitleSection() {
    return const Column(
      children: [
        SizedBox(height: 16),
        Text('Consultation Completed!',
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF00897B))),
        SizedBox(height: 6),
        Text('Clinical record saved successfully',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildStatItem(Icons.person_outline, 'Patient',
              data['patientName'] ?? patientName ?? 'Patient', const Color(0xFF1A2332)),
          _buildStatDivider(),
          _buildStatItem(Icons.receipt_long_outlined, 'Token No.',
              data['tokenNumber']?.toString() ?? '1247',
              const Color(0xFF1A2332)),
          _buildStatDivider(),
          _buildStatItem(Icons.access_time_outlined, 'Time Saved',
              data['consultationDuration']?.toString() ?? '16:45 min', const Color(0xFF00897B)),
          _buildStatDivider(),
          _buildStatItem(Icons.calendar_today_outlined, 'Date',
              data['completionDate']?.toString() ?? '12 May 2026', const Color(0xFF1A2332)),
        ],
      ),
    );
  }

  Widget _buildStatsRowFallback() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildStatItem(Icons.person_outline, 'Patient',
              patientName ?? 'Patient', const Color(0xFF1A2332)),
          _buildStatDivider(),
          _buildStatItem(Icons.receipt_long_outlined, 'Token No.', '1247',
              const Color(0xFF1A2332)),
          _buildStatDivider(),
          _buildStatItem(Icons.access_time_outlined, 'Time Saved',
              '16:45 min', const Color(0xFF00897B)),
          _buildStatDivider(),
          _buildStatItem(Icons.calendar_today_outlined, 'Date',
              '12 May 2026', const Color(0xFF1A2332)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00897B)),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500)),
          const SizedBox(height: 3),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
        height: 40,
        width: 1,
        color: Colors.grey.shade200);
  }

  Widget _buildQueueStatus(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${data['remainingInQueue'] ?? 0} patients remaining in queue',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Next patient: ${data['nextPatientToken'] ?? '-'}',
              style: const TextStyle(color: Color(0xFF00897B), fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildWhatsNextCard(BuildContext context, Map<String, dynamic> data) {
    final List<dynamic> checklist = data['whatsSavedChecklist'] ?? [];
    
    
    final actions = checklist.map((item) {
      final text = item.toString();
      IconData icon = Icons.check_circle_outline;
      Color iconBgColor = const Color(0xFFE0F2F1);
      Color iconColor = const Color(0xFF00695C);
      
      if (text.toLowerCase().contains('print')) {
        icon = Icons.print_outlined;
        iconColor = const Color(0xFF00897B);
      } else if (text.toLowerCase().contains('send') || text.toLowerCase().contains('share')) {
        icon = Icons.share_outlined;
        iconBgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
      } else if (text.toLowerCase().contains('notif')) {
        icon = Icons.notifications_outlined;
        iconBgColor = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFE65100);
      } else if (text.toLowerCase().contains('patient')) {
        icon = Icons.person_add_outlined;
      }

      return _WhatsNextAction(
        icon: icon,
        iconBgColor: iconBgColor,
        iconColor: iconColor,
        title: text,
        subtitle: 'Processed successfully.',
      );
    }).toList();

    if (actions.isEmpty) return _buildWhatsNextCardFallback(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's next?",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2332))),
          const SizedBox(height: 12),
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.grey.shade100, indent: 52),
            _buildWhatsNextItem(actions[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildWhatsNextCardFallback(BuildContext context) {
    final actions = [
      _WhatsNextAction(
        icon: Icons.person_add_outlined,
        iconBgColor: const Color(0xFFE0F2F1),
        iconColor: const Color(0xFF00695C),
        title: 'Patient moved to doctor queue',
        subtitle: 'Doctor will review the clinical summary.',
      ),
      _WhatsNextAction(
        icon: Icons.print_outlined,
        iconBgColor: const Color(0xFFE0F2F1),
        iconColor: const Color(0xFF00897B),
        title: 'Print Summary',
        titleHighlight: '(Optional)',
        subtitle: 'You can print the summary for patient.',
      ),
      _WhatsNextAction(
        icon: Icons.share_outlined,
        iconBgColor: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF2E7D32),
        title: 'Send Summary to Patient',
        titleHighlight: '(Optional)',
        subtitle: 'Share via SMS / WhatsApp / ABHA.',
      ),
      _WhatsNextAction(
        icon: Icons.notifications_outlined,
        iconBgColor: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
        title: 'Patient will be notified',
        subtitle: 'We will notify the patient when doctor is ready.',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's next?",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2332))),
          const SizedBox(height: 12),
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: Colors.grey.shade100, indent: 52),
            _buildWhatsNextItem(actions[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildWhatsNextItem(_WhatsNextAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: action.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, size: 20, color: action.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(action.title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2332))),
                    ),
                    if (action.titleHighlight != null) ...[
                      const SizedBox(width: 4),
                      Text(action.titleHighlight!,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal.shade600)),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(action.subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500)),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Colors.grey.shade300, size: 20),
        ],
      ),
    );
  }

  Widget _buildThankYouBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFB2DFDB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined,
                color: Color(0xFF00695C), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thank you!',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00695C))),
                const SizedBox(height: 4),
                Text(
                    'You have completed this consultation successfully.\nAll data is securely saved and linked to patient\'s record.',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.teal.shade800,
                        height: 1.4)),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline,
              color: Colors.teal.shade200, size: 36),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.go('/doctor-dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NEXT PATIENT',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                      Text('Start new consultation',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                context.go('/doctor-dashboard');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF00695C),
                side: const BorderSide(color: Color(0xFF00695C), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_outlined,
                      color: Color(0xFF00695C), size: 18),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BACK TO DASHBOARD',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      Text('View today\'s patient list',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('All actions are securely logged.',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhatsNextAction {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? titleHighlight;
  final String subtitle;

  const _WhatsNextAction({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.titleHighlight,
    required this.subtitle,
  });
}