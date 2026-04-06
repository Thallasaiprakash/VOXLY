import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen> {
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0-6 (Mon-Sun)
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Weekly Planner',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.history, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Day Tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_days.length, (index) {
                  final isSelected = _selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isSelected ? Colors.transparent : AppColors.surface2),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
                      ),
                      child: Text(
                        _days[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecond,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Task List for Selected Day
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _TaskCard(index: index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        label: const Text('New Task'),
        icon: const Icon(Icons.add),
      ),
      bottomNavigationBar: const _VoxlyBottomNav(currentIndex: 1),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
      // TODO: Implement Add Task Bottom Sheet
  }
}

class _TaskCard extends StatelessWidget {
  final int index;
  const _TaskCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final Map<int, Map<String, dynamic>> dummyTasks = {
      0: {'title': 'Morning Meditation', 'time': '07:30 AM', 'cat': 'Health', 'pri': 'Normal'},
      1: {'title': 'Project Sync', 'time': '10:00 AM', 'cat': 'Work', 'pri': 'High'},
      2: {'title': 'Buy Groceries', 'time': '04:00 PM', 'cat': 'Personal', 'pri': 'Normal'},
      3: {'title': 'Interview Prep', 'time': '08:00 PM', 'cat': 'Work', 'pri': 'Critical'},
    };

    final task = dummyTasks[index]!;
    final priorityColor = task['pri'] == 'Critical' ? AppColors.danger : (task['pri'] == 'High' ? AppColors.warning : AppColors.primary);

    return Dismissible(
      key: Key('task_$index'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
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
                  Row(
                    children: [
                       Text(
                        task['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      if (task['pri'] == 'Critical') const Icon(Icons.warning, color: AppColors.danger, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: AppColors.textSecond),
                      const SizedBox(width: 4),
                      Text(task['time'], style: TextStyle(color: AppColors.textSecond, fontSize: 12)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8)),
                        child: Text(task['cat'], style: TextStyle(color: AppColors.textSecond, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.drag_handle, color: AppColors.textHint),
          ],
        ),
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
