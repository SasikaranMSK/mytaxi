import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../viewmodel/login_view_model.dart';
import 'login_button.dart';
import 'remember_me_checkbox.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const String _rememberMeKey = 'remember_me_checked';

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  LoginViewModel _vm = LoginViewModel.initial();

  @override
  void initState() {
    super.initState();
    _username.addListener(_syncVm);
    _password.addListener(_syncVm);
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRememberMe = prefs.getBool(_rememberMeKey);
    if (!mounted) return;

    setState(() {
      _vm = _vm.copyWith(rememberMe: savedRememberMe == true);
    });
  }

  void _syncVm() {
    final next = _vm.copyWith(
      username: _username.text,
      password: _password.text,
    );
    if (next.username == _vm.username && next.password == _vm.password) return;
    setState(() => _vm = next);
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toggleObscure() {
    setState(() => _vm = _vm.copyWith(obscure: !_vm.obscure));
  }

  Future<void> _toggleRemember(bool value) async {
    setState(() => _vm = _vm.copyWith(rememberMe: value));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  void _submit(AuthState state) {
    if (state is AuthLoading) return;

    if (_autovalidateMode == AutovalidateMode.disabled) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    context.read<AuthBloc>().add(
          LoginRequested(_vm.usernameValue, _vm.passwordValue),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login to continue',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  _input(
                    controller: _username,
                    hint: 'Username',
                    icon: Icons.person_outline,
                    validator: (value) =>
                        LoginViewModel.validateUsername(value ?? ''),
                  ),
                  const SizedBox(height: 16),
                  _input(
                    controller: _password,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscure: _vm.obscure,
                    validator: (value) =>
                        LoginViewModel.validatePassword(value ?? ''),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _vm.obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: _toggleObscure,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RememberMeCheckbox(
                          value: _vm.rememberMe,
                          onChanged: (value) {
                            _toggleRemember(value);
                          },
                        ),
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      return LoginButton(
                        loading: loading,
                        onPressed: () => _submit(state),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create an account',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A32),
        title: const Text(
          'Reset Password',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final email = controller.text.trim();
              if (email.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reset link sent to $email')),
                );
              }
            },
            child: const Text('Send link'),
          ),
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }
}
