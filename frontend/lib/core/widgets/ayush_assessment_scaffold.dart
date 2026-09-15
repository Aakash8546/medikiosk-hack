import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/core/widgets/skeleton_loader.dart';


















class AyushAssessmentScaffold extends StatefulWidget {
  final String title;
  final int currentStep; 
  final int totalSteps;
  final List<String> stepLabels;
  final String backRoute;
  final Widget child;
  final VoidCallback? onListenPressed;
  final bool isLoading;

  const AyushAssessmentScaffold({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    required this.backRoute,
    required this.child,
    this.onListenPressed,
    this.isLoading = false,
  });

  @override
  State<AyushAssessmentScaffold> createState() =>
      _AyushAssessmentScaffoldState();
}

class _AyushAssessmentScaffoldState extends State<AyushAssessmentScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _contentAnimController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  bool _showSkeleton = false;

  @override
  void initState() {
    super.initState();
    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimController,
        curve: Curves.easeOut,
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    
    _showSkeletonThenContent();
  }

  Future<void> _showSkeletonThenContent() async {
    if (widget.isLoading) {
      setState(() => _showSkeleton = true);
      return;
    }
    setState(() => _showSkeleton = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _showSkeleton = false);
      _contentAnimController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AyushAssessmentScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading) {
      _showSkeletonThenContent();
    }
  }

  @override
  void dispose() {
    _contentAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepPercent =
        (widget.currentStep + 1) / widget.totalSteps;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            
            _buildHeader(),

            
            _buildProgressBar(stepPercent),

            
            _buildStepLabels(),

            
            Expanded(
              child: _showSkeleton
                  ? const AyushStepSkeleton()
                  : FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: widget.child,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(widget.backRoute),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0B6B6A),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  'Step ${widget.currentStep + 1} of ${widget.totalSteps}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onListenPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B6B6A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded,
                      color: Colors.white, size: 16),
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
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double stepPercent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: stepPercent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0B6B6A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabels() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: List.generate(widget.stepLabels.length, (index) {
          final isActive = index == widget.currentStep;
          final isCompleted = index < widget.currentStep;
          final color = isActive
              ? const Color(0xFF0B6B6A)
              : isCompleted
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF9CA3AF);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 10 : 8,
                  height: isActive ? 10 : 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                
                Text(
                  widget.stepLabels[index],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}