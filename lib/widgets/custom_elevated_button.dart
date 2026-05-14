import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? iconWidget;
  final MainAxisAlignment? mainAxisAlignment;
  final bool? hasIcon;
  final Color? textColor;
  final TextStyle? textStyle;
  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = Colors.amber,
    this.borderColor = Colors.transparent,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.hasIcon = false,
    this.iconWidget,
    this.textColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(16),

          side: BorderSide(width: 1.5, color: borderColor!),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: mainAxisAlignment!,
        children: [
          if (hasIcon!) iconWidget ?? SizedBox(),

          Text(
            text,
            style: (textStyle ?? AppStyles.bold20White).copyWith(
              color: textColor ?? AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
