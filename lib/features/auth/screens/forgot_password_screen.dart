import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twende_bus_ui/core/providers.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _sendResetLink() async {
    // Validate the form before proceeding.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    final authService = ref.read(authServiceProvider);
    final result = await authService.forgotPassword(
      email: _emailController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Determine the message and color based on the result.
    final message = result == "Success"
        ? "Password reset link sent to your email!"
        : result;
    final color = result == "Success"
        ? AppColors.accentColor
        : AppColors.errorColor;

    // Show the snackbar feedback.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));

    // If successful, pop back to the login screen after a short delay.
    if (result == "Success") {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reset your password", style: AppTextStyles.headline1),
              const SizedBox(height: 8),
              Text(
                "Enter your email to receive a password reset link.",
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.subtleTextColor,
                ),
              ),
              const SizedBox(height: 40),
              // Use TextFormField with controller and validator.
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _sendResetLink,
                        child: const Text('Send Reset Link'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
