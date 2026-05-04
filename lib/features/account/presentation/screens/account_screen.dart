import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';
import '../../../../utils/app_styles.dart';
import '../../../auth/domain/models/child_profile.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/children_cubit.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _fullName = 'ولي الأمر';
  String _phone = '--';

  @override
  void initState() {
    super.initState();
    _loadParentInfo();
  }

  Future<void> _loadParentInfo() async {
    final parentInfo = await SessionService.getParentInfo();
    if (!mounted) return;
    setState(() {
      _fullName = parentInfo['fullName']?.trim().isNotEmpty == true
          ? parentInfo['fullName']!.trim()
          : 'ولي الأمر';
      _phone = parentInfo['phone']?.trim().isNotEmpty == true
          ? parentInfo['phone']!.trim()
          : '--';
    });
  }

  @override
  Widget build(BuildContext context) {
    final childrenState = context.watch<ChildrenCubit>().state;
    final children = childrenState.children;
    final isChildrenLoading =
        childrenState.status == ChildrenStatus.loading && children.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Center(
                child: Text('حسابي', style: AppStyles.bold20Black),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ParentCard(fullName: _fullName, phone: _phone),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'أطفالي (${children.length})',
                          style: AppStyles.bold18Black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isChildrenLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else ...children.map(_buildChildCard),
                    if (!isChildrenLoading && children.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'لا يوجد أطفال حالياً',
                            style: AppStyles.regular14Grey,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: _onLogoutPressed,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          foregroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, size: 20),
                            const SizedBox(width: 8),
                            Text('تسجيل الخروج', style: AppStyles.bold16Primary.copyWith(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'SmartKids Hub • الإصدار 1.0.0',
                        style: AppStyles.regular12Grey,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(ChildProfile child) {
    return Card(
      elevation: 2,
      color: AppColors.whiteColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLighter,
              child: Text(
                child.genderEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name, style: AppStyles.bold16Black),
                  Text(child.ageLabel, style: AppStyles.regular14Grey),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          label: 'الطول',
                          value: '${child.length.toInt()} سم',
                          icon: Icons.straighten,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoChip(
                          label: 'الوزن',
                          value: '${_formatWeight(child.weight)} كجم',
                          icon: Icons.monitor_weight_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoChip(
                          label: 'الميلاد',
                          value: _formatDate(child.birthDate),
                          icon: Icons.cake_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatWeight(double weight) {
    if (weight % 1 == 0) {
      return weight.toInt().toString();
    }
    return weight.toStringAsFixed(1);
  }

  Future<void> _onLogoutPressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('تأكيد تسجيل الخروج', style: AppStyles.bold16Black),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: AppStyles.regular14Grey,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('إلغاء', style: AppStyles.regular14Grey),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text('تسجيل الخروج', style: AppStyles.bold14Primary.copyWith(color: AppColors.error)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await context.read<AuthCubit>().logout();
    await HiveService.clearChildren();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }
}

class _ParentCard extends StatelessWidget {
  final String fullName;
  final String phone;

  const _ParentCard({
    required this.fullName,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: AppStyles.bold18White),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: AppColors.whiteColor,
                    ),
                    const SizedBox(width: 6),
                    Text(phone, style: AppStyles.regular14White),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.whiteColor, width: 2),
              color: AppColors.whiteColor.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.whiteColor,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.regular12Grey.copyWith(
                    fontSize: 9,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppStyles.bold14Primary.copyWith(
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
