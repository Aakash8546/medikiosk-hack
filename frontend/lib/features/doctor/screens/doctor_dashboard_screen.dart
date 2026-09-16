import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/doctor_dashboard_response.dart';
import '../providers/doctor_dashboard_provider.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  int _selectedFilter = 0; 
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(doctorDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            
            _buildHeader(),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(doctorDashboardProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: dashboardAsync.when(
                    data: (dashboardData) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreeting(dashboardData),
                        _buildStatsRow(dashboardData),
                        _buildFilterTabs(),
                        _buildQueueHeader(),
                        if (dashboardData.patientQueue.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 48),
                            child: Center(
                              child: Text(
                                'No patients waiting in the OPD queue right now.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                              ),
                            ),
                          )
                        else
                          _buildPatientList(dashboardData.patientQueue),
                        const SizedBox(height: 16),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0B6B6A),
                        ),
                      ),
                    ),
                    error: (err, stack) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              err is DoctorDashboardException
                                  ? err.message
                                  : 'Failed to load OPD Dashboard: $err',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  err is DoctorDashboardException && err.requiresLogin
                                      ? context.go('/doctor-login')
                                      : ref.invalidate(doctorDashboardProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B6B6A),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                err is DoctorDashboardException && err.requiresLogin
                                    ? 'Sign in'
                                    : 'Retry',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
          
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MediKiosk',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/red-flag-alert'),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              

            ],
          ),
          const SizedBox(width: 4),
          
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://ui-avatars.com/api/?name=Dr.+Arjun&background=0F9FA8&color=fff&size=128',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildGreeting(DoctorDashboardResponse data) {
    final name = data.doctorName.isNotEmpty ? data.doctorName : 'Doctor';
    final spec = data.specialty.isNotEmpty ? data.specialty : 'Physician';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, Dr. $name',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2332),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              spec,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B6B6A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildStatsRow(DoctorDashboardResponse data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF0F9FA8),
            value: '${data.totalPatientsToday}',
            label: 'Total Patients',
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.groups_outlined,
            iconColor: const Color(0xFF22C55E),
            value: '${data.activeNow}',
            label: 'Active Now',
            valueColor: const Color(0xFF22C55E),
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.calendar_today_rounded,
            iconColor: const Color(0xFF3B82F6),
            value: '${data.opdCountToday}',
            label: "Today's OPD",
            valueColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF9CA3AF),
            value: '${data.completedCountToday}',
            label: 'Completed',
            valueColor: const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildFilterTabs() {
    final filters = ['All', 'AYUSH', 'General', 'Red Flags'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(filters.length, (i) {
                  final isSelected = _selectedFilter == i;
                  final isRedFlags = i == 3;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0B6B6A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0B6B6A)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              filters[i],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF374151),
                              ),
                            ),
                            if (isRedFlags) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildQueueHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Patient Queue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2332),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildPatientList(List<DoctorPatientQueueItem> queue) {
    
    final filteredPatients = queue.where((p) {
      switch (_selectedFilter) {
        case 0: 
          return true;
        case 1: 
          return p.sessionType.toUpperCase() == 'AYUSH';
        case 2: 
          return p.sessionType.toUpperCase() == 'GENERAL';
        case 3: 
          return p.isRedFlag ||
              p.priority.toUpperCase() == 'HIGH' ||
              p.priority.toUpperCase() == 'CRITICAL';
        default:
          return true;
      }
    }).toList();

    if (filteredPatients.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No patients found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Try selecting a different filter',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: filteredPatients.map((p) => _PatientCard(
          patient: p,
          onTap: () => context.go('/patient-queue-detail', extra: {
            'sessionId': p.sessionId,
            'patientId': p.patientId,
            'patientName': p.patientName,
            'abhaId': p.abhaId,
            'token': p.tokenNumber,
          }),
        )).toList(),
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
            offset: Offset(0, -2),
          ),
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
                onTap: () => setState(() => _selectedNav = 0),
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                label: 'Patients',
                isSelected: _selectedNav == 1,
                onTap: () => setState(() => _selectedNav = 1),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Alerts',
                isSelected: _selectedNav == 2,
                onTap: () {
                  setState(() => _selectedNav = 2);
                  context.push('/red-flag-alert');
                },
                hasDot: true,
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: _selectedNav == 3,
                onTap: () => setState(() => _selectedNav = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: valueColor ?? const Color(0xFF0F9FA8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _PatientCard extends StatelessWidget {
  final DoctorPatientQueueItem patient;
  final VoidCallback? onTap;

  const _PatientCard({required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRedFlag = patient.isRedFlag || patient.priority.toUpperCase() == 'CRITICAL';
    final isHigh = patient.priority.toUpperCase() == 'HIGH' && !isRedFlag;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: patient.borderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    patient.patientName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2332),
                                    ),
                                  ),
                                ),
                                if (isRedFlag)
                                  const _SeverityBadge(
                                    label: 'RED FLAG',
                                    color: Color(0xFFDC2626),
                                    bgColor: Color(0xFFFEE2E2),
                                    textColor: Color(0xFFDC2626),
                                    dotColor: Color(0xFFDC2626),
                                  ),
                                if (isHigh)
                                  const _SeverityBadge(
                                    label: 'HIGH',
                                    color: Color(0xFFF59E0B),
                                    bgColor: Color(0xFFFEF3C7),
                                    textColor: Color(0xFF92400E),
                                    icon: Icons.warning_amber_rounded,
                                  ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            
                            Text(
                              'Age ${patient.age}/${patient.gender.isNotEmpty ? patient.gender[0].toUpperCase() : ''}  |  Token ${patient.tokenNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),

                            const SizedBox(height: 6),

                            
                            Row(
                              children: [
                                
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: patient.sessionType.toUpperCase() == 'AYUSH'
                                        ? const Color(0xFFE0F5F5)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    patient.sessionType,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: patient.sessionType.toUpperCase() == 'AYUSH'
                                          ? const Color(0xFF0B6B6A)
                                          : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),

                                
                                if (patient.primarySymptom.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      patient.primarySymptom,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF374151),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                if (patient.prakritiBadge.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '🟢 ${patient.prakritiBadge}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _StatusBadge(status: _formatStatus(patient.status)),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING':
        return 'Waiting';
      case 'IN_REVIEW':
      case 'REVIEW':
        return 'In Review';
      case 'INTERVIEW':
        return 'Interview';
      case 'DOCUMENTS':
        return 'Documents';
      default:
        return status;
    }
  }
}




class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final Color textColor;
  final Color? dotColor;
  final IconData? icon;

  const _SeverityBadge({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.textColor,
    this.dotColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}




class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Waiting' => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      'In Review' => (
          const Color(0xFFE0F5F5),
          const Color(0xFF0B6B6A),
        ),
      'Interview' => (
          const Color(0xFFF3E8FF),
          const Color(0xFF7C3AED),
        ),
      'Documents' => (
          const Color(0xFFF3F4F6),
          const Color(0xFF6B7280),
        ),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
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
                    top: 0,
                    right: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}