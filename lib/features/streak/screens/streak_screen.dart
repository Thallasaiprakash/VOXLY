import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class StreakScreen extends ConsumerStatefulWidget {
  const StreakScreen({super.key});

  @override
  ConsumerState<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends ConsumerState<StreakScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Fire Streak
                        _StreakCounter(count: 7),
                        const SizedBox(height: 40),
                        // XP and Level
                        _XPProgress(totalXp: 1450, level: 'Disciplined'),
                        const SizedBox(height: 48),
                        // Badges
                        const _BadgesGrid(),
                        const SizedBox(height: 48),
                        // Weekly Chart placeholder
                        const _WeeklyCompletionChart(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [AppColors.primary, AppColors.success, AppColors.warning],
          ),
        ],
      ),
      bottomNavigationBar: const _VoxlyBottomNav(currentIndex: 2),
    );
  }
}

class _StreakCounter extends StatelessWidget {
  final int count;
  const _StreakCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.warning.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
                ],
              ),
            ),
            const Icon(Icons.local_fire_department, size: 100, color: AppColors.warning),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '$count DAY STREAK',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Keep the fire burning, Ramu!',
          style: TextStyle(color: AppColors.textSecond, fontSize: 14),
        ),
      ],
    );
  }
}

class _XPProgress extends StatelessWidget {
  final int totalXp;
  final String level;

  const _XPProgress({required this.totalXp, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surface2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XP POINTS', style: TextStyle(color: AppColors.textSecond, letterSpacing: 1.2, fontSize: 12)),
                  Text('$totalXp XP', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(level, style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.75,
              minHeight: 10,
              backgroundColor: AppColors.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('550 XP to Next Level', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid();

  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon': Icons.wb_sunny, 'label': 'Early Bird'},
      {'icon': Icons.task_alt, 'label': 'Closer'},
      {'icon': Icons.military_tech, 'label': 'Week Champ'},
      {'icon': Icons.nights_stay, 'label': 'Night Owl'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ACHIEVEMENTS', style: TextStyle(color: AppColors.textSecond, letterSpacing: 1.5, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Icon(badges[index]['icon'] as IconData, color: AppColors.primaryLight, size: 24),
                ),
                const SizedBox(height: 8),
                Text(badges[index]['label'] as String, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WeeklyCompletionChart extends StatelessWidget {
  const _WeeklyCompletionChart();

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
         color: AppColors.surface,
         borderRadius: BorderRadius.circular(24),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('LAST 7 DAYS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
           const SizedBox(height: 24),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.end,
             children: List.generate(7, (index) {
               final heights = [0.4, 0.7, 0.9, 0.5, 0.8, 1.0, 0.6];
               return _Bar(height: 80 * heights[index], label: ['M','T','W','T','F','S','S'][index], active: index == 5);
             }),
           ),
         ],
       ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double height;
  final String label;
  final bool active;
  const _Bar({required this.height, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }
}

class _VoxlyBottomNav extends StatelessWidget {
  final int currentIndex;
  const _VoxlyBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/planner'); break;
          case 2: context.go('/streak'); break;
          case 3: context.go('/settings'); break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Plan'),
        BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Streak'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
