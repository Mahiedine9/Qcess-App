import 'package:flutter/material.dart';
import 'package:mobile/core/presentation/widgets/custom_text_field.dart';
import 'package:mobile/core/theme/app_colors.dart';

class AccessCodeInputField extends StatefulWidget {
  final TextEditingController controller;

  const AccessCodeInputField({
    required this.controller,
    super.key,
  });

  @override
  State<AccessCodeInputField> createState() => _AccessCodeInputFieldState();
}

class _AccessCodeInputFieldState extends State<AccessCodeInputField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      hintText: 'Entrez votre code d\'accès',
      prefixIcon: Icons.vpn_key_outlined,
      obscureText: !_isVisible,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.text,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textHint,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _isVisible = !_isVisible;
          });
        },
      ),
      validator: _validateAccessCode,
    );
  }

  String? _validateAccessCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre code d\'accès';
    }
    if (value.length < 4) {
      return 'Le code d\'accès doit contenir au moins 4 caractères';
    }
    return null;
  }
}