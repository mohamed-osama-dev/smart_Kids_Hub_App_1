import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ThemedTextField extends StatefulWidget {
  const ThemedTextField({
    super.key,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.prefixText,
    this.prefixIcon,
    required this.hintText,
    this.validator,
    this.isPassword = false,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.decoration = const InputDecoration(),
  });

  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final String? prefixText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool isPassword;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final InputDecoration decoration;

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {
  late bool _isObscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
      cursorColor: AppColors.primary,
      validator: widget.validator,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      obscureText: _isObscure,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: widget.decoration.copyWith(
        hintText: widget.hintText,
        prefixText: widget.prefixText,
        prefixStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
              )
            : widget.decoration.suffixIcon,
      ),
    );
  }
}
