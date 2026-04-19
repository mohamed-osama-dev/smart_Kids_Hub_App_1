import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/parent.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/app_routes.dart';
import '../widgets/step_progress_indicator.dart';
import '../../../../widgets/custom_elevated_button.dart';

class OTPVerificationScreen extends StatefulWidget {
  final Parent parent;

  const OTPVerificationScreen({super.key, required this.parent});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool _isVerifying = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOTPCChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  String _getOTP() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _handleVerify() {
    final otp = _getOTP();
    if (otp.length == 4) {
      setState(() => _isVerifying = true);

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isVerifying = false);
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.childInfo, arguments: widget.parent);
        }
      });
    }
  }

  void _handleResendOTP() {
    // TODO: Resend OTP logic
  }

  @override
  Widget build(BuildContext context) {
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
                        // Progress indicator
                        const StepProgressIndicator(
                          currentStep: 2,
                          totalSteps: 2,
                        ),
                        // Icon
                        SizedBox(height: isKeyboardVisible ? 16 : 32),
                        Container(
                          width: isKeyboardVisible ? 70 : 100,
                          height: isKeyboardVisible ? 70 : 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            size: isKeyboardVisible ? 35 : 50,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 12 : 24),
                        // Title
                        Text(
                          'تحقق من رمز التأكيد',
                          style: AppStyles.bold22Black,
                        ),
                        SizedBox(height: isKeyboardVisible ? 4 : 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'لقد أرسلنا رمز تأكيد برسالة واتساب إلى',
                            style: AppStyles.regular14Grey,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 4 : 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLighter,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.parent.phone,
                            style: AppStyles.bold16Primary,
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 4 : 8),
                        TextButton(
                          onPressed: () {
                            // TODO: Edit phone number
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'إدخل الرمز في الأسفل',
                            style: AppStyles.semi14Primary,
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 16 : 32),
                        // OTP input label
                        Text('رمز التأكيد', style: AppStyles.bold16Black),
                        SizedBox(height: isKeyboardVisible ? 8 : 16),
                        // OTP input fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            4,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],

                                  keyboardType: TextInputType.visiblePassword,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: AppStyles.bold20Black,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppColors.whiteColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _onOTPCChanged(index, value),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 16 : 24),
                        // Verify button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: CustomElevatedButton(
                            onPressed: _isVerifying ? () {} : _handleVerify,
                            text: _isVerifying
                                ? 'جاري التحقق...'
                                : 'تحقق من الرمز',
                            backgroundColor: _isVerifying
                                ? AppColors.textHint
                                : AppColors.primary,
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 8 : 16),
                        if (!isKeyboardVisible) ...[
                          const Spacer(),
                          // Timer
                          Text(
                            'انتهي الرمز خلال: 01:50',
                            style: AppStyles.regular14Grey.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: _handleResendOTP,
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 44),
                            ),
                            child: Text(
                              'لم تستقبل الرمز؟ إعادة إرسال',
                              style: AppStyles.semi14Primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
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
