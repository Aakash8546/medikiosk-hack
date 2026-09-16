import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';

import '../../onboarding/providers/onboarding_provider.dart';
import '../../../app/providers/locale_provider.dart';
import '../../../services/api_service.dart';

class PersonalizedRecommendationsScreen extends ConsumerStatefulWidget {
  const PersonalizedRecommendationsScreen({super.key});

  @override
  ConsumerState<PersonalizedRecommendationsScreen> createState() =>
      _PersonalizedRecommendationsScreenState();
}

class _PersonalizedRecommendationsScreenState
    extends ConsumerState<PersonalizedRecommendationsScreen> {
  bool _isDownloading = false;

  
  
  Future<void> _downloadReport() async {
    final session = ref.read(sessionProvider);
    final sessionId = session.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No active session — please complete the assessment first.')),
      );
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final currentLang = ref.read(localeProvider).languageCode;
      final path = await ApiService().downloadAyushPdf(
        sessionId: sessionId,
        lang: currentLang,
        sessionToken: session.token,
      );
      if (!mounted) return;
      setState(() => _isDownloading = false);
      final opened = await OpenFile.open(path);
      if (!mounted) return;
      if (opened.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved to $path')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not download the report. Please try again.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(context),

            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    
                    _buildInfoCard(),

                    const SizedBox(height: 16),

                    
                    _buildAssessmentSnapshot(),

                    const SizedBox(height: 16),

                    
                    _buildDietRecommendations(),

                    const SizedBox(height: 16),

                    
                    _buildLifestyleRecommendations(),

                    const SizedBox(height: 16),

                    
                    _buildHerbalSupport(),

                    const SizedBox(height: 16),

                    
                    _buildDailyRoutine(),

                    const SizedBox(height: 16),

                    
                    _buildRememberCard(),

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

  

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/ahara-vihara'),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF0B6B6A), size: 20),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Personalized Recommendations',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Based on your AYUSH Assessment',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B6B6A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Listen',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'These recommendations are personalized for you based on your Prakriti, Vikriti, Agni, Koshtha and lifestyle assessment.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Always follow the advice of your AYUSH physician.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B6B6A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildAssessmentSnapshot() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your Assessment Snapshot',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'View Full',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0B6B6A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: const Color(0xFF0B6B6A), size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                _buildSnapshotItem('🔵', 'Prakriti', 'Pitta-Kapha', const Color(0xFF0B6B6A)),
                _buildSnapshotItem('🔥', 'Agni', 'Madhyama', const Color(0xFF22C55E)),
                _buildSnapshotItem('🫁', 'Koshtha', 'Madhyama', const Color(0xFF22C55E)),
                _buildSnapshotItem('🪷', 'Vikriti', 'Pitta↑', const Color(0xFFE67E22)),
                _buildSnapshotItem('📋', 'Overall', 'Moderate', const Color(0xFFE67E22)),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSnapshotItem(String emoji, String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  

  Widget _buildDietRecommendations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              const Text('🥗', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ahara (Diet) Recommendations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Eat fresh, light, and easy to digest foods.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0B6B6A), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Food List',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF0B6B6A), size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Include More',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDietItem('✅', 'Warm, cooked, and lightly spiced meals'),
                    _buildDietItem('✅', 'Green vegetables (bottle gourd, ridge gourd)'),
                    _buildDietItem('✅', 'Old rice, barley, mung dal'),
                    _buildDietItem('✅', 'Buttermilk, coriander, fennel water'),
                    _buildDietItem('✅', 'Pomegranate, apple, grapes'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Limit / Avoid',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDietItem('❌', 'Fried, oily and heavy foods'),
                    _buildDietItem('❌', 'Excess salt, sour and spicy food'),
                    _buildDietItem('❌', 'Fermented and packaged foods'),
                    _buildDietItem('❌', 'Cold drinks, ice cream'),
                    _buildDietItem('❌', 'Daytime sleeping after meals'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDietItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF374151),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildLifestyleRecommendations() {
    final lifestyleItems = [
      {'emoji': '🌅', 'title': 'Wake Up', 'subtitle': 'Before 6 AM'},
      {'emoji': '🏃', 'title': 'Physical Activity', 'subtitle': '30 min walk /\nlight exercise'},
      {'emoji': '🧘', 'title': 'Stress Management', 'subtitle': 'Pranayama,\nMeditation'},
      {'emoji': '🌙', 'title': 'Sleep', 'subtitle': '10 PM – 6 AM'},
      {'emoji': '⏰', 'title': 'Meal Timing', 'subtitle': 'Eat on time,\navoid late meals'},
      {'emoji': '💧', 'title': 'Hydration', 'subtitle': 'Warm water\nthrough the day'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              const Text('🧘', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vihara (Lifestyle) Recommendations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Build daily habits that balance your doshas.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0B6B6A), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Daily Routine',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF0B6B6A), size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: lifestyleItems.take(3).map((item) {
              return _buildLifestyleItem(item);
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: lifestyleItems.skip(3).take(3).map((item) {
              return _buildLifestyleItem(item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleItem(Map<String, String> item) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(item['emoji']!, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item['subtitle']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7280),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  

  Widget _buildHerbalSupport() {
    final herbalItems = [
      {'emoji': '🌿', 'name': 'Triphala', 'timing': 'At bedtime'},
      {'emoji': '🪴', 'name': 'Guduchi', 'timing': 'Morning'},
      {'emoji': '🫗', 'name': 'Jeera Water', 'timing': 'After meals'},
      {'emoji': '🥛', 'name': 'Turmeric Milk', 'timing': 'At bedtime'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              const Text('🍶', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Herbal & Natural Support',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'Support digestion, immunity and well-being.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0B6B6A), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF0B6B6A), size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: herbalItems.take(2).map((item) {
              return _buildHerbalItem(item);
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: herbalItems.skip(2).take(2).map((item) {
              return _buildHerbalItem(item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHerbalItem(Map<String, String> item) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(item['emoji']!, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['name']!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            item['timing']!,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  

  Widget _buildDailyRoutine() {
    final routineItems = [
      {'time': '6:00 AM', 'title': 'Wake up', 'subtitle': 'Warm water', 'emoji': '🌅'},
      {'time': '7:00 AM', 'title': 'Light breakfast', 'subtitle': '', 'emoji': '🥣'},
      {'time': '10:00 AM', 'title': 'Hydrate', 'subtitle': '(Warm water)', 'emoji': '💧'},
      {'time': '1:00 PM', 'title': 'Lunch', 'subtitle': '(Main meal)', 'emoji': '🍽️'},
      {'time': '5:00 PM', 'title': 'Herbal tea /', 'subtitle': 'Fruits', 'emoji': '🍵'},
      {'time': '8:00 PM', 'title': 'Light dinner', 'subtitle': 'by 7:30 PM', 'emoji': '🌙'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              const Text('⏰', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Daily Routine (Suggested)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'A simple routine to follow every day.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0B6B6A), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Full Routine',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B6B6A),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF0B6B6A), size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: routineItems.take(3).map((item) {
              return _buildTimelineItem(item, false);
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: routineItems.skip(3).take(3).map((item) {
              return _buildTimelineItem(item, false);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, String> item, bool showConnector) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(item['emoji']!, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['time']!,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B6B6A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (item['subtitle']!.isNotEmpty)
            Text(
              item['subtitle']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 7,
                color: Color(0xFF6B7280),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  

  Widget _buildRememberCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remember',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Consistency in diet, lifestyle and positive thinking is the key to good health.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Text('🌿', style: TextStyle(fontSize: 40)),
        ],
      ),
    );
  }

  

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isDownloading ? null : _downloadReport,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF0B6B6A)))
                  : const Icon(Icons.download_rounded,
                      size: 16, color: Color(0xFF0B6B6A)),
              label: Text(
                _isDownloading ? 'Preparing…' : 'Download',
                style: const TextStyle(
                  color: Color(0xFF0B6B6A),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side:
                    const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/upload-documents'),
              icon: const Text(
                'Continue to Next',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              label: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}