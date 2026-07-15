import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/candy_ui.dart';
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
    final authProvider = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;
    final isSigningOut = authProvider.isSigningOut;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: CandyIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CandyBody(
        child: PageContainer(
          child: ListView(
            children: [
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primary.withValues(alpha: 0.12),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: scheme.primary,
                        ),
                      ),
                      title: const Text('Local notifications'),
                      subtitle: const Text(
                        'Note reminders are scheduled on this device',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primary.withValues(alpha: 0.12),
                        child: Icon(Icons.info_outline_rounded, color: scheme.primary),
                      ),
                      title: const Text('About NoteVault'),
                      subtitle: const Text(
                        'CC106 Final Project — candy pink notes + Life Spaces',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.18)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.error.withValues(alpha: 0.12),
                    child: Icon(Icons.logout_rounded, color: scheme.error),
                  ),
                  title: Text(
                    'Log out',
                    style: TextStyle(
                      color: scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text('Sign out of your account'),
                  enabled: !isSigningOut,
                  onTap: isSigningOut ? null : () => _confirmSignOut(context),
                  trailing: isSigningOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.chevron_right_rounded, color: scheme.error),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Made with candy pink love',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.candyRose.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
