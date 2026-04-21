import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';
import '../../../../utils/app_styles.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../cubit/auth_cubit.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AuthCubit>();
    final success = await cubit.setNewPassword(
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.errorMessage ?? 'تعذر تغيير كلمة المرور'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')));
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('تعيين كلمة مرور جديدة'),
          backgroundColor: AppColors.background,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Form(
                    key: _formKey,
                    child: Consumer<AuthCubit>(
                      builder: (context, cubit, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أدخل كلمة المرور الجديدة ثم أكدها',
                              style: AppStyles.regular14Grey,
                            ),
                            const SizedBox(height: 16),
                            ThemedTextField(
                              controller: _passwordController,
                              hintText: '••••••••••••',
                              keyboardType: TextInputType.visiblePassword,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'كلمة المرور مطلوبة';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(),
                            ),
                            const SizedBox(height: 16),
                            ThemedTextField(
                              controller: _confirmPasswordController,
                              hintText: '••••••••••••',
                              keyboardType: TextInputType.visiblePassword,
                              isPassword: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'تأكيد كلمة المرور مطلوب';
                                }
                                if (value != _passwordController.text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(),
                            ),
                            const SizedBox(height: 24),
                            if (cubit.isLoading) ...[
                              const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            CustomElevatedButton(
                              onPressed: cubit.isLoading ? () {} : _handleSubmit,
                              text: cubit.isLoading
                                  ? 'جاري الحفظ...'
                                  : 'حفظ كلمة المرور',
                              backgroundColor: cubit.isLoading
                                  ? AppColors.textHint
                                  : AppColors.primary,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
