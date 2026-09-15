import 'dart:async';
import 'package:flutter/material.dart';

class InactivityDetector extends StatefulWidget {
  final Duration timeout;
  final VoidCallback onTimeout;
  final Widget child;

  const InactivityDetector({
    super.key,
    this.timeout = const Duration(minutes: 3),
    required this.onTimeout,
    required this.child,
  });

  @override
  State<InactivityDetector> createState() => _InactivityDetectorState();
}

class _InactivityDetectorState extends State<InactivityDetector> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, widget.onTimeout);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer,
      child: widget.child,
    );
  }
}