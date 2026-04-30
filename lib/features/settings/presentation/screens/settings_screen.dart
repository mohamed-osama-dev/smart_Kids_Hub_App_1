import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/hive_service.dart';
import '../../../../core/services/session_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';
import '../../../../utils/app_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  late final Animation<double> _loadingOpacity;

  bool _isLoadingProfile = true;
  String _parentName = '';
  String _parentPhone = '';

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _loadingOpacity = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut));
    _loadParentInfo();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _loadParentInfo() {
    setState(() => _isLoadingProfile = true);
    SessionService.getParentInfo().then((info) {
      if (!mounted) return;
      setState(() {
        _parentName = info['fullName'] ?? '';
        _parentPhone = info['phone'] ?? '';
        _isLoadingProfile = false;
      });
    });
  }

  Future<void> _showAboutSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text('SK', style: AppStyles.bold20White),
                ),
                const SizedBox(height: 12),
                Text('SmartKids Hub', style: AppStyles.bold20Black),
                const SizedBox(height: 6),
                Text('الإصدار 1.0.0', style: AppStyles.regular14Grey),
                const SizedBox(height: 10),
                Text(
                  'تطبيق ذكي لمتابعة نمو وتغذية أطفالك',
                  style: AppStyles.regular14Black,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'support@smartkidshub.com',
                  style: AppStyles.semi14Primary,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إغلاق'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text('تسجيل الخروج', style: AppStyles.bold18Black),
            content: Text(
              'هل أنت متأكد من تسجيل الخروج؟',
              style: AppStyles.regular14Black,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('إلغاء', style: AppStyles.semi14Primary),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.whiteColor,
                ),
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout != true) return;

    await context.read<AuthCubit>().logout();
    await SessionService.clearSession();
    await HiveService.clearChildren();

    if (!mounted) return;
    await Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _parentName.isEmpty ? 'مستخدم SmartKids' : _parentName;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('الإعدادات', style: AppStyles.bold18Black),
          centerTitle: true,
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.whiteColor,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoadingProfile
                            ? AnimatedBuilder(
                                animation: _loadingOpacity,
                                builder: (context, _) {
                                  return Opacity(
                                    opacity: _loadingOpacity.value,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 16,
                                          width: 160,
                                          decoration: BoxDecoration(
                                            color: AppColors.textHint.withValues(
                                              alpha: 0.45,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 14,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            color: AppColors.textHint.withValues(
                                              alpha: 0.45,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: AppStyles.bold18White,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _parentPhone,
                                    style: AppStyles.regular14White,
                                  ),
                                ],
                              ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.profile);
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        iconColor: AppColors.primary,
                        title: 'معلومات الحساب',
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.profile);
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        iconColor: AppColors.secondary,
                        title: 'إشعارات',
                        onTap: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.notifications);
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        iconColor: AppColors.accent,
                        title: 'من نحن',
                        onTap: () {
                          _showAboutSheet();
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: AppColors.playful,
                        title: 'سياسة الخصوصية',
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRoutes.privacy);
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.star_outline,
                        iconColor: AppColors.warning,
                        title: 'تقييم التطبيق',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('شكراً لك! تقييمك يهمنا 🌟'),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _SettingsTile(
                    icon: Icons.logout,
                    iconColor: AppColors.error,
                    title: 'تسجيل الخروج',
                    titleStyle: AppStyles.bold16Black.copyWith(
                      color: AppColors.error,
                    ),
                    showArrow: false,
                    showDivider: false,
                    onTap: () {
                      _confirmLogout();
                    },
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;
  final bool showDivider;
  final TextStyle? titleStyle;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.showArrow = true,
    this.showDivider = true,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle ?? AppStyles.semi16Black,
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textHint,
                  ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderColor,
            ),
        ],
      ),
    );
  }
}

