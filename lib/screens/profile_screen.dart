import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validation_utils.dart';
import '../widgets/candy_ui.dart';
import '../widgets/page_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _initializedName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncName(ProfileProvider profileProvider) {
    if (_initializedName) return;
    final name = profileProvider.profile?.displayName;
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
      _initializedName = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authUser = context.watch<AuthProvider>().user;
    final scheme = Theme.of(context).colorScheme;
    _syncName(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: CandyIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CandyBody(
        child: profileProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : PageContainer(
                child: ListView(
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.candyPink,
                                  AppColors.candyRose,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.candyRose.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: scheme.primaryContainer,
                              backgroundImage: profileProvider.profile?.avatarUrl != null
                                  ? NetworkImage(profileProvider.profile!.avatarUrl!)
                                  : null,
                              child: profileProvider.profile?.avatarUrl == null
                                  ? Text(
                                      profileProvider.profile?.initials ?? '?',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Material(
                              color: AppColors.candyRose,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: profileProvider.isSaving ? null : _pickAvatar,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        counterText: '${_nameController.text.length} / 50',
                      ),
                      maxLength: 50,
                      validator: ValidationUtils.validateFullName,
                    ),
                    const SizedBox(height: 14),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.primary.withValues(alpha: 0.12),
                          child: Icon(Icons.email_outlined, color: scheme.primary),
                        ),
                        title: const Text('Email'),
                        subtitle: Text(
                          authUser?.email ?? profileProvider.profile?.email ?? '',
                        ),
                      ),
                    ),
                    if (profileProvider.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        profileProvider.errorMessage!,
                        style: TextStyle(color: scheme.error),
                      ),
                    ],
                    const SizedBox(height: 28),
                    CandyButton(
                      label: 'Save Profile',
                      icon: Icons.favorite_rounded,
                      isLoading: profileProvider.isSaving,
                      onPressed: profileProvider.isSaving
                          ? null
                          : () async {
                              final saved =
                                  await profileProvider.saveProfile(_nameController.text);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    saved ? 'Profile saved' : 'Could not save profile',
                                  ),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final fileName = image.name.isNotEmpty ? image.name : 'avatar.jpg';
    if (!mounted) return;

    final saved = await context.read<ProfileProvider>().uploadAvatar(
          Uint8List.fromList(bytes),
          fileName,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'Profile photo updated' : 'Could not upload photo'),
      ),
    );
  }
}
