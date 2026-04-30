import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.construction,
                size: 64,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 12),
              Text('قريباً...', style: AppStyles.bold20Black),
              const SizedBox(height: 8),
              Text('هذه الميزة قيد التطوير', style: AppStyles.regular14Grey),
            ],
          ),
        ),
      ),
    );
  }
}

