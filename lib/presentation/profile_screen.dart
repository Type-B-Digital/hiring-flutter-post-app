import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:post_app/provider/auth_provider.dart';
import 'package:post_app/utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in.')));
    }

    final fullName = '${user.firstName} ${user.lastName}';
    final initials = '${user.firstName[0]}${user.lastName[0]}'.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                fullName,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(Icons.power_settings_new_rounded, color: AppColors.critical),
                  label: const Text('Log out', style: TextStyle(color: AppColors.critical)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
