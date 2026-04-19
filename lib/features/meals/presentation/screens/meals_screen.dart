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
}
