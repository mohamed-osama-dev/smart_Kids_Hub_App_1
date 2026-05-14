import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/models/parent.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/app_routes.dart';
import '../widgets/step_progress_indicator.dart';
import '../../../../widgets/custom_elevated_button.dart';
import '../cubit/auth_cubit.dart';

class OTPVerificationScreen extends StatefulWidget {
  final Parent? parent;
  final String phoneNumber;
  final bool isPasswordReset;

  const OTPVerificationScreen({
    super.key,
    this.parent,
    required this.phoneNumber,
    this.isPasswordReset = false,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  bool _isVerifying = false;
  int _secondsRemaining = 60;
  bool _canResend = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    final String cleanOtp = _otpController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanOtp.length == 6 && !_isVerifying) {
      _handleVerify();
    }
  }

  String _formatPhoneForDisplay(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('20') && digits.length == 12) {
      return '0${digits.substring(2)}';
    }
    if (digits.length == 10) {
      return '0$digits';
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits;
    }
    return phone;
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _handleVerify() async {
    final String cleanOtp = _otpController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    if (cleanOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رمز التحقق كاملاً (6 أرقام)')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final cubit = context.read<AuthCubit>();
    final success = await cubit.verifyOtp(
      verifyCode: cleanOtp,
      isPasswordReset: widget.isPasswordReset,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (success) {
      if (widget.isPasswordReset) {
        Navigator.of(context).pushNamed(AppRoutes.setNewPassword);
      } else if (widget.parent != null) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.childInfo, arguments: widget.parent);
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.errorMessage ?? 'رمز التحقق غير صحيح')),
      );
    }
  }

  Future<void> _handleResendOTP() async {
    final cubit = context.read<AuthCubit>();
    final success = await cubit.resendCode();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.errorMessage ?? 'تعذر إعادة إرسال الرمز')),
      );
    }
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
                            _formatPhoneForDisplay(widget.phoneNumber),
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
                        // OTP input field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.left,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                letterSpacing: 16.0,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
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
                            ),
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 16 : 24),
                        // Verify button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Consumer<AuthCubit>(
                            builder: (context, cubit, _) {
                              final isBusy = _isVerifying || cubit.isLoading;
                              return CustomElevatedButton(
                                onPressed: isBusy ? () {} : _handleVerify,
                                text: isBusy
                                    ? 'جاري التحقق...'
                                    : 'تحقق من الرمز',
                                backgroundColor: isBusy
                                    ? AppColors.textHint
                                    : AppColors.primary,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isKeyboardVisible ? 8 : 16),
                        if (!isKeyboardVisible) ...[
                          const Spacer(),
                          // Timer
                          if (!_canResend)
                            Text(
                              'انتهي الرمز خلال: ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                              style: AppStyles.regular14Grey.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          SizedBox(height: 16),
                          Consumer<AuthCubit>(
                            builder: (context, cubit, _) {
                              return TextButton(
                                onPressed: (_canResend && !cubit.isLoading)
                                    ? () async {
                                        await _handleResendOTP();
                                        _startTimer();
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                ),
                                child: Text(
                                  cubit.isLoading
                                      ? 'جاري إعادة الإرسال...'
                                      : 'لم تستقبل الرمز؟ إعادة إرسال',
                                  style: _canResend
                                      ? AppStyles.semi14Primary
                                      : AppStyles.semi14Primary.copyWith(
                                          color: AppColors.textHint,
                                        ),
                                ),
                              );
                            },
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

class OTPVerificationArgs {
  final Parent? parent;
  final String phoneNumber;
  final bool isPasswordReset;

  const OTPVerificationArgs({
    this.parent,
    required this.phoneNumber,
    this.isPasswordReset = false,
  });
}
