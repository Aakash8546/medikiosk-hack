import 'package:flutter/material.dart';










class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE5E7EB),
    this.highlightColor = const Color(0xFFF3F4F6),
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value,
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}


class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}


class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}



class AyushStepSkeleton extends StatelessWidget {
  const AyushStepSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              SkeletonCircle(size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 18),
                    SizedBox(height: 6),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
              SkeletonBox(width: 80, height: 32, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 16),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (_) => SkeletonCircle(size: 12)),
          ),
          const SizedBox(height: 20),

          
          SkeletonBox(height: 80, borderRadius: 14),
          const SizedBox(height: 20),

          
          const SkeletonBox(width: 200, height: 18),
          const SizedBox(height: 8),
          const SkeletonBox(width: 300, height: 14),
          const SizedBox(height: 16),

          
          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SkeletonBox(height: 120, borderRadius: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          
          const SkeletonBox(width: 250, height: 18),
          const SizedBox(height: 8),
          const SkeletonBox(width: 180, height: 14),
          const SizedBox(height: 16),

          Row(
            children: List.generate(
              3,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SkeletonBox(height: 120, borderRadius: 12),
                ),
              ),
            ),
          ),
          const Spacer(),

          
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 48, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 48, borderRadius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}