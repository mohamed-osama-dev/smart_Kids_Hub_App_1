import 'package:flutter/material.dart';

class ThemedTextField extends StatefulWidget {
  const ThemedTextField({
    super.key,
    this.controller,
    this.keyboardType = TextInputType.visiblePassword,
    this.prefixWidget,
    this.prefixText,
    required this.hintText,
    this.prefixIconPath,
    this.validator,
    this.isPassword = false,
    this.onChanged,
    this.onSaved,
    this.maxLines = 1,
    this.color,
  });

  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Widget? prefixWidget;
  final String? prefixIconPath;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;

  final bool isPassword;
  final int maxLines;
  final Color? color;

  final String? prefixText;

  @override
  State<ThemedTextField> createState() => _ThemedTextFieldState();
}

class _ThemedTextFieldState extends State<ThemedTextField> {
  late bool isObscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return TextFormField(
      style: textTheme.titleMedium,
      cursorColor: Colors.amber,
      validator: widget.validator,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      obscureText: isObscure,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        prefix: widget.prefixWidget,
        prefixText: widget.prefixText,

        hintText: widget.hintText,

        contentPadding: const EdgeInsetsDirectional.only(
          top: 16,
          bottom: 16,
          start: 16,
        ),
        prefixIcon: widget.prefixIconPath != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 19, end: 10),
                // child: SvgPicture.asset(
                //   widget.prefixIconPath!,
                //   colorFilter: ColorFilter.mode(
                //     widget.color == null ? AppTheme.white : widget.color!,
                //     BlendMode.srcIn,
                //   ),
                // ),
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: Icon(
                  isObscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.amber,
                ),
              )
            : null,
        suffixIconColor: Colors.amber,
      ),
    );
  }
}
