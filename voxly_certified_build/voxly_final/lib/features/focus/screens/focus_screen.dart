import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class FocusScreen extends StatefulWidget {
  final String taskTitle;
  const FocusScreen({super.key, required this.taskTitle});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int _secondsLeft = 1500; // 25 minutes
  Timer? _timer;
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _timer?.cancel();
            _isRunning = false;
          }
        });
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  String _formatTime() {
    final minutes = (_secondsLeft / 60).floor();
    final seconds = (_secondsLeft % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Breathing animation effect
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.5, 1.5),
              duration: 4000.ms,
              curve: Curves.easeInOutSine,
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(Icons.center_focus_strong, color: AppColors.primary, size: 48),
                const SizedBox(height: 24),
                Text(
                  widget.taskTitle,
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Focus Session',
                  style: TextStyle(color: AppColors.textSecond, fontSize: 16),
                ),
                const Spacer(),
                Text(
                   _formatTime(),
                   style: GoogleFonts.poppins(
                     fontSize: 80,
                     fontWeight: FontWeight.w300,
                     color: Colors.white,
                     letterSpacing: 2,
                   ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.textSecond, size: 30),
                      onPressed: () => setState(() => _secondsLeft = 1500),
                    ),
                    const SizedBox(width: 32),
                    GestureDetector(
                      onTap: _toggleTimer,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      icon: const Icon(Icons.stop, color: AppColors.textSecond, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Breathe in. Deeply.',
                  style: TextStyle(color: AppColors.textHint, fontStyle: FontStyle.italic),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 2000.ms),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
