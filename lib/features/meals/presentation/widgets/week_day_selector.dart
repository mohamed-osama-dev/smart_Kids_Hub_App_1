import 'package:flutter/material.dart';
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
    // weekday: Mon=1...Sun=7. We want Saturday=0 index.
    // Saturday in Dart weekday = 6
    // Days since last Saturday:
    final daysSinceSaturday = (now.weekday + 1) % 7; // Sat=0,Sun=1,...,Fri=6
    final startOfWeek = now.subtract(Duration(days: daysSinceSaturday));
    final dayNames = [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];
    final days = <Map<String, String>>[];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      days.add({
        'name': dayNames[i],
        'day': date.day.toString(),
        'isToday':
            (date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day)
                ? 'true'
                : 'false',
      });
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
