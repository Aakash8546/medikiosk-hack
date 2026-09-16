import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/doctor_portal_responses.dart';
import '../../doctor/providers/doctor_screen_providers.dart';

class MedicalTimelineScreen extends ConsumerStatefulWidget {
  final String? patientName;
  final String? abhaId;

  
  
  final String? sessionId;

  const MedicalTimelineScreen({
    super.key,
    this.patientName,
    this.abhaId,
    this.sessionId,
  });

  @override
  ConsumerState<MedicalTimelineScreen> createState() =>
      _MedicalTimelineScreenState();
}

class _MedicalTimelineScreenState extends ConsumerState<MedicalTimelineScreen> {
  int _selectedTab = 2; 
  int _selectedNav = 1; 
  String _selectedFilter = 'All Events';

  final List<String> _filters = [
    'All Events',
    'Consultations',
    'Reports',
    'Medications',
    'Procedures',
  ];

  DoctorTimeline? _timeline;

  @override
  Widget build(BuildContext context) {
    final sessionId = widget.sessionId;
    if (sessionId != null && sessionId.isNotEmpty) {
      final async = ref.watch(doctorTimelineProvider(sessionId));
      _timeline = async.valueOrNull;
      if (async.isLoading && _timeline == null) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientInfoCard(),
                    _buildTabBar(),
                    _buildTimelineHeader(),
                    _buildFilterPills(),
                    _buildTimeline(),
                    _buildInfoBanner(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildViewFullSummaryButton(),
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
                Text(
                  '54 Y • Male • ABHA: ${widget.abhaId ?? 'XX-1234-5678-9012'}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6B7280)),
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
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: Color(0xFFDC2626)),
                    const SizedBox(width: 4),
                    const Text('RED FLAG',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFDC2626))),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('High Priority',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280))),
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
      _TabData(icon: Icons.favorite_border_rounded, label: 'Vitals (Kiosk)'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 12),
                  
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

  
  
  
  Widget _buildTimelineHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          const Text(
            'Medical Timeline',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2332)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.info_outline_rounded,
              size: 18, color: Color(0xFF6B7280)),
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0B6B6A)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list_rounded,
                    size: 16, color: Color(0xFF0B6B6A)),
                SizedBox(width: 4),
                Text('Filter',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildFilterPills() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0B6B6A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B6B6A)
                      : const Color(0xFFD1D5DB),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : const Color(0xFF374151)),
              ),
            ),
          );
        },
      ),
    );
  }

  
  
  
  String get _patientName =>
      (_timeline?.patientName.isNotEmpty ?? false)
          ? _timeline!.patientName
          : (widget.patientName ?? 'Patient');

  
  
  
  Widget _buildTimeline() {
    final events = _timeline?.events ?? const <TimelineEventItem>[];

    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Column(
          children: [
            const Icon(Icons.history_toggle_off_rounded,
                size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 10),
            Text(
              _timeline == null
                  ? 'Open this from the patient queue to see their timeline.'
                  : 'No prior records were digitized for this patient.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    final visible = _selectedFilter == 'All Events'
        ? events
        : events.where((e) => _matchesFilter(e, _selectedFilter)).toList();

    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'No ${_selectedFilter.toLowerCase()} in this patient\'s timeline.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          for (int i = 0; i < visible.length; i++) ...[
            _buildTimelineEvent(
              dateLabel: visible[i].date,
              date: '',
              iconColor: _accentFor(visible[i].badgeColor),
              iconBgColor: _accentFor(visible[i].badgeColor).withValues(alpha: 0.12),
              icon: _iconFor(visible[i].iconType),
              tagLabel: _prettyCategory(visible[i].category),
              tagColor: _accentFor(visible[i].badgeColor),
              tagBgColor: _accentFor(visible[i].badgeColor).withValues(alpha: 0.12),
              title: visible[i].title,
              time: visible[i].time,
              subtitle: visible[i].resultText,
              bottomTag: visible[i].highlightTag,
              bottomTagColor: const Color(0xFF374151),
              bottomTagBgColor: const Color(0xFFF3F4F6),
              bottomText: visible[i].highlightValue,
              bottomTextColor: const Color(0xFF1A2332),
              showArrow: false,
            ),
            if (i < visible.length - 1) _buildConnectorLine(),
          ],
        ],
      ),
    );
  }

  bool _matchesFilter(TimelineEventItem e, String filter) {
    final c = e.category.toUpperCase();
    switch (filter.toLowerCase()) {
      case 'consultations':
        return c.contains('CONSULT') || c.contains('DISCHARGE');
      case 'reports':
        return c.contains('LAB') || c.contains('IMAGING');
      case 'medications':
        return c.contains('PRESCRIPTION');
      case 'procedures':
        return c.contains('PROCEDURE');
      default:
        return true;
    }
  }

  static String _prettyCategory(String category) => category.isEmpty
      ? 'Document'
      : category
          .split('_')
          .map((w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' ');

  static IconData _iconFor(String iconType) {
    switch (iconType) {
      case 'prescription':
        return Icons.medication_outlined;
      case 'lab':
        return Icons.science_outlined;
      case 'imaging':
        return Icons.image_outlined;
      case 'hospital':
        return Icons.local_hospital_outlined;
      case 'interview':
        return Icons.medical_services_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  static Color _accentFor(String badgeColor) {
    switch (badgeColor) {
      case 'green':
        return const Color(0xFF059669);
      case 'purple':
        return const Color(0xFF7C3AED);
      case 'orange':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Widget _buildTimelineEvent({
    required String dateLabel,
    required String date,
    required Color iconColor,
    required Color iconBgColor,
    required IconData icon,
    required String tagLabel,
    required Color tagColor,
    required Color tagBgColor,
    required String title,
    required String time,
    String? subtitle,
    String? subtitleHighlight,
    String? bottomTag,
    Color? bottomTagColor,
    Color? bottomTagBgColor,
    String? bottomText,
    Color? bottomTextColor,
    bool showArrow = false,
    bool showDocIcon = false,
    bool showThumb = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dateLabel.isNotEmpty)
                  Text(
                    dateLabel,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151)),
                  ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF6B7280)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(12),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tagBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tagLabel,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: tagColor),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2332)),
                        ),
                      ),
                      if (showDocIcon) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.description_outlined,
                              size: 18, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (showThumb) ...[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.medical_information_outlined,
                              size: 22, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (showArrow)
                        const Icon(Icons.chevron_right_rounded,
                            size: 20, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  if (subtitle != null) ...[
                    if (subtitleHighlight != null)
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              height: 1.3),
                          children: [
                            const TextSpan(text: 'Result: '),
                            TextSpan(
                              text: subtitleHighlight,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                            height: 1.3),
                      ),
                  ],
                  
                  if (bottomTag != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: bottomTagBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            bottomTag,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: bottomTagColor),
                          ),
                        ),
                        if (bottomText != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bottomText,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: bottomTextColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 72 + 8 + 19, top: 2, bottom: 2),
      child: Container(
        width: 2,
        height: 14,
        color: const Color(0xFFD1D5DB),
      ),
    );
  }

  
  
  
  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined,
              size: 20, color: Color(0xFF0B6B6A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Timeline is created from interviews, documents and past records.\nPlease verify before consultation.',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151).withValues(alpha: 0.8),
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildViewFullSummaryButton() {
    return Container(
      color: const Color(0xFFF4F6F8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              context.go('/ai-clinical-summary', extra: {
                'patientName': _patientName,
                'abhaId': widget.abhaId,
                'sessionId': widget.sessionId,
              });
            },
            icon: const Icon(Icons.content_paste_rounded, size: 20),
            label: const Text(
              'VIEW FULL SUMMARY',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
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