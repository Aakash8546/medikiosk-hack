import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medikiosk/app/design_tokens.dart';
import 'package:medikiosk/app/theme.dart';
import 'package:medikiosk/core/widgets/kiosk_app_bar.dart';
import 'package:medikiosk/core/widgets/voice_button.dart';
import 'package:medikiosk/features/interview/providers/interview_provider.dart';
import 'package:medikiosk/features/onboarding/providers/onboarding_provider.dart';

class VoiceConversationScreen extends ConsumerStatefulWidget {
  const VoiceConversationScreen({super.key});

  @override
  ConsumerState<VoiceConversationScreen> createState() =>
      _VoiceConversationScreenState();
}

class _VoiceConversationScreenState
    extends ConsumerState<VoiceConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _speakerOn = true;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final interviewState = ref.read(interviewNotifierProvider);
      if (interviewState.sessionId == null) {
        final sessionLang = ref.read(sessionProvider).language ?? 'en';
        ref.read(interviewNotifierProvider.notifier).startInterview(language: sessionLang);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final interviewState = ref.watch(interviewNotifierProvider);
    final notifier = ref.read(interviewNotifierProvider.notifier);

    
    ref.listen<InterviewState>(interviewNotifierProvider, (previous, next) {
      if (next.toastMessage != null && next.toastMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.toastMessage!),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        notifier.clearToast();
      }

      
      if (next.status == 'emergency_stop') {
        context.go('/red-flag-alert', extra: {
          'patientName': 'Patient',
          'message': next.emergencyMessage,
          'redFlags': next.redFlags,
        });
      } else if (next.status == 'completed') {
        context.go('/upload-documents');
      }

      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: DesignTokens.neutral50,
      appBar: KioskAppBar(
        title: 'AI Clinical Interview',
        onBack: () => context.go('/mode-selection'),
        actions: [
          
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Interview bypassed for testing! Routing to Document Upload...'),
                  duration: Duration(seconds: 1),
                ),
              );
              context.go('/upload-documents');
            },
            icon: const Icon(Icons.fast_forward_rounded, color: Colors.orangeAccent, size: 18),
            label: const Text(
              'Skip (Test)',
              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => _speakerOn = !_speakerOn);
              if (!_speakerOn) {
                notifier.audioService.stopAudio();
              }
            },
            icon: Icon(
              _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: DesignTokens.primary500,
            ),
            tooltip: _speakerOn ? 'Mute TTS' : 'Unmute TTS',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            
            if (interviewState.isLoading)
              const LinearProgressIndicator(
                backgroundColor: DesignTokens.primary100,
                color: DesignTokens.primary500,
              ),

            
            if (interviewState.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spacingSM),
                color: DesignTokens.critical100,
                child: Text(
                  interviewState.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: DesignTokens.critical700),
                ),
              ),

            
            Expanded(
              child: interviewState.messages.isEmpty && interviewState.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: DesignTokens.spacingMD),
                          Text('Starting AI Clinical Interview...'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(DesignTokens.spacingMD),
                      itemCount: interviewState.messages.length,
                      itemBuilder: (context, index) {
                        final msg = interviewState.messages[index];
                        return _ChatBubble(message: msg);
                      },
                    ),
            ),

            
            if (interviewState.quickReplies.isNotEmpty && !interviewState.isLoading)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingMD,
                  vertical: DesignTokens.spacingSM,
                ),
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: interviewState.quickReplies.map((choice) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          elevation: 2,
                          backgroundColor: DesignTokens.primary100,
                          side: BorderSide(color: DesignTokens.primary100),
                          label: Text(
                            choice,
                            style: MediKioskTheme.bodyMedium.copyWith(
                              color: DesignTokens.primary900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {
                            notifier.sendTextAnswer(choice);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const Divider(height: 1, color: DesignTokens.neutral200),

            
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingMD),
              child: Column(
                children: [
                  Row(
                    children: [
                      
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !interviewState.isLoading,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (text) {
                            if (text.isNotEmpty) {
                              notifier.sendTextAnswer(text);
                              _textController.clear();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: interviewState.language == 'hi'
                                ? 'उत्तर टाइप करें या बोलें...'
                                : 'Type your answer or hold mic...',
                            filled: true,
                            fillColor: DesignTokens.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spacingMD,
                              vertical: DesignTokens.spacingMD,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: DesignTokens.neutral300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: DesignTokens.neutral300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: DesignTokens.primary500, width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send_rounded),
                              color: DesignTokens.primary500,
                              onPressed: () {
                                if (_textController.text.isNotEmpty) {
                                  notifier.sendTextAnswer(_textController.text);
                                  _textController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacingMD),

                      
                      GestureDetector(
                        onTap: () {
                          if (interviewState.isRecording) {
                            notifier.stopAndSendRecording();
                          } else {
                            notifier.startRecording();
                          }
                        },
                        onLongPressStart: (_) {
                          if (!interviewState.isRecording) {
                            notifier.startRecording();
                          }
                        },
                        onLongPressEnd: (_) {
                          if (interviewState.isRecording) {
                            notifier.stopAndSendRecording();
                          }
                        },
                        child: VoiceButton(
                          onPressed: null,
                          state: interviewState.isRecording
                              ? VoiceButtonState.listening
                              : (interviewState.isLoading
                                  ? VoiceButtonState.processing
                                  : VoiceButtonState.idle),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: DesignTokens.spacingSM),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          interviewState.isRecording
                              ? '🔴 Recording... Release button to send'
                              : (interviewState.language == 'hi'
                                  ? 'आप अपनी भाषा में बोल या लिख सकते हैं'
                                  : 'Hold mic to speak or type answer'),
                          overflow: TextOverflow.ellipsis,
                          style: MediKioskTheme.caption.copyWith(
                            color: interviewState.isRecording
                                ? DesignTokens.critical500
                                : DesignTokens.neutral500,
                            fontWeight: interviewState.isRecording
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      
                      InkWell(
                        onTap: () {
                          final newLang = interviewState.language == 'hi' ? 'en' : 'hi';
                          notifier.startInterview(language: newLang);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.primary100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                interviewState.language == 'hi' ? 'हिन्दी (HI)' : 'English (EN)',
                                style: MediKioskTheme.caption.copyWith(
                                  color: DesignTokens.primary900,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.swap_horiz_rounded, size: 16, color: DesignTokens.primary900),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final InterviewMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingMD),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: DesignTokens.primary100,
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    size: 20,
                    color: DesignTokens.primary700,
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingSM),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingMD,
                    vertical: DesignTokens.spacingMD,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? DesignTokens.primary500 : DesignTokens.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: MediKioskTheme.body.copyWith(
                      color: isUser ? DesignTokens.white : DesignTokens.neutral950,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),

          
          if (message.transcribedCaption != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                message.transcribedCaption!,
                style: MediKioskTheme.caption.copyWith(
                  color: DesignTokens.neutral500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}