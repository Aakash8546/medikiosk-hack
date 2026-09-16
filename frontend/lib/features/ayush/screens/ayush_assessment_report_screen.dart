import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/core/utils/responsive.dart';
import 'package:medikiosk/app/providers/locale_provider.dart';
import 'package:medikiosk/app/localization/app_localizations.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';
import 'package:medikiosk/models/ayush_report_response.dart';
import 'package:medikiosk/services/api_service.dart';
import 'package:open_file/open_file.dart';





class AyushAssessmentReportScreen extends ConsumerStatefulWidget {
  final AyushReportResponse? report;

  const AyushAssessmentReportScreen({super.key, this.report});

  @override
  ConsumerState<AyushAssessmentReportScreen> createState() => _AyushAssessmentReportScreenState();
}

class _AyushAssessmentReportScreenState extends ConsumerState<AyushAssessmentReportScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  
  String? get _sessionId {
    
    if (widget.report?.sessionId != null && widget.report!.sessionId!.isNotEmpty) {
      return widget.report!.sessionId;
    }
    
    final session = ref.read(sessionProvider);
    return session.sessionId;
  }

  Future<void> _downloadPdf() async {
    final sessionId = _sessionId;
    final sessionToken = ref.read(sessionProvider).token;
    if (sessionId == null || sessionId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No session ID available. Please complete an assessment first.')),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final api = ApiService();
      final currentLang = ref.read(localeProvider).languageCode;
      final filePath = await api.downloadAyushPdf(
        sessionId: sessionId,
        lang: currentLang,
        sessionToken: sessionToken,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      if (!mounted) return;

      
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: ${result.message}')),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        final message = e.response?.statusCode == 403
            ? 'This assessment is not finalized or you are not authorized to download it.'
            : 'Download failed: ${e.message ?? e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  
  static final _demo = AyushReportResponse(
    sessionId: 'demo-session',
    vataScore: 10,
    pittaScore: 12,
    kaphaScore: 2,
    vataPercentage: 41.7,
    pittaPercentage: 50.0,
    kaphaPercentage: 8.3,
    prakritiResult: 'PITTA_VATA',
    prakritiDescription: 'You have a Pitta-Vata constitution. You are likely to be energetic, focused and quick in thought with a tendency towards sensitivity and dryness.',
    agniScore: 4,
    agniGauge: 0.5,
    agniType: 'MADHYAMA_AGNI',
    lifestyleScore: 16,
    lifestyleBadge: 'Excellent',
    tastePreference: ['sweet', 'sour'],
    waterIntake: 'adequate',
    vikritiSummary: const VikritiSummary(
      doshas: ['vata', 'pitta'],
      symptoms: ['bloating', 'acidity'],
      severity: 'moderate',
      duration: '1-4-weeks',
    ),
    completenessScore: 85,
    isFinalized: true,
  );

  @override
  Widget build(BuildContext context) {
    final data = widget.report ?? _demo;
    final r = Responsive.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [                    _buildHeader(context, r, l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: r.sectionSpacing),
                    _buildPrakritiSection(data, r, l10n),
                    SizedBox(height: r.sectionSpacing),
                    _buildWhatThisMeans(data, r, l10n),
                    SizedBox(height: r.sectionSpacing),
                    _buildKeyInsights(data, r, l10n),
                    SizedBox(height: r.sectionSpacing),
                    _buildVikritiSection(data, r, l10n),
                    SizedBox(height: r.sectionSpacing),
                    _buildDoctorView(data, r, l10n),
                    SizedBox(height: r.sectionSpacing),
                    _buildDisclaimer(r, l10n),
                    SizedBox(height: r.sectionSpacing),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(r, l10n),
          ],
        ),
      ),
    );
  }

  
  Widget _buildHeader(BuildContext context, Responsive r, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.horizontalPadding, 12, r.horizontalPadding, 0),
      child: Row(
        children: [
          
          
          
          
          
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  l10n.assessmentReport,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  l10n.ayushReportSubtitle,
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0B6B6A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(l10n.listenButton, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildPrakritiSection(AyushReportResponse data, Responsive r, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: r.cardEdgeInsets,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(l10n.ayushReportYourPrakriti,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0B6B6A))),
            ],
          ),
          SizedBox(height: r.sectionSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.prakritiResult,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(l10n.ayushReportConstitution,
                        style: TextStyle(fontSize: 14, color: Color(0xFFE67E22), fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      data.prakritiDescription,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
                    ),
                    SizedBox(height: r.sectionSpacing),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 14),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(l10n.ayushReportAssessmentCompleted,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: r.sectionSpacing),
              
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: _buildDonutChart(data),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildDonutChart(AyushReportResponse data) {
    final segments = [
      _DonutSegment(data.pittaPercentage / 100, const Color(0xFFE67E22), 'Pitta', '${data.pittaPercentage}%', '(${data.pittaScore})'),
      _DonutSegment(data.vataPercentage / 100, const Color(0xFF3B82F6), 'Vata', '${data.vataPercentage}%', '(${data.vataScore})'),
      _DonutSegment(data.kaphaPercentage / 100, const Color(0xFF22C55E), 'Kapha', '${data.kaphaPercentage}%', '(${data.kaphaScore})'),
    ];

    return Row(
      children: [
        
        Expanded(
          child: CustomPaint(
            size: const Size(140, 140),
            painter: _DonutPainter(segments),
            child: const Center(
              child: Text('🌿', style: TextStyle(fontSize: 32)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: segments.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.label}  ${s.percent}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: s.color),
                            overflow: TextOverflow.ellipsis),
                        Text(s.count, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  
  Widget _buildWhatThisMeans(AyushReportResponse data, Responsive r, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: r.cardEdgeInsets,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ayushReportWhatThisMeans,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(
                  data.vikritiDescription.isNotEmpty
                      ? '${data.prakritiDescription}\n${data.vikritiDescription}'
                      : data.prakritiDescription,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildKeyInsights(AyushReportResponse data, Responsive r, AppLocalizations l10n) {
    final insights = [
      _KeyInsight('🔥', 'Agni', data.agniType, const Color(0xFFE67E22), data.agniDescription),
      _KeyInsight('🧘', 'Lifestyle', data.lifestyleBadge, const Color(0xFF22C55E), data.lifestyleDescription),
      _KeyInsight('🧑', 'Vikriti', data.vikritiDoshasSummary, const Color(0xFF3B82F6), data.vikritiDescription),
      _KeyInsight('💧', 'Hydration', data.waterIntake, const Color(0xFF06B6D4), data.hydrationDescription),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ayushReportKeyInsights,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        SizedBox(height: r.sectionSpacing),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            separatorBuilder: (_, __) => SizedBox(width: r.optionSpacing),
            itemBuilder: (_, i) => SizedBox(
              width: 140,
              child: _buildInsightCard(insights[i], r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(_KeyInsight insight, Responsive r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(insight.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.label,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                    Text(insight.value,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: insight.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(insight.description,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.3),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.7,
              minHeight: 4,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(insight.color),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildVikritiSection(AyushReportResponse data, Responsive r, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: r.cardEdgeInsets,
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔄', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l10n.ayushReportVikritiTitle,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ),
            ],
          ),
          SizedBox(height: r.sectionSpacing),
          
          Row(
            children: [
              _buildVikritiDataItem(l10n.ayushReportImbalancedDoshas, data.vikritiSummary.doshas.join(', '), r),
              _buildVikritiDataItem(l10n.ayushReportKeySymptoms, data.vikritiSummary.symptoms.join(', '), r),
              _buildVikritiDataItem(l10n.ayushReportSeverity, data.vikritiSummary.severity, r),
              _buildVikritiDataItem(l10n.ayushReportDuration, data.vikritiSummary.duration, r),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVikritiDataItem(String label, String value, Responsive r) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE67E22)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  
  Widget _buildDoctorView(AyushReportResponse data, Responsive r, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Expanded(
          child: Container(
            padding: r.cardEdgeInsets,
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🩺', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(l10n.ayushReportDoctorView,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...data.doctorsQuickView.map((point) => _buildDoctorPoint(point)),
              ],
            ),
          ),
        ),
        SizedBox(width: r.optionSpacing),
        
        Expanded(
          child: Container(
            padding: r.cardEdgeInsets,
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ayushReportSuggestedFocus,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0B6B6A))),
                const SizedBox(height: 12),
                ...data.suggestedFocusAreas.map((area) => _buildFocusPoint('🌿', area)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF374151), height: 1.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusPoint(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF374151), height: 1.3)),
          ),
        ],
      ),
    );
  }

  
  Widget _buildDisclaimer(Responsive r, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: r.cardEdgeInsets,
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF9CA3AF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ayushReportDisclaimer,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                const SizedBox(height: 4),
                Text(
                  l10n.ayushReportDisclaimerText,
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildBottomButtons(Responsive r, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(r.horizontalPadding, 12, r.horizontalPadding, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              
              Expanded(
                child: _isDownloading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LinearProgressIndicator(
                            value: _downloadProgress,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B6B6A)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${l10n.ayushReportDownloading} ${(_downloadProgress * 100).toInt()}%',
                            style: TextStyle(fontSize: 11, color: Color(0xFF0B6B6A)),
                          ),
                        ],
                      )
                    : OutlinedButton.icon(
                        onPressed: _downloadPdf,
                        icon: const Icon(Icons.download_rounded, size: 16, color: Color(0xFF0B6B6A)),
                        label: Text(l10n.downloadReport,
                            style: TextStyle(color: Color(0xFF0B6B6A), fontWeight: FontWeight.w600, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0B6B6A), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(                    onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.ayushReportReportSaved)),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
                  label: Text(l10n.shareWithDoctor,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6B6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(sessionProvider.notifier).setMode('ayush');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.ayushReportSuccess),
                    backgroundColor: Color(0xFF0B6B6A),
                    duration: Duration(seconds: 2),
                  ),
                );
                context.go('/dashboard', extra: {'source': 'ayush'});
              },
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              label: Text(l10n.ayushReportSubmitDone,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
    ],
  );
}



class _DonutSegment {
  final double fraction;
  final Color color;
  final String label;
  final String percent;
  final String count;
  const _DonutSegment(this.fraction, this.color, this.label, this.percent, this.count);
}

class _KeyInsight {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final String description;
  const _KeyInsight(this.emoji, this.label, this.value, this.color, this.description);
}



class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 28.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweepAngle = 2 * math.pi * seg.fraction;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
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