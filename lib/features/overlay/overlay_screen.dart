import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/voxly_logo.dart';
import '../../../services/tts_service.dart';
import '../../../models/task_model.dart';

class OverlayScreen extends StatefulWidget {
  final String userName;
  final List<Task> tasks;
  final bool isQuietHours;

  const OverlayScreen({
    super.key,
    required this.userName,
    required this.tasks,
    this.isQuietHours = false,
  });

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> with TickerProviderStateMixin {
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _startSequence();
  }

  Future<void> _startSequence() async {
    await _ttsService.init();
    
    // Start greeting and reading after a short delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      setState(() => _isSpeaking = true);
      await _ttsService.greetAndReadTasks(
        name: widget.userName,
        pendingTasks: widget.tasks.where((t) => !t.isCompleted).toList(),
        isQuietHours: widget.isQuietHours,
      );
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Important for overlay
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background.withOpacity(0.95),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              // Logo slide in
              const VoxlyLogo(size: 80).animate().slideY(begin: -1, duration: 600.ms, curve: Curves.easeOutExpo).fadeIn(),
              const SizedBox(height: 24),
              // Typewriter greeting
              _TypewriterText(
                text: 'Hey ${widget.userName},',
                style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ).animate(delay: 600.ms).fadeIn(),
              const SizedBox(height: 32),
              // Voice wave bars
              _VoiceWaveWidget(isSpeaking: _isSpeaking, controller: _waveController),
              const SizedBox(height: 48),
              // Task cards sliding in
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: widget.tasks.length,
                  itemBuilder: (context, index) {
                    return _OverlayTaskCard(task: widget.tasks[index])
                        .animate(delay: (1200 + index * 200).ms)
                        .slideX(begin: 1, duration: 450.ms, curve: Curves.easeOutCubic)
                        .fadeIn();
                  },
                ),
              ),
              // Dismiss button
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: GestureDetector(
                  onLongPress: () => Navigator.of(context).pop(), // Placeholder for overlay dismiss
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Hold to Dismiss',
                      style: TextStyle(color: AppColors.textSecond, fontWeight: FontWeight.bold),
                    ),
                  ).animate(delay: 2000.ms).fadeIn().scale(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const _TypewriterText({required this.text, required this.style});

  @override
  _TypewriterTextState createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayString = '';

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() async {
    for (int i = 0; i <= widget.text.length; i++) {
      if (!mounted) return;
      setState(() {
        _displayString = widget.text.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayString, style: widget.style);
  }
}

class _VoiceWaveWidget extends StatelessWidget {
  final bool isSpeaking;
  final AnimationController controller;
  const _VoiceWaveWidget({required this.isSpeaking, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 40),
          painter: _VoiceWavePainter(
            animationValue: controller.value,
            active: isSpeaking,
          ),
        );
      },
    );
  }
}

class _VoiceWavePainter extends CustomPainter {
  final double animationValue;
  final bool active;
  _VoiceWavePainter({required this.animationValue, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    const barCount = 7;
    final barWidth = size.width / (barCount * 2);
    final spacing = barWidth;
    final totalWidth = barCount * barWidth + (barCount - 1) * spacing;
    final startX = (size.width - totalWidth) / 2;

    for (int i = 0; i < barCount; i++) {
        final x = startX + i * (barWidth + spacing);
        double heightFactor = [0.4, 0.7, 0.9, 0.5, 0.8, 1.0, 0.6][i];
        
        if (active) {
            double sinVal = math.sin(animationValue * 2 * math.pi + (i * 0.8)).abs();
            heightFactor = 0.3 + (sinVal * 0.7);
        } else {
            // Idle pulse
            double pulse = math.sin(animationValue * 2 * math.pi);
            heightFactor *= (0.8 + (pulse * 0.2));
        }

        final height = size.height * heightFactor;
        final y = (size.height - height) / 2;

        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(x, y, barWidth, height),
                Radius.circular(barWidth / 2),
            ),
            paint..color = AppColors.primary.withOpacity(0.5 + heightFactor * 0.5),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWavePainter oldDelegate) => true;
}

class _OverlayTaskCard extends StatelessWidget {
  final Task task;
  const _OverlayTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final priorityColor = task.priority == 'critical' ? AppColors.danger : (task.priority == 'high' ? AppColors.warning : AppColors.primary);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: priorityColor, width: 6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const SizedBox(height: 4),
                if (task.time != null)
                  Text(task.time!, style: TextStyle(color: AppColors.textSecond, fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: AppColors.textHint, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
