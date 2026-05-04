import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../../domain/entities/entities.dart';
import '../cubit/doctors_cubit.dart';
import '../widgets/doctor_detail_modal.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingController;
  late final Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _loadingOpacity = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DoctorsCubit>().loadDoctors();
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DoctorsCubit>().state;
    final specialties = DoctorSpecialty.allSpecialties;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: Center(
                child: Text('الأطباء', style: AppStyles.bold20Black),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: specialties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final specialty = specialties[index];
                  final isSelected =
                      state.selectedSpecialtyKey == specialty.key;
                  return ChoiceChip(
                    label: Text(
                      '${specialty.emoji} ${specialty.label}',
                      style: AppStyles.bold14Primary.copyWith(
                        color: isSelected
                            ? AppColors.whiteColor
                            : AppColors.primary,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: AppColors.primaryLighter,
                    selectedColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onSelected: (_) => context
                        .read<DoctorsCubit>()
                        .filterBySpecialty(specialty.key),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${state.doctorCount} طبيب متاح',
                  style: AppStyles.regular14Grey,
                ),
              ),
            ),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DoctorsState state) {
    if (state.status == DoctorsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'تعذر تحميل قائمة الأطباء',
                style: AppStyles.regular14Grey,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<DoctorsCubit>().loadDoctors(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == DoctorsStatus.loading ||
        state.status == DoctorsStatus.initial) {
      return AnimatedBuilder(
        animation: _loadingOpacity,
        builder: (context, _) {
          return ListView.builder(
            itemCount: 3,
            itemBuilder: (_, __) => _DoctorCardSkeleton(
              opacity: _loadingOpacity.value,
            ),
          );
        },
      );
    }

    if (state.filteredDoctors.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد أطباء في هذا التخصص حالياً',
          style: AppStyles.regular14Grey,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: state.filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = state.filteredDoctors[index];
        return _DoctorCard(
          doctor: doctor,
          onTap: () => DoctorDetailModal.show(context, doctor),
        );
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final specialtyColor = _specialtyColor(doctor.specialtyKey);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.rating}',
                            style: AppStyles.bold14Black,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(doctor.name, style: AppStyles.bold18Black),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: specialtyColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          doctor.specialty,
                          style: AppStyles.bold14Primary.copyWith(
                            fontSize: 11,
                            color: specialtyColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '${doctor.experienceYears} سنة خبرة',
                            style: AppStyles.regular12Grey,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textHint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${doctor.reviewsCount} تقييم',
                            style: AppStyles.regular12Grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLighter,
                  child: doctor.avatarPath != null
                      ? ClipOval(
                          child: Image.asset(
                            doctor.avatarPath!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.medical_services,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.medical_services,
                          size: 32,
                          color: AppColors.primary,
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

class _DoctorCardSkeleton extends StatelessWidget {
  final double opacity;

  const _DoctorCardSkeleton({required this.opacity});

  @override
  Widget build(BuildContext context) {
    final shimmerColor = AppColors.textHint.withValues(alpha: opacity);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 42,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 18,
                  width: 170,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 20,
                  width: 140,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 190,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: shimmerColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

Color _specialtyColor(String key) {
  switch (key) {
    case 'general':
      return AppColors.secondary;
    case 'nutrition':
      return Colors.green.shade600;
    case 'neurology':
      return Colors.purple;
    case 'cardiology':
      return Colors.red;
    case 'dermatology':
      return Colors.orange;
    case 'dental':
      return Colors.teal;
    default:
      return AppColors.primary;
  }
}
