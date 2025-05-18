import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled3/core/constants/constants.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Account'),
          backgroundColor: kPrimarycolor,
        ),
        body: BlocConsumer<AccountCubit, AccountState>(
          listener: (context, state) {
            if (state.status == AccountStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated')),
              );
            } else if (state.status == AccountStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error ?? 'Update failed')),
              );
            }
          },
          builder: (context, state) {
            // Show spinner while loading initial user or during any update
            if (state.status == AccountStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Render form with current state values
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar
                Center(
                  child: GestureDetector(
                    onTap: () => context.read<AccountCubit>().updateProfileImage(),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: state.imageUrl == null || state.imageUrl!.isEmpty? const AssetImage('assets/paper.png') : CachedNetworkImageProvider(state.imageUrl!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '${state.firstName ?? ''} ${state.lastName ?? ''}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(state.email ?? '', style: const TextStyle(color: Colors.grey)),
                ),

                const SizedBox(height: 24),
                const Divider(),

                // First Name
                _buildEditableField(
                  context: context,
                  label: "First Name",
                  value: state.firstName ?? '',
                  icon: Icons.person,
                  onSave: (v) => _updateField(context, state, firstName: v),
                ),

                // Last Name
                _buildEditableField(
                  context: context,
                  label: "Last Name",
                  value: state.lastName ?? '',
                  icon: Icons.person_outline,
                  onSave: (v) => _updateField(context, state, lastName: v),
                ),

                // Email
                _buildEditableField(
                  context: context,
                  label: "Email",
                  value: state.email ?? '',
                  icon: Icons.email,
                  onSave: (v) => _updateField(context, state, email: v),
                ),

                // Date of Birth
                _buildEditableField(
                  context: context,
                  label: "Date of Birth",
                  value: state.dob != null ? state.dob!.toIso8601String().split('T').first : '',
                  icon: Icons.calendar_today,
                  onSave: (v) {
                    final d = DateTime.tryParse(v);
                    if (d != null) _updateField(context, state, dob: d);
                  },
                ),


            ElevatedButton.icon(
            icon: const Icon(
                Icons.arrow_back,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimarycolor,
            ),
            label: const Text('Back',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
            if (widget.prevPath.isNotEmpty) {
              GoRouter.of(context).push(widget.prevPath);
            }
            else {
              throw Exception("No prev path provided");
            }
            },
            ),
              ],
            );
          },
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
      firstName: firstName   ?? state.firstName!,
      lastName:  lastName    ?? state.lastName!,
      email:     email       ?? state.email!,
      dateOfBirth: dob       ?? state.dob!,
    );
    context.read<AccountCubit>().updateUserInfo(updated);
  }

  Widget _buildEditableField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required void Function(String) onSave,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: kPrimarycolor),
          title: Text(label),
          subtitle: Text(value),
          trailing: const Icon(Icons.edit),
          onTap: () => _showEditDialog(context, label, value, onSave),
        ),
        const Divider(),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context,
      String label,
      String current,
      void Function(String) onSave,
      ) {
    final ctl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(controller: ctl, decoration: InputDecoration(hintText: 'Enter new $label')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onSave(ctl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
