import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../repositories/user_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) => SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _greeting(),
                                style: TextStyle(color: AppColors.textSecond, fontSize: 16),
                              ),
                              Text(
                                user?.name ?? 'Guest',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.surface,
                            child: Icon(Icons.person, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Progress Ring and Stats
                      _ProgressOverview(),
                    ],
                  ),
                ),
              ),
              // Mood Check-in
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _MoodCheckIn(uid: user?.uid ?? ''),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              // Today's Tasks Summary
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today\'s Focus',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => context.go('/planner'),
                        child: const Text('View Full Week'),
                      ),
                    ],
                  ),
                ),
              ),
              // Placeholder Task List
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _TaskItemPlaceholder(index: index),
                    childCount: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _VoxlyBottomNav(currentIndex: 0),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _showAddTaskSheet(BuildContext context) {
      // TODO: Implement Add Task Bottom Sheet
  }
}

class _ProgressOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.15), AppColors.background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const Text('65%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You\'re crushing it!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 4),
              Text('3 tasks left for today', style: TextStyle(color: AppColors.textSecond, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCheckIn extends ConsumerWidget {
  final String uid;
  const _MoodCheckIn({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = ['😴', '😐', '😊', '😄', '🔥'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How\'s your energy today?', style: TextStyle(fontSize: 16, color: Colors.white)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(moods.length, (index) {
            return GestureDetector(
              onTap: () {
                final date = DateTime.now().toIso8601String().split('T')[0];
                ref.read(userRepositoryProvider).logMood(uid, date, index);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Energy logged!'), duration: Duration(seconds: 1)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surface2),
                ),
                child: Text(moods[index], style: const TextStyle(fontSize: 24)),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _TaskItemPlaceholder extends StatelessWidget {
  final int index;
  const _TaskItemPlaceholder({required this.index});

  @override
  Widget build(BuildContext context) {
    final titles = ['Team Standup', 'Review Proposal', 'Call Priya'];
    final times = ['09:00 AM', '02:00 PM', '05:30 PM'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titles[index % 3], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                Text(times[index % 3], style: TextStyle(color: AppColors.textSecond, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: AppColors.textHint),
        ],
      ),
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
