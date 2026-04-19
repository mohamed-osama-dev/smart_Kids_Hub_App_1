import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/app_routes.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../../../../widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '012345678');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.parentInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top illustration area
                        SizedBox(
                          height: isKeyboardVisible
                              ? screenHeight * 0.2
                              : screenHeight * 0.35,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(32),
                              bottomRight: Radius.circular(32),
                            ),
                            child: Image.asset(
                              'assets/images/login_bg.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  color: AppColors.primaryLighter,
                                  child: Icon(
                                    Icons.family_restroom,
                                    size: isKeyboardVisible ? 50 : 80,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Bottom form card
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Card(
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: isKeyboardVisible ? 16 : 24,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Title
                                      Text(
                                        'تسجيل الدخول',
                                        style: AppStyles.bold22Black,
                                      ),
                                      SizedBox(
                                        height: isKeyboardVisible ? 4 : 8,
                                      ),
                                      Text(
                                        'مرحباً بعودتك!',
                                        style: AppStyles.regular14Grey,
                                      ),
                                      SizedBox(
                                        height: isKeyboardVisible ? 16 : 24,
                                      ),
                                      // Phone field
                                      ThemedTextField(
                                        controller: _phoneController,
                                        hintText: '1012345678',
                                        keyboardType: TextInputType.phone,
                                        prefixText: '+20 ',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'رقم الهاتف مطلوب';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(),
                                      ),
                                      SizedBox(
                                        height: isKeyboardVisible ? 12 : 16,
                                      ),
                                      // Password field
                                      ThemedTextField(
                                        controller: _passwordController,
                                        hintText: '••••••••••••',
                                        keyboardType:
                                            TextInputType.visiblePassword,
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
                                      SizedBox(
                                        height: isKeyboardVisible ? 8 : 12,
                                      ),
                                      // Forgot password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            // TODO: Navigate to forgot password
                                          },
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(0, 44),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            'نسيت كلمة المرور؟',
                                            style: AppStyles.semi14Primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: isKeyboardVisible ? 12 : 16,
                                      ),
                                      // Login button
                                      CustomElevatedButton(
                                        onPressed: _handleLogin,
                                        text: 'تسجيل الدخول',
                                        backgroundColor: AppColors.primary,
                                      ),
                                      SizedBox(
                                        height: isKeyboardVisible ? 8 : 16,
                                      ),
                                      // Sign up link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'ليس لديك حساب؟ ',
                                            style: AppStyles.regular14Grey,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pushNamed(AppRoutes.parentInfo);
                                            },
                                            style: TextButton.styleFrom(
                                              minimumSize: const Size(0, 44),
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: Text(
                                              'إنشاء حساب جديد',
                                              style: AppStyles.semi14Primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
