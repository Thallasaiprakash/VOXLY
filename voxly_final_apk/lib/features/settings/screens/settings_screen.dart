import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/colors.dart';
import '../../../repositories/user_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _ProfileSection(name: user?.name ?? 'Guest'),
            const SizedBox(height: 32),
            _SettingsGroup(
              title: 'VOICE SETTINGS',
              items: [
                _SettingsTile(
                  icon: Icons.record_voice_over,
                  title: 'Enable Voice Greeting',
                  trailing: Switch(
                    value: user?.settings['voiceEnabled'] ?? true,
                    onChanged: (val) {},
                    activeColor: AppColors.primary,
                  ),
                ),
                _SettingsTile(
                  icon: Icons.speed,
                  title: 'Voice Speed',
                  subtitle: 'Normal',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: 'OVERLAY & FOCUS',
              items: [
                _SettingsTile(
                  icon: Icons.layers,
                  title: 'Show Overlay on Unlock',
                  subtitle: 'Every Unlock',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.nights_stay,
                  title: 'Quiet Hours',
                  subtitle: '22:00 - 07:00 (Visual only)',
                  onTap: () {},
                ),
              ],
            ),
             const SizedBox(height: 24),
            _SettingsGroup(
              title: 'APP PREFERENCES',
              items: [
                _SettingsTile(
                  icon: Icons.calendar_today,
                  title: 'Week Starts On',
                  subtitle: 'Monday',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.color_lens,
                  title: 'Theme',
                  subtitle: 'Deep Dark (Default)',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
             _SettingsTile(
                icon: Icons.info_outline,
                title: 'Privacy Policy',
                onTap: () {},
              ),
               _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                titleColor: AppColors.danger,
                onTap: () {},
              ),
              const SizedBox(height: 48),
              const Center(
                child: Text(
                  'VOXLY v1.0.0',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: const _VoxlyBottomNav(currentIndex: 3),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String name;
  const _ProfileSection({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.surface2,
            child: Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Personal Account', style: TextStyle(color: AppColors.textSecond, fontSize: 14)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryLight, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(color: AppColors.textSecond, letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primaryLight, size: 20),
      ),
      title: Text(title, style: TextStyle(color: titleColor ?? Colors.white, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: AppColors.textSecond, fontSize: 12)) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.textHint) : null),
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
