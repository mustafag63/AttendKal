import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';

// Overall dashboard stats provider
final overallProgressProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final database = AppDatabase.instance;
  return await database.getOverallProgress();
});

// Course progress list provider
final courseProgressListProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final database = AppDatabase.instance;
  return await database.getCourseProgressList();
});

// Weekly trend provider
final weeklyTrendProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, weeks) async {
      final database = AppDatabase.instance;
      return await database.getWeeklyTrend(weeks: weeks);
    });

// Daily heatmap provider
final dailyHeatmapProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, days) async {
      final database = AppDatabase.instance;
      return await database.getDailyHeatmap(days: days);
    });

// Auto-refresh progress data when attendance changes
final progressRefreshProvider = StateProvider<int>((ref) => 0);

// Invalidate progress providers when attendance changes
void refreshProgressData(Ref ref) {
  ref.invalidate(overallProgressProvider);
  ref.invalidate(courseProgressListProvider);
  ref.invalidate(weeklyTrendProvider);
  ref.invalidate(dailyHeatmapProvider);
}

// Widget için refresh fonksiyonu
void refreshProgressDataWidget(WidgetRef ref) {
  ref.invalidate(overallProgressProvider);
  ref.invalidate(courseProgressListProvider);
  ref.invalidate(weeklyTrendProvider);
  ref.invalidate(dailyHeatmapProvider);
  ref.read(progressRefreshProvider.notifier).state++;
}
