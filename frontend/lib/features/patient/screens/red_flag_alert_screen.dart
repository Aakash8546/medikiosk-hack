import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/doctor_portal_responses.dart';
import '../../doctor/providers/doctor_dashboard_provider.dart';
import '../../doctor/providers/doctor_screen_providers.dart';

class RedFlagAlertScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? abhaId;
  final String? message;
  final List<String>? redFlags;

  
  
  final String? sessionId;

  const RedFlagAlertScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.message,
    this.redFlags,
    this.sessionId,
  });

  @override
  ConsumerState<RedFlagAlertScreen> createState() =>
      _RedFlagAlertScreenState();
}

class _RedFlagAlertScreenState extends ConsumerState<RedFlagAlertScreen> {
  int _selectedNav = 2; 

  
  DoctorRedFlagAlert? _alert;

  
  
  
  bool get _noFlags {
    if (_alert != null) return !_alert!.hasFlags;
    return widget.redFlags == null || widget.redFlags!.isEmpty;
  }

  String get _alertLevelLabel {
    if (_alert != null) {
      switch (_alert!.alertLevel.toUpperCase()) {
        case 'CRITICAL':
          return 'CRITICAL';
        case 'NONE':
          return 'NO RED FLAGS';
        default:
          return 'HIGH PRIORITY';
      }
    }
    return _noFlags ? 'NO RED FLAGS' : 'HIGH PRIORITY';
  }

  Color get _alertLevelColor =>
      _noFlags ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

