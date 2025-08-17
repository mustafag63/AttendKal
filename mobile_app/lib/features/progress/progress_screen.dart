import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İlerleme'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshProgressDataWidget(ref);
          // Wait a bit for providers to refresh
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Overview
              _buildDashboardSection(ref),

              const SizedBox(height: 24),

              // Course Progress Cards
              _buildCourseProgressSection(ref),

              const SizedBox(height: 24),

              // Weekly Trend Chart
              _buildWeeklyTrendSection(ref),

              const SizedBox(height: 24),

              // Daily Heatmap
              _buildDailyHeatmapSection(ref),

              const SizedBox(height: 80), // Bottom padding for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection(WidgetRef ref) {
    final overallProgress = ref.watch(overallProgressProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Genel Durum',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            overallProgress.when(
              data: (data) => _buildDashboardStats(data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Hata: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats(Map<String, dynamic> data) {
    final attendanceRate = data['attendanceRate'] as double;
    final totalAbsent = data['totalAbsent'] as int;
    final totalRemainingAbsences = data['totalRemainingAbsences'] as int;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Katılım Oranı',
            '${attendanceRate.toStringAsFixed(1)}%',
            Icons.trending_up,
            _getAttendanceColor(attendanceRate),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Toplam Devamsızlık',
            '$totalAbsent',
            Icons.event_busy,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Kalan Hak',
            '$totalRemainingAbsences',
            Icons.favorite,
            _getRemainingAbsencesColor(totalRemainingAbsences),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgressSection(WidgetRef ref) {
    final courseProgress = ref.watch(courseProgressListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ders Kartları',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        courseProgress.when(
          data: (courses) => courses.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Henüz ders bulunmuyor')),
                  ),
                )
              : Column(
                  children: courses
                      .map((courseData) => _buildCourseCard(courseData))
                      .toList(),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Hata: $error'),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> courseData) {
    final course = courseData['course'];
    final attendanceRate = courseData['attendanceRate'] as double;
    final remainingAbsences = courseData['remainingAbsences'] as int;
    final statusIcon = courseData['statusIcon'] as String;
    final totalSessions = courseData['totalSessions'] as int;
    final present = courseData['present'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: course.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            statusIcon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      Text(
                        course.code,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressStat(
                    'Katılım',
                    '${attendanceRate.toStringAsFixed(1)}%',
                    _getAttendanceColor(attendanceRate),
                  ),
                ),
                Expanded(
                  child: _buildProgressStat(
                    'Kalan Hak',
                    '$remainingAbsences',
                    _getRemainingAbsencesColor(remainingAbsences),
                  ),
                ),
                Expanded(
                  child: _buildProgressStat(
                    'Toplam',
                    '$present/$totalSessions',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            LinearProgressIndicator(
              value: totalSessions > 0 ? attendanceRate / 100 : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getAttendanceColor(attendanceRate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildWeeklyTrendSection(WidgetRef ref) {
    final weeklyTrend = ref.watch(weeklyTrendProvider(8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Haftalık Trend (Son 8 Hafta)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: weeklyTrend.when(
                data: (data) => data.isEmpty
                    ? const Center(child: Text('Veri bulunmuyor'))
                    : _buildSimpleWeeklyChart(data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Hata: $error')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleWeeklyChart(List<Map<String, dynamic>> data) {
    return Column(
      children: [
        // Simple bar chart representation
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.map((weekData) {
              final rate = weekData['attendanceRate'] as double;
              final height = (rate / 100) * 120; // Max height 120

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${rate.toInt()}%',
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      color: _getAttendanceColor(rate),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weekData['weekLabel'],
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyHeatmapSection(WidgetRef ref) {
    final dailyHeatmap = ref.watch(dailyHeatmapProvider(30));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Günlük Isı Haritası (Son 30 Gün)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: dailyHeatmap.when(
              data: (data) => data.isEmpty
                  ? const Center(child: Text('Veri bulunmuyor'))
                  : _buildHeatmap(data),
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Center(child: Text('Hata: $error')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmap(List<Map<String, dynamic>> data) {
    const double cellSize = 12;
    const double spacing = 2;

    return Column(
      children: [
        // Weekday labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('P', style: TextStyle(fontSize: 10)),
            Text('S', style: TextStyle(fontSize: 10)),
            Text('Ç', style: TextStyle(fontSize: 10)),
            Text('P', style: TextStyle(fontSize: 10)),
            Text('C', style: TextStyle(fontSize: 10)),
            Text('C', style: TextStyle(fontSize: 10)),
            Text('P', style: TextStyle(fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: data.map((day) {
            final intensity = day['intensity'] as double;
            final totalSessions = day['totalSessions'] as int;

            Color color;
            if (totalSessions == 0) {
              color = Colors.grey[200]!;
            } else if (intensity >= 0.8) {
              color = Colors.green[600]!;
            } else if (intensity >= 0.6) {
              color = Colors.green[400]!;
            } else if (intensity >= 0.4) {
              color = Colors.orange[400]!;
            } else {
              color = Colors.red[400]!;
            }

            return Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Az', style: TextStyle(fontSize: 10)),
            const SizedBox(width: 4),
            Container(
              width: cellSize,
              height: cellSize,
              color: Colors.grey[200],
            ),
            const SizedBox(width: 2),
            Container(
              width: cellSize,
              height: cellSize,
              color: Colors.red[400],
            ),
            const SizedBox(width: 2),
            Container(
              width: cellSize,
              height: cellSize,
              color: Colors.orange[400],
            ),
            const SizedBox(width: 2),
            Container(
              width: cellSize,
              height: cellSize,
              color: Colors.green[400],
            ),
            const SizedBox(width: 2),
            Container(
              width: cellSize,
              height: cellSize,
              color: Colors.green[600],
            ),
            const SizedBox(width: 4),
            const Text('Çok', style: TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getRemainingAbsencesColor(int remaining) {
    if (remaining == 0) return Colors.red;
    if (remaining <= 2) return Colors.orange;
    return Colors.green;
  }
}
