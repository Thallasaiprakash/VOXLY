import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/voxly_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (onboardingComplete) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const VoxlyLogo(size: 120)
                .animate()
                .scale(
                  duration: 800.ms,
                  curve: Curves.easeOutExpo,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                )
                .then(delay: 200.ms),
            const SizedBox(height: 24),
            Text(
              'VOXLY',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Your voice. Your day.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecond,
                    letterSpacing: 1.2,
                  ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
