import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled3/core/constants/constants.dart';
import 'package:untitled3/core/util/app_route.dart';
import 'package:untitled3/features/account/domain/entities/update_account_entity.dart';
import '../blocs/account_cubit.dart';
import '../blocs/account_state.dart';

class AccountPage extends StatefulWidget {
  final String prevPath;

  const AccountPage({super.key, required this.prevPath});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<AccountCubit>();
    _cubit.fetchCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimaryColor, kBackgroundColor],
            ),
          ),
          child: BlocConsumer<AccountCubit, AccountState>(
            listener: (context, state) {
              if (state.status == AccountStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile updated'),
                    backgroundColor: kPrimaryColor,
                  ),
                );
              } else if (state.status == AccountStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error ?? 'Update failed'),
                    backgroundColor: kErrorColor,
                  ),
                );
              }
            },
            builder: (context, state) {
              // Show spinner while loading initial user or during any update
              if (state.status == AccountStatus.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(kTextLight),
                    strokeWidth: 3.0,
                    backgroundColor: kBackgroundColor,
                  ),
                );
              }

              // Render form with current state values
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Back button
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: kTextLight),
                              onPressed: () {
                                if (widget.prevPath.isNotEmpty) {
                                  GoRouter.of(context).push(widget.prevPath);
                                } else {
                                  GoRouter.of(context).pop();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          "Account",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: kTextLight,
                            fontFamily: kFont,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Avatar
                        GestureDetector(
                          onTap: () => context.read<AccountCubit>().updateProfileImage(),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: kTextLight, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: state.imageUrl == null || state.imageUrl!.isEmpty
                                  ? const AssetImage('assets/paper.png')
                                  : CachedNetworkImageProvider(state.imageUrl!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // User name
                        Text(
                          '${state.firstName ?? ''} ${state.lastName ?? ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kTextLight,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Email
                        Text(
                          state.email ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: kTextLight,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // First Name Field
                        _buildStyledField(
                          context: context,
                          label: "First Name",
                          value: state.firstName ?? '',
                          icon: Icons.person,
                          onSave: (v) => _updateField(context, state, firstName: v),
                        ),
                        const SizedBox(height: 16),

                        // Last Name Field
                        _buildStyledField(
                          context: context,
                          label: "Last Name",
                          value: state.lastName ?? '',
                          icon: Icons.person_outline,
                          onSave: (v) => _updateField(context, state, lastName: v),
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        _buildStyledField(
                          context: context,
                          label: "Email",
                          value: state.email ?? '',
                          icon: Icons.email,
                          onSave: (v) => _updateField(context, state, email: v),
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth Field
                        _buildStyledField(
                          context: context,
                          label: "Date of Birth",
                          value: state.dob != null ? state.dob!.toIso8601String().split('T').first : '',
                          icon: Icons.calendar_today,
                          onSave: (v) {
                            final d = DateTime.tryParse(v);
                            if (d != null) _updateField(context, state, dob: d);
                          },
                        ),
                        const SizedBox(height: 30),

                        // Save Changes Button (optional - you can remove if not needed)
                        ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).pushReplacement(AppRoute.homePath);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Helper to show the edit dialog and then dispatch the cubit call,
  /// passing only the field(s) that changed.
  void _updateField(
      BuildContext context,
      AccountState state, {
        String? firstName,
        String? lastName,
        String? email,
        DateTime? dob,
      }) {
    final updated = UpdateAccountEntity(
      username: state.username!,
      firstName: firstName ?? state.firstName!,
      lastName: lastName ?? state.lastName!,
      email: email ?? state.email!,
      dateOfBirth: dob ?? state.dob!,
    );
    context.read<AccountCubit>().updateUserInfo(updated);
  }

  Widget _buildStyledField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required void Function(String) onSave,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: kBorderColor, width: 1.0),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: kTextPrimary),
        title: Text(
          label,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? 'Tap to add $label' : value,
          style: TextStyle(
            color: value.isEmpty ? kTextLight.withOpacity(0.7) : kTextLight,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.edit, color: kTextPrimary),
        onTap: () => _showStyledEditDialog(context, label, value, onSave),
      ),
    );
  }

  void _showStyledEditDialog(
      BuildContext context,
      String label,
      String current,
      void Function(String) onSave,
      ) {
    final ctl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          'Edit $label',
          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctl,
          cursorColor: kTextPrimary,
          style: const TextStyle(color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new $label',
            hintStyle: TextStyle(color: kTextPrimary.withOpacity(0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: kTextPrimary, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: kBorderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(color: kTextPrimary, width: 2.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kTextPrimary)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(ctl.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}