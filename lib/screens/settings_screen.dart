import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/page_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isTransitioning) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to the sign-in screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await authProvider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isSigningOut = authProvider.isSigningOut;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: PageContainer(
        child: ListView(
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Saved locally with SharedPreferences'),
                    secondary: Icon(
                      themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: scheme.primary,
                    ),
                    value: themeProvider.isDark,
                    onChanged: isSigningOut ? null : (_) => themeProvider.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications_active_outlined, color: scheme.primary),
                    title: const Text('Local notifications'),
                    subtitle: const Text('Note reminders are scheduled on this device'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info_outline_rounded, color: scheme.primary),
                    title: const Text('About NoteVault'),
                    subtitle: const Text('CC106 Final Project — candy pink notes + Life Spaces'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.logout_rounded, color: scheme.error),
                title: const Text('Log out'),
                subtitle: const Text('Sign out of your account'),
                enabled: !isSigningOut,
                onTap: isSigningOut ? null : () => _confirmSignOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
