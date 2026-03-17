import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (authController.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(authController.error!),
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_add, size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text('Join BP Monitor',
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Create an account to get started',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textSecondary(context)),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: colorScheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, size: 28),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: colorScheme.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, size: 28),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, size: 28),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 28),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      helperText: 'At least 6 characters',
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter a password';
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 28),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 28),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  Consumer<AuthController>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          minimumSize: const Size.fromHeight(60),
                        ),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 3, color: Colors.white))
                            : const Text('Create Account'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: colorScheme.onSurface)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Sign In',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
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
}
