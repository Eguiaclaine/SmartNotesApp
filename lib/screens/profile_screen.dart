import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/validation_utils.dart';
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
      appBar: AppBar(title: const Text('Profile')),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageContainer(
              child: ListView(
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 56,
                          backgroundColor: scheme.primaryContainer,
                          backgroundImage: profileProvider.profile?.avatarUrl != null
                              ? NetworkImage(profileProvider.profile!.avatarUrl!)
                              : null,
                          child: profileProvider.profile?.avatarUrl == null
                              ? Text(
                                  profileProvider.profile?.initials ?? '?',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: scheme.primary,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: profileProvider.isSaving ? null : _pickAvatar,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
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
                      counterText: '${_nameController.text.length} / 50',
                    ),
                    maxLength: 50,
                    validator: ValidationUtils.validateFullName,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.email_outlined, color: scheme.primary),
                    title: const Text('Email'),
                    subtitle: Text(authUser?.email ?? profileProvider.profile?.email ?? ''),
                  ),
                  if (profileProvider.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      profileProvider.errorMessage!,
                      style: TextStyle(color: scheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: profileProvider.isSaving
                        ? null
                        : () async {
                            final saved = await profileProvider.saveProfile(_nameController.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(saved ? 'Profile saved' : 'Could not save profile'),
                              ),
                            );
                          },
                    child: profileProvider.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Text('Save Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
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
      SnackBar(content: Text(saved ? 'Profile photo updated' : 'Could not upload photo')),
    );
  }
}
