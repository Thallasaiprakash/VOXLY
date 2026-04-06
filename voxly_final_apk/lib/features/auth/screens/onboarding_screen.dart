import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/voxly_logo.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../models/user_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();

  Future<void> _completeOnboarding() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name first!')),
      );
      _pageController.animateToPage(0, duration: 300.ms, curve: Curves.easeOut);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setBool('onboarding_complete', true);

    // Create user profile in Firebase
    final authRepo = ref.read(authRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    // Sign in anonymously if not signed in (for the demo)
    if (authRepo.currentUser == null) {
      final cred = await authRepo.signInAnonymously();
      final uid = cred.user!.uid;
      
      await userRepo.createUserProfile(UserModel(
        uid: uid,
        name: _nameController.text.trim(),
        createdAt: DateTime.now(),
        settings: {
          'voiceEnabled': true,
          'voiceSpeed': 0.85,
          'quietHoursStart': '22:00',
          'quietHoursEnd': '07:00',
          'overlayMode': 'first_unlock',
          'weekStartsMonday': true,
        },
        moodLog: {},
      ));
    }

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _NameEntryPage(controller: _nameController),
                  const _HowItWorksPage(),
                  const _PermissionsPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
                  Row(
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.surface2,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Continue button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutExpo);
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    child: Text(_currentPage == 2 ? 'Let\'s Go' : 'Continue'),
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

class _NameEntryPage extends StatelessWidget {
  final TextEditingController controller;
  const _NameEntryPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VoxlyLogo(size: 80),
          const SizedBox(height: 48),
          Text(
            'What should we call you?',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 24, color: Colors.white),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Your name...',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 24),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.surface2, width: 2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class _HowItWorksPage extends StatelessWidget {
  const _HowItWorksPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FeatureCard(
            icon: Icons.lock_open,
            title: 'Unlock & Hear',
            desc: 'Unlock your phone and hear your tasks immediately.',
            delay: 0,
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.calendar_month,
            title: 'Weekly Plan',
            desc: 'Plan your whole week in just 2 minutes.',
            delay: 200,
          ),
          const SizedBox(height: 24),
          _FeatureCard(
            icon: Icons.notifications_off,
            title: 'Smart Silence',
            desc: 'Completed tasks stay silent. No redundant noise.',
            delay: 400,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final int delay;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface2),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textSecond)),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: delay.ms).fadeIn().slideY(begin: 0.1);
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissions',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'VOXLY needs these to show your tasks on unlock.',
            style: TextStyle(color: AppColors.textSecond, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _PermissionItem(
            title: 'Overlay Permission',
            desc: 'To show tasks on top of your lock screen.',
            icon: Icons.layers,
          ),
          const SizedBox(height: 20),
          _PermissionItem(
            title: 'Background Service',
            desc: 'To monitor phone unlocks silently.',
            icon: Icons.sync,
          ),
           const SizedBox(height: 20),
          _PermissionItem(
            title: 'Notifications',
            desc: 'To send relevant task reminders.',
            icon: Icons.notifications,
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _PermissionItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _PermissionItem({
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primaryLight, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecond)),
            ],
          ),
        ),
      ],
    );
  }
}
