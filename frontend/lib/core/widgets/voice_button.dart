import 'package:flutter/material.dart';
import '../../app/design_tokens.dart';

enum VoiceButtonState { idle, listening, processing, success, error }

class VoiceButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoiceButtonState state;

  const VoiceButton({
    super.key,
    required this.onPressed,
    this.state = VoiceButtonState.idle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state == VoiceButtonState.listening;
    final isProcessing = state == VoiceButtonState.processing;

    return SizedBox(
      width: DesignTokens.voiceButtonMinSize,
      height: DesignTokens.voiceButtonMinSize,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive
              ? DesignTokens.critical500
              : DesignTokens.primary500,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: DesignTokens.critical500.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: state == VoiceButtonState.processing ? null : onPressed,
            customBorder: const CircleBorder(),
            child: Center(
              child: _buildIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case VoiceButtonState.idle:
        return const Icon(
          Icons.mic_rounded,
          color: DesignTokens.white,
          size: 32,
        );
      case VoiceButtonState.listening:
        return const Icon(
          Icons.mic_rounded,
          color: DesignTokens.white,
          size: 32,
        );
      case VoiceButtonState.processing:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.white),
          ),
        );
      case VoiceButtonState.success:
        return const Icon(
          Icons.check_rounded,
          color: DesignTokens.white,
          size: 32,
        );
      case VoiceButtonState.error:
        return const Icon(
          Icons.mic_off_rounded,
          color: DesignTokens.white,
          size: 32,
        );
    }
  }
}