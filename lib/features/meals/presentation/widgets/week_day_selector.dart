import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_styles.dart';

class WeekDaySelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDaySelected;

  const WeekDaySelector({
    super.key,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  List<Map<String, String>> _getWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7 + 1));
    final days = <Map<String, String>>[];
    final dayNames = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = dayNames[i];
      final dayNum = DateFormat('d').format(date);
      days.add({'name': dayName, 'day': dayNum, 'isToday': 'false'});
    }

    // Mark today
    final todayIdx = now.weekday % 7 + 1;
    if (todayIdx < days.length) {
      days[todayIdx] = Map<String, String>.from(days[todayIdx])..['isToday'] = 'true';
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getWeekDays();

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;
          final isToday = day['isToday'] == 'true';

          return GestureDetector(
            onTap: () => onDaySelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'اليوم',
                      style: AppStyles.bold12White.copyWith(fontSize: 9),
                    ),
                  ),
                const SizedBox(height: 2),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day['name']!,
                        style: (isSelected ? AppStyles.bold12White : AppStyles.regular12Grey)
                            .copyWith(fontSize: 9),
                      ),
                      Text(
                        day['day']!,
                        style: (isSelected ? AppStyles.bold14White : AppStyles.bold14Black)
                            .copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
