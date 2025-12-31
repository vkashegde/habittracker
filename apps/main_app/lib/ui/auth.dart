import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main_app/cubits/auth_cubit.dart';

/// Minimal login/profile UI using shared Supabase-backed repositories.
class AuthSection extends StatefulWidget {
  const AuthSection({super.key});

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLogin = true;

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email and password are required.')));
      return;
    }

    if (_isLogin) {
      await context.read<AuthCubit>().signIn(email, password);
    } else {
      await context.read<AuthCubit>().signUp(email, password);
    }
  }

  Future<void> _saveProfile() async {
    await context.read<AuthCubit>().saveProfile(_displayNameController.text.trim());
  }

  Future<void> _signOut() async {
    await context.read<AuthCubit>().signOut();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final isLoading = state.isLoading;
        final profile = state.profile;

        if (user != null && profile != null) {
          _displayNameController.text =
              profile['display_name'] as String? ?? _displayNameController.text;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Authentication',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (user != null) Text(user.email ?? '', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                  ),
                if (user == null) ...[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Switch(
                        value: _isLogin,
                        onChanged: isLoading
                            ? null
                            : (v) {
                                setState(() => _isLogin = v);
                              },
                      ),
                      Text(_isLogin ? 'Login' : 'Sign up'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitAuth,
                    child: Text(_isLogin ? 'Login' : 'Sign up'),
                  ),
                ] else ...[
                  TextField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(labelText: 'Display name'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    child: const Text('Save profile'),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Profile: ${profile['display_name'] ?? ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(onPressed: isLoading ? null : _signOut, child: const Text('Sign out')),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
