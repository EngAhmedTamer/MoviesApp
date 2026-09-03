import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_app/core/di/app_dependencies.dart';
import 'package:movies_app/core/theme/app_colors.dart';
import 'package:movies_app/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:movies_app/features/auth/presentation/cubit/profile_state.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_app_bar.dart';
import 'package:movies_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:movies_app/features/auth/presentation/widgets/avatar_selector.dart';
import 'package:movies_app/shared/widgets/movies_primary_button.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = context.read<AppDependencies>();

    return BlocProvider<ProfileCubit>(
      create: (context) => dependencies.createProfileCubit()..loadCurrentUser(),
      child: const _UpdateProfileView(),
    );
  }
}

class _UpdateProfileView extends StatefulWidget {
  const _UpdateProfileView();

  @override
  State<_UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<_UpdateProfileView> {
  static const _avatars = [
    'assets/images/auth/avatar_03.png',
    'assets/images/auth/avatar_01.png',
    'assets/images/auth/avatar_02.png',
    'assets/images/auth/avatar_04.png',
    'assets/images/auth/avatar_05.png',
    'assets/images/auth/avatar_06.png',
    'assets/images/auth/avatar_07.png',
    'assets/images/auth/avatar_08.png',
    'assets/images/auth/avatar_09.png',
  ];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  int _selectedAvatarIndex = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<ProfileCubit>().updateProfile(
          name: name,
          phoneNumber: phone,
          avatarId: _avatars[_selectedAvatarIndex],
        );
  }

  void _onDeletePressed() {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<ProfileCubit>().deleteAccount();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.ready && state.user != null) {
          _nameController.text = state.user!.name!;
          _phoneController.text = state.user!.phoneNumber!;
          final avatarIndex = _avatars.indexOf(state.user!.avatarId!);
          if (avatarIndex != -1) {
            setState(() => _selectedAvatarIndex = avatarIndex);
          }
        } else if (state.status == ProfileStatus.deleted) {
          context.go('/');
        } else if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Update failed'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AuthAppBar(
            title: 'Update Profile',
            onBack: state.isSubmitting ? () {} : () => context.pop(),
          ),
          body: state.status == ProfileStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  top: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight - 32),
                          child: Column(
                            children: [
                              AvatarSelector(
                                avatarAssetPaths: _avatars,
                                selectedIndex: _selectedAvatarIndex,
                                onSelected: (index) {
                                  setState(() => _selectedAvatarIndex = index);
                                },
                              ),
                              const SizedBox(height: 12),
                              AuthTextField(
                                controller: _nameController,
                                hintText: 'Name',
                                prefixIcon: Icons.badge_outlined,
                                textInputAction: TextInputAction.next,
                                enabled: !state.isSubmitting,
                              ),
                              const SizedBox(height: 24),
                              AuthTextField(
                                controller: _phoneController,
                                hintText: 'Phone Number',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                enabled: !state.isSubmitting,
                              ),
                              const SizedBox(height: 24),
                              MoviesPrimaryButton(
                                label: state.isSubmitting
                                    ? 'Updating...'
                                    : 'Update Data',
                                onPressed:
                                    state.isSubmitting ? null : _onUpdatePressed,
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: OutlinedButton(
                                  onPressed: state.isSubmitting
                                      ? null
                                      : _onDeletePressed,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(color: AppColors.error),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text('Delete Account'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
