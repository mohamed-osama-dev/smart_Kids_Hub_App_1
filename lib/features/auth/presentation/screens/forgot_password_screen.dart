import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_routes.dart';
import '../../../../utils/app_styles.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../cubit/auth_cubit.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AuthCubit>();
    final success = await cubit.forgotPassword(
      phoneNumber: _phoneController.text.trim(),
    );
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.errorMessage ?? 'تعذر إرسال الرمز')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.otpVerification,
      arguments: OTPVerificationArgs(
        phoneNumber: _phoneController.text.trim(),
        isPasswordReset: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('نسيت كلمة المرور'),
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
                              'أدخل رقم هاتفك لإرسال رمز التحقق',
                              style: AppStyles.regular14Grey,
                            ),
                            const SizedBox(height: 16),
                            ThemedTextField(
                              controller: _phoneController,
                              hintText: '1012345678',
                              keyboardType: TextInputType.phone,
                              prefixText: '+20 ',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'رقم الهاتف مطلوب';
                                }
                                final digits = value.replaceAll(RegExp(r'\D'), '');
                                final validLength =
                                    digits.length == 10 ||
                                    (digits.length == 11 &&
                                        digits.startsWith('0'));
                                if (!validLength) {
                                  return 'رقم الهاتف غير صحيح';
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
                                  ? 'جاري الإرسال...'
                                  : 'إرسال الرمز',
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
