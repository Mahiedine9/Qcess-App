import 'package:flutter/material.dart';
import 'package:mobile/features/auth/presentation/widgets/access_code_input_field.dart';
import 'package:mobile/features/auth/presentation/widgets/email_input_field.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController accessCodeController;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.accessCodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmailInputField(controller: emailController),
        const SizedBox(height: 16),
        AccessCodeInputField(controller: accessCodeController),
      ],
    );
  }
}