import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

/// NOTE: This widget has NO Scaffold of its own.
/// The bottom navigation bar lives in the app shell (HomePage).
/// All tab screens are plain widgets — no Scaffold wrapper.
class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(child: const _MealsBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 20),
        onPressed: () {
          // When used inside the tab shell there's nothing to pop,
          // but keep this for standalone route usage.
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        },
      ),
      title: Text(
        'تخطيط الوجبات',
        style: AppStyles.bold20Black,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today, size: 22),
          onPressed: () {
            // TODO: Open calendar
          },
        ),
      ],
    );
  }
}

class _MealsBody extends StatelessWidget {
  const _MealsBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MealsCubit>();
    final state = cubit.state;

    return SafeArea(
      child: Column(
        children: [
          // Week day selector
          WeekDaySelector(
            selectedIndex: state.selectedDayIndex,
            onDaySelected: (index) {
              cubit.selectDay(index);
              // In a real app, you'd also fetch meals for that date
              // cubit.getMealsByDate(dateForIndex(index));
            },
          ),
          // Ingredients card
          IngredientsCard(
            ingredients: state.ingredients,
            onRemoveIngredient: cubit.removeIngredient,
            onAddIngredient: () => _showAddIngredientDialog(context, cubit),
          ),
          // Allergies card
          _AllergiesCard(
            allergies: state.allergies,
            onRemoveAllergy: cubit.removeAllergy,
            onAddAllergy: () => _showAddAllergyDialog(context, cubit),
          ),
          // AI Suggest button
          AiSuggestButton(
            onPressed: () => cubit.getAiSuggestions(),
            isLoading: state.status == MealsStatus.loading,
          ),
          // Meals list (shows when loaded)
          Expanded(
            child: _buildContent(context, cubit, state),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MealsCubit cubit, MealsState state) {
    switch (state.status) {
      case MealsStatus.initial:
        return const SizedBox.shrink();
      case MealsStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      case MealsStatus.loaded:
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: state.meals.length,
          itemBuilder: (context, index) {
            final meal = state.meals[index];
            return MealCard(
              meal: meal,
              onFavorite: () => cubit.toggleFavorite(meal.id),
              onCheck: () {
                // Toggle checked state (would need to be added to cubit)
              },
              onViewRecipe: () {
                // TODO: Navigate to recipe detail
              },
            );
          },
        );
      case MealsStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'حدث خطأ',
                style: AppStyles.regular14Grey,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => cubit.getAiSuggestions(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        );
    }
  }

  void _showAddIngredientDialog(BuildContext context, MealsCubit cubit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة مكون', style: AppStyles.bold18Black),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اسم المكون',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: AppStyles.semi14Primary),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                cubit.addIngredient(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddAllergyDialog(BuildContext context, MealsCubit cubit) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة حساسية', style: AppStyles.bold18Black),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'مثال: فول سوداني، حليب، بيض',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: AppStyles.semi14Primary),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                cubit.addAllergy(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

class _AllergiesCard extends StatelessWidget {
  final List<String> allergies;
  final Function(String) onRemoveAllergy;
  final VoidCallback onAddAllergy;

  const _AllergiesCard({
    required this.allergies,
    required this.onRemoveAllergy,
    required this.onAddAllergy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'حساسية الطفل',
                style: AppStyles.bold16Black,
              ),
              const SizedBox(width: 4),
              const Text('⚠️', style: TextStyle(fontSize: 16)),
            ],
          ),
          if (allergies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: allergies.map((allergy) {
                return Chip(
                  label: Text(
                    allergy,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  backgroundColor: Colors.red.shade400,
                  deleteIconColor: Colors.white,
                  onDeleted: () => onRemoveAllergy(allergy),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddAllergy,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة حساسية'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade300, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