  String get _formattedTime {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String get _formattedDate {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get _detectedByEngine {
    final ruleName = _alert?.allAlerts.firstOrNull?.ruleName;
    if (ruleName != null && ruleName.isNotEmpty) return ruleName;
    return 'AI Risk Engine';
  }

  @override
  Widget build(BuildContext context) {
    String? sessionId = widget.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      final dashboardAsync = ref.watch(doctorDashboardProvider);
      final queue = dashboardAsync.valueOrNull?.patientQueue ?? const [];
      if (queue.isNotEmpty) {
        final redFlagItem = queue.firstWhere(
          (p) => p.isRedFlag == true,
          orElse: () => queue.first,
        );
        sessionId = redFlagItem.sessionId;
      }
    }

    if (sessionId != null && sessionId.isNotEmpty) {
      final async = ref.watch(doctorRedFlagProvider(sessionId));
      _alert = async.valueOrNull;
      if (async.isLoading && _alert == null) {
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
                    const SizedBox(height: 16),
                    _buildAlertBanner(),
                    const SizedBox(height: 12),
                    _buildAlertLevelCard(),
                    const SizedBox(height: 12),
                    _buildSymptomsCard(),
                    const SizedBox(height: 12),
                    _buildRecommendedActionCard(),
                    const SizedBox(height: 12),
                    _buildInfoBanner(),
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
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white, size: 20),
        ],
      ),
    );
  }

  
  
  
  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFDC2626).withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 22, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Text(
                      'RED-FLAG ALERT',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'This patient has high-risk symptoms that need urgent clinical attention.',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF374151),
                      height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.notifications_active_rounded,
                  size: 32, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildAlertLevelCard() {
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
          
          Row(
            children: [
              const Text('Alert Level',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151))),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _alertLevelColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_alertLevelLabel,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _alert?.recommendedAction.isNotEmpty == true
                ? _alert!.recommendedAction
                : (_noFlags
                    ? 'No red-flag symptoms were detected. Routine consultation.'
                    : 'Immediate review by a doctor is recommended.'),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 14),
          
          Container(
              height: 1,
              decoration: const BoxDecoration(color: Color(0xFFE5E7EB))),
          const SizedBox(height: 14),
          
          Row(
            children: [
              
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.access_time_rounded,
                    size: 18, color: Color(0xFFDC2626)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detected At',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(_formattedTime,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2332))),
                    Text(_formattedDate,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.smart_toy_outlined,
                    size: 18, color: Color(0xFFDC2626)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detected By',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                    const SizedBox(height: 2),
                    Text(_detectedByEngine,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2332)),
                        overflow: TextOverflow.ellipsis),
                    const Text('Clinical Rules Engine',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSymptomsCard() {
    final List<_SymptomData> symptoms;

    if (_alert != null) {
      symptoms = _alert!.allAlerts.map((f) {
        final critical = f.severity.toUpperCase() == 'CRITICAL';
        return _SymptomData(
          alertId: f.alertId,
          title: f.ruleName.isNotEmpty ? f.ruleName : (f.symptom.isNotEmpty ? f.symptom : 'Red Flag Alert'),
          description: f.triggeredBy.isNotEmpty
              ? 'Triggered by: ${f.triggeredBy}'
              : (f.description.isNotEmpty ? f.description : 'Detected during kiosk interview'),
          severity: f.severity.isNotEmpty ? f.severity.toUpperCase() : 'CRITICAL',
          severityColor:
              critical ? const Color(0xFFDC2626) : const Color(0xFFE85D3A),
          icon: Icons.warning_rounded,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor:
              critical ? const Color(0xFFDC2626) : const Color(0xFFE85D3A),
        );
      }).toList();
    } else if (widget.redFlags != null && widget.redFlags!.isNotEmpty) {
      symptoms = widget.redFlags!.map((rf) {
        return _SymptomData(
          title: rf,
          description: 'Emergency Red-Flag detected during interview',
          severity: 'HIGH',
          severityColor: const Color(0xFFDC2626),
          icon: Icons.warning_rounded,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
        );
      }).toList();
    } else {
      symptoms = const [];
    }

    if (symptoms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined,
                size: 22, color: Color(0xFF16A34A)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.message ??
                    'No emergency symptoms were detected during the interview.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
              ),
            ),
          ],
        ),
      );
    }

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
              Text('🚩', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('Red-Flag Symptoms Detected',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 14),
          
          ...List.generate(symptoms.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: i < symptoms.length - 1 ? 12 : 0),
              child: _buildSymptomRow(symptoms[i]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSymptomRow(_SymptomData symptom) {
    final sid = widget.sessionId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: symptom.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(symptom.icon, size: 20, color: symptom.iconColor),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symptom.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2332))),
                  const SizedBox(height: 2),
                  Text(symptom.description,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: symptom.severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border:
                    Border.all(color: symptom.severityColor.withValues(alpha: 0.3)),
              ),
              child: Text(symptom.severity,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: symptom.severityColor,
                      letterSpacing: 0.3)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: symptom.severityColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: symptom.severityColor.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: symptom.severityColor.withValues(alpha: 0.3)),
              ),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final targetAlertId = (symptom.alertId != null && symptom.alertId!.isNotEmpty)
                  ? symptom.alertId!
                  : (sid ?? 'alert-123');
              try {
                await ref.read(apiServiceProvider).acknowledgeRedFlagAlert(alertId: targetAlertId);
                if (sid != null && sid.isNotEmpty) {
                  ref.invalidate(doctorRedFlagProvider(sid));
                }
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
            label: const Text('Acknowledge & Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildRecommendedActionCard() {
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
              Icon(Icons.description_outlined,
                  size: 18, color: Color(0xFF374151)),
              SizedBox(width: 8),
              Text('Recommended Action',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2332))),
            ],
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital_rounded,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Urgent Clinical Evaluation Required',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2332))),
                      const SizedBox(height: 4),
                      Text(
                          'Please prioritize this patient in the queue and ensure immediate clinical assessment.',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF374151)
                                  .withValues(alpha: 0.8),
                              height: 1.4)),
                    ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: Color(0xFF0B6B6A)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'This alert is generated automatically and does not replace clinical judgment.',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                  height: 1.4),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              
            },
            child: const Row(
              children: [
                Text('Learn more',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A))),
                SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: Color(0xFF0B6B6A)),
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
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final sid = widget.sessionId;
                  final alertId = _alert?.allAlerts.firstOrNull?.alertId ?? sid ?? 'alert-123';
                  try {
                    await ref.read(apiServiceProvider).acknowledgeRedFlagAlert(alertId: alertId);
                    if (sid != null && sid.isNotEmpty) {
                      ref.invalidate(doctorRedFlagProvider(sid));
                    }
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Red-flag alert acknowledged & cleared by physician.'),
                        backgroundColor: Color(0xFF0B6B6A),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Red-flag alert marked as reviewed.'),
                        backgroundColor: Color(0xFF0B6B6A),
                      ),
                    );
                  }
                  if (mounted) {
                    context.go('/doctor-dashboard');
                  }
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'MARK AS REVIEWED & ACKNOWLEDGE',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient queue token moved to High Priority.'),
                      backgroundColor: Color(0xFF0B6B6A),
                    ),
                  );
                  context.go('/token');
                },
                icon: const Icon(Icons.content_paste_rounded, size: 18),
                label: const Text(
                  'PRIORITIZE IN QUEUE',
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
                  onTap: () {
                    setState(() => _selectedNav = 1);
                    context.go('/doctor-dashboard');
                  }),
              _NavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Alerts',
                  isSelected: _selectedNav == 2,
                  onTap: () {
                    setState(() => _selectedNav = 2);
                    context.go('/red-flag-alert');
                  },
                  hasDot: true),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isSelected: _selectedNav == 3,
                  onTap: () {
                    setState(() => _selectedNav = 3);
                    context.go('/profile');
                  },
                  hasDot:true),
            ],
          ),
        ),
      ),
    );
  }
}




class _SymptomData {
  final String? alertId;
  final String title;
  final String description;
  final String severity;
  final Color severityColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const _SymptomData({
    this.alertId,
    required this.title,
    required this.description,
    required this.severity,
    required this.severityColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
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