import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/child.dart';
import '../../domain/models/parent.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/children_cubit.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/app_routes.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/child_form_card.dart';
import '../../../../widgets/custom_elevated_button.dart';

class ChildInfoScreen extends StatefulWidget {
  final Parent? parent;

  const ChildInfoScreen({super.key, this.parent});

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  late Child _currentChild;

  @override
  void initState() {
    super.initState();
    _currentChild = _createEmptyChild();
  }

  Child _createEmptyChild() {
    return Child(
      name: '',
      birthDate: DateTime(1900, 1, 1),
      gender: Gender.male,
      height: null,
      // TODO: remove default weight after testing.
      weight: 20.0,
      healthConditions: const [],
      hasNoChronicDiseases: false,
    );
  }

  void _updateChild(Child child) {
    setState(() {
      _currentChild = child;
    });
  }

  bool _canSubmitChild() {
    if (_currentChild.name.trim().isEmpty) return false;
    if (_currentChild.birthDate.year <= 1900) return false;
    if (_currentChild.height == null || _currentChild.height! <= 0) return false;
    if (_currentChild.weight == null || _currentChild.weight! <= 0) return false;
    return true;
  }

  Future<void> _submitChild({required bool navigateHomeOnSuccess}) async {
    if (!_canSubmitChild()) return;

    final cubit = context.read<AuthCubit>();
    final success = await cubit.addChild(_currentChild);
    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.errorMessage ?? 'حدث خطأ أثناء إضافة الطفل')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح')));

    if (navigateHomeOnSuccess) {
      final childrenCubit = context.read<ChildrenCubit>();

      if (widget.parent == null) {
        Navigator.of(context).pop();
        childrenCubit.addChildAndRefresh();
        return;
      }

      await Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      childrenCubit.addChildAndRefresh();
      return;
    }

    setState(() {
      _currentChild = _createEmptyChild();
    });
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
              const StepProgressIndicator(currentStep: 2, totalSteps: 2),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('معلومات الأطفال', style: AppStyles.bold20Black),
                    Text('الخطوة 2 من 2', style: AppStyles.regular12Grey),
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
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: ChildFormCard(
                                  childNumber: 1,
                                  child: _currentChild,
                                  onChanged: _updateChild,
                                ),
                              ),
                              // Add another child button
                              Consumer<AuthCubit>(
                                builder: (context, cubit, _) {
                                  final canSubmit =
                                      _canSubmitChild() && !cubit.isLoading;
                                  return InkWell(
                                    onTap: canSubmit
                                        ? () => _submitChild(
                                            navigateHomeOnSuccess: false,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        border: Border.all(
                                          color: canSubmit
                                              ? AppColors.primary
                                              : AppColors.textHint,
                                          width: 2,
                                          style: BorderStyle.solid,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (cubit.isLoading) ...[
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ] else ...[
                                            const Icon(
                                              Icons.add,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            cubit.isLoading
                                                ? 'جاري الإضافة...'
                                                : 'إضافة طفل آخر',
                                            style: AppStyles.bold16Primary
                                                .copyWith(
                                                  color: canSubmit
                                                      ? AppColors.primary
                                                      : AppColors.textHint,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // Next button
                              Consumer<AuthCubit>(
                                builder: (context, cubit, _) {
                                  final canSubmit =
                                      _canSubmitChild() && !cubit.isLoading;
                                  return CustomElevatedButton(
                                    onPressed: canSubmit
                                        ? () => _submitChild(
                                            navigateHomeOnSuccess: true,
                                          )
                                        : () {},
                                    text: cubit.isLoading
                                        ? 'جاري الحفظ...'
                                        : 'التالي: تأكيد البيانات',
                                    backgroundColor: canSubmit
                                        ? AppColors.primary
                                        : AppColors.textHint.withOpacity(0.3),
                                  );
                                },
                              ),
                            ],
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
}
