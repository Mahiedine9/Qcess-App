import 'package:flutter/material.dart';
import 'package:mobile/core/presentation/widgets/custom_text_field.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputField({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: 'Entrez votre adresse électronique',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }
    return null;
  }
}