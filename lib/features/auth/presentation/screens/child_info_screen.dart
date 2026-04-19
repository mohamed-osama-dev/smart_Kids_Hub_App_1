import 'package:flutter/material.dart';
import '../../domain/models/child.dart';
import '../../domain/models/parent.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/app_routes.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/child_form_card.dart';
import '../../../../widgets/custom_elevated_button.dart';

class ChildInfoScreen extends StatefulWidget {
  final Parent parent;

  const ChildInfoScreen({
    super.key,
    required this.parent,
  });

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  final List<Child> _children = [
    Child(
      name: '',
      birthDate: DateTime(2022, 3, 15),
      gender: Gender.male,
      height: 105,
      healthConditions: const [],
      hasNoChronicDiseases: false,
    ),
  ];

  void _addChild() {
    setState(() {
      _children.add(
        Child(
          name: '',
          birthDate: DateTime(2022, 1, 1),
          gender: Gender.male,
          height: 0.0,
          healthConditions: const [],
          hasNoChronicDiseases: false,
        ),
      );
    });
  }

  void _removeChild(int index) {
    if (_children.length > 1) {
      setState(() {
        _children.removeAt(index);
      });
    }
  }

  void _updateChild(int index, Child child) {
    setState(() {
      _children[index] = child;
    });
  }

  bool _canProceed() {
    for (final child in _children) {
      if (child.name.isEmpty || child.height == null || child.height == 0) {
        return false;
      }
    }
    return true;
  }

  void _handleNext() {
    if (_canProceed()) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
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
              const StepProgressIndicator(
                currentStep: 2,
                totalSteps: 2,
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معلومات الأطفال',
                      style: AppStyles.bold20Black,
                    ),
                    Text(
                      'الخطوة 2 من 2',
                      style: AppStyles.regular12Grey,
                    ),
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
                          minHeight: constraints.maxHeight -
                              MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              ...List.generate(
                                _children.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: ChildFormCard(
                                    childNumber: index + 1,
                                    child: _children[index],
                                    onChanged: (child) =>
                                        _updateChild(index, child),
                                    onDelete: _children.length > 1
                                        ? () => _removeChild(index)
                                        : null,
                                    canDelete: _children.length > 1,
                                  ),
                                ),
                              ),
                              // Add another child button
                              InkWell(
                                onTap: _addChild,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'إضافة طفل آخر',
                                        style: AppStyles.bold16Primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Next button
                              CustomElevatedButton(
                                onPressed: _canProceed() ? _handleNext : () {},
                                text: 'التالي: تأكيد البيانات',
                                backgroundColor: _canProceed()
                                    ? AppColors.primary
                                    : AppColors.textHint.withOpacity(0.3),
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
