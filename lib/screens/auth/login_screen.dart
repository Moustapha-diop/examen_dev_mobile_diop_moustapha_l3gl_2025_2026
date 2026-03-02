import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/auth/register_screen.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.error ?? AppStrings.error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.task_alt,
                        size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  AppStrings.login,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bienvenue sur SunuTask',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  hint: 'exemple@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.emailRequired;
                    if (!v.contains('@') || !v.contains('.')) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (v.length < 6) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ListenableBuilder(
                  listenable: _authProvider,
                  builder: (_, __) => CustomButton(
                    text: AppStrings.login,
                    isLoading: _authProvider.isLoading,
                    onPressed: _login,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        text: '${AppStrings.noAccount} ',
                        style: TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: AppStrings.register,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
