import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/parent.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/app_routes.dart';
import '../widgets/step_progress_indicator.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../cubit/auth_cubit.dart';
import 'otp_verification_screen.dart';

class ParentInfoScreen extends StatefulWidget {
  const ParentInfoScreen({super.key});

  @override
  State<ParentInfoScreen> createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'أحمد محمد علي');
  final _phoneController = TextEditingController(text: '01012345678');
  final _passwordController = TextEditingController(text: 'password123');
  final _confirmPasswordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNext() async {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<AuthCubit>();
      final success = await cubit.registerParent(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      if (success) {
        final parent = Parent(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        Navigator.of(
          context,
        ).pushNamed(
          AppRoutes.otpVerification,
          arguments: OTPVerificationArgs(
            parent: parent,
            phoneNumber: parent.phone,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(cubit.errorMessage ?? 'حدث خطأ، حاول مجدداً')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              const StepProgressIndicator(currentStep: 1, totalSteps: 2),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('معلومات ولي الأمر', style: AppStyles.bold20Black),
                    const SizedBox(height: 4),
                    Text('الخطوة 1 من 2', style: AppStyles.regular12Grey),
                  ],
                ),
              ),
              // Form content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight:
                              constraints.maxHeight -
                              MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar icon
                                Center(
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLighter,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      size: 40,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Full name
                                _buildFieldLabel('الاسم الكامل'),
                                const SizedBox(height: 8),
                                ThemedTextField(
                                  controller: _nameController,
                                  hintText: 'أدخل اسمك الكامل',
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الاسم الكامل مطلوب';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(),
                                ),
                                const SizedBox(height: 16),
                                // Phone number
                                _buildFieldLabel('رقم الهاتف'),
                                const SizedBox(height: 8),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: ThemedTextField(
                                    controller: _phoneController,
                                    hintText: '1012345678',
                                    keyboardType: TextInputType.phone,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    prefixText: '+20 ',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'رقم الهاتف مطلوب';
                                      }
                                      final digits = value.replaceAll(
                                        RegExp(r'\D'),
                                        '',
                                      );
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
                                ),
                                const SizedBox(height: 16),
                                // Password
                                _buildFieldLabel('كلمة المرور'),
                                const SizedBox(height: 8),
                                ThemedTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••••',
                                  keyboardType: TextInputType.visiblePassword,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
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
                                // Confirm password
                                _buildFieldLabel('تأكيد كلمة المرور'),
                                const SizedBox(height: 8),
                                ThemedTextField(
                                  controller: _confirmPasswordController,
                                  hintText: '••••••••••',
                                  keyboardType: TextInputType.visiblePassword,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
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
                                // Next button
                                Consumer<AuthCubit>(
                                  builder: (context, cubit, _) {
                                    return CustomElevatedButton(
                                      onPressed: cubit.isLoading
                                          ? () {}
                                          : _handleNext,
                                      text: cubit.isLoading ? 'جاري المتابعة...' : 'التالي',
                                      backgroundColor: cubit.isLoading
                                          ? AppColors.textHint
                                          : AppColors.primary,
                                      hasIcon: true,
                                      iconWidget: const Icon(
                                        Icons.arrow_back_ios,
                                        color: AppColors.whiteColor,
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: AppStyles.regular14Grey);
  }
}
