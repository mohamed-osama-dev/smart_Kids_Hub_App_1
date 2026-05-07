import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/child.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import 'gender_selector.dart';
import 'health_condition_checkbox.dart';

class ChildFormCard extends StatefulWidget {
  final int childNumber;
  final Child child;
  final ValueChanged<Child> onChanged;
  final VoidCallback? onDelete;
  final bool canDelete;

  const ChildFormCard({
    super.key,
    required this.childNumber,
    required this.child,
    required this.onChanged,
    this.onDelete,
    this.canDelete = false,
  });

  @override
  State<ChildFormCard> createState() => _ChildFormCardState();
}

class _ChildFormCardState extends State<ChildFormCard> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const List<String> _healthConditionsList = [
    'لا يعاني من أمراض مزمنة',
    'الربو',
    'الحساسية الغذائية',
    'السكري',
    'أمراض القلب',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.child.name;
    if (widget.child.birthDate.year > 1900) {
      _birthDateController.text = DateFormat(
        'MM/dd/yyyy',
      ).format(widget.child.birthDate);
    }
    _heightController.text = widget.child.height != null ? widget.child.height!.toInt().toString() : '';
    _weightController.text = widget.child.weight != null ? widget.child.weight!.toInt().toString() : '';
    _notesController.text = widget.child.additionalNotes;
  }

  @override
  void didUpdateWidget(ChildFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.name != _nameController.text) {
      _nameController.text = widget.child.name;
    }
    final birthDateText = widget.child.birthDate.year > 1900
        ? DateFormat('MM/dd/yyyy').format(widget.child.birthDate)
        : '';
    if (_birthDateController.text != birthDateText) {
      _birthDateController.text = birthDateText;
    }
    final heightText = widget.child.height != null ? widget.child.height!.toInt().toString() : '';
    if (_heightController.text != heightText) {
      _heightController.text = heightText;
    }
    final weightText = widget.child.weight != null ? widget.child.weight!.toInt().toString() : '';
    if (_weightController.text != weightText) {
      _weightController.text = weightText;
    }
    if (widget.child.additionalNotes != _notesController.text) {
      _notesController.text = widget.child.additionalNotes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateChild({
    String? name,
    DateTime? birthDate,
    Gender? gender,
    double? height,
    double? weight,
    List<String>? healthConditions,
    String? additionalNotes,
    bool? hasNoChronicDiseases,
  }) {
    final updatedChild = widget.child.copyWith(
      name: name ?? widget.child.name,
      birthDate: birthDate ?? widget.child.birthDate,
      gender: gender ?? widget.child.gender,
      height: height ?? widget.child.height,
      weight: weight ?? widget.child.weight,
      healthConditions: healthConditions ?? widget.child.healthConditions,
      additionalNotes: additionalNotes ?? widget.child.additionalNotes,
      hasNoChronicDiseases:
          hasNoChronicDiseases ?? widget.child.hasNoChronicDiseases,
    );
    widget.onChanged(updatedChild);
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.child.birthDate.year > 1900
          ? widget.child.birthDate
          : DateTime(2020, 1, 1),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = DateFormat('MM/dd/yyyy').format(picked);
      _updateChild(birthDate: picked);
    }
  }

  void _onNoChronicDiseasesChanged(bool? value) {
    if (value == true) {
      _updateChild(hasNoChronicDiseases: true, healthConditions: []);
    } else {
      _updateChild(hasNoChronicDiseases: false);
    }
  }

  void _onConditionChanged(int index, bool? value) {
    if (index == 0) {
      _onNoChronicDiseasesChanged(value);
      return;
    }

    final conditions = List<String>.from(widget.child.healthConditions);
    if (value == true) {
      conditions.add(_healthConditionsList[index]);
    } else {
      conditions.remove(_healthConditionsList[index]);
    }

    _updateChild(healthConditions: conditions, hasNoChronicDiseases: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with child number and delete button
        Row(
          children: [
            if (widget.canDelete) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.childNumber.toString(),
                  style: AppStyles.bold14White,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('الطفل ${widget.childNumber}', style: AppStyles.bold16Black),
          ],
        ),
        const SizedBox(height: 16),
        // Form card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info Section
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text('البيانات الأساسية', style: AppStyles.bold16Primary),
                  ],
                ),
                const SizedBox(height: 16),
                // Child Name
                _buildFieldLabel('اسم الطفل *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'مثال: أحمد محمد',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                  onChanged: (value) => _updateChild(name: value),
                ),
                const SizedBox(height: 16),
                // Birth Date
                _buildFieldLabel('تاريخ الميلاد *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'mm/dd/yyyy',
                    prefixIcon: const Icon(Icons.calendar_today, size: 20),
                  ),
                  onTap: _selectBirthDate,
                ),
                if (widget.child.birthDate.year > 1900) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'العمر: ${widget.child.ageString}',
                      style: AppStyles.regular12Grey.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Gender
                _buildFieldLabel('الجنس *'),
                const SizedBox(height: 8),
                GenderSelector(
                  selectedGender: widget.child.gender,
                  onGenderChanged: (gender) => _updateChild(gender: gender),
                ),
                const SizedBox(height: 16),
                // Height
                _buildFieldLabel('الطول (سم) *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(Icons.straighten, size: 20),
                  ),
                  onChanged: (value) {
                    final height = double.tryParse(value);
                    if (height != null) {
                      _updateChild(height: height);
                    }
                  },
                ),
                const SizedBox(height: 4),
                Text('آخر طول تم قياسه', style: AppStyles.regular12Grey),
                const SizedBox(height: 16),
                // Weight
                _buildFieldLabel('الوزن (كجم) *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: const Icon(
                      Icons.monitor_weight_outlined,
                      size: 20,
                    ),
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    if (weight != null) {
                      _updateChild(weight: weight);
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Health Conditions Section
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text('الحالة الصحية', style: AppStyles.bold16Black),
                  ],
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  _healthConditionsList.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HealthConditionCheckbox(
                      label: _healthConditionsList[index],
                      isChecked: index == 0
                          ? widget.child.hasNoChronicDiseases
                          : widget.child.healthConditions.contains(
                              _healthConditionsList[index],
                            ),
                      onChanged: (value) => _onConditionChanged(index, value),
                      isFirst: index == 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Additional Notes
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text('ملاحظات إضافية', style: AppStyles.bold14Black),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'معلومات صحية أخرى أو ملاحظات مهمة عن الطفل...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: '',
                  ),
                  onChanged: (value) => _updateChild(additionalNotes: value),
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required maxLength,
                        required isFocused,
                      }) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '$currentLength / $maxLength',
                            style: AppStyles.regular12Grey,
                          ),
                        );
                      },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: AppStyles.regular14Grey);
  }
}
