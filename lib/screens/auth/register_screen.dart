import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _authProvider.register(
      _nameController.text.trim(),
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
      appBar: AppBar(
        title: const Text(AppStrings.register),
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez SunuTask et organisez vos projets',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: AppStrings.name,
                  controller: _nameController,
                  hint: 'Votre nom complet',
                  prefixIcon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty) return AppStrings.nameRequired;
                    if (v.trim().length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'La confirmation est requise';
                    }
                    if (v != _passwordController.text) {
                      return AppStrings.passwordsNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ListenableBuilder(
                  listenable: _authProvider,
                  builder: (_, __) => CustomButton(
                    text: AppStrings.register,
                    isLoading: _authProvider.isLoading,
                    onPressed: _register,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: '${AppStrings.haveAccount} ',
                        style: TextStyle(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: AppStrings.login,
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
