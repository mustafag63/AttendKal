import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../courses/presentation/bloc/courses_bloc.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../../core/widgets/bottom_navigation.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    // Load data for analytics
    context.read<CoursesBloc>().add(LoadCoursesEvent());
    context.read<AttendanceBloc>().add(const LoadAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, coursesState) {
                return BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, attendanceState) {
                    if (coursesState is CoursesLoaded &&
                        attendanceState is AttendanceLoaded) {
                      return _buildOverviewCards(
                          coursesState.courses, attendanceState.attendances);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Attendance Trends
            const Text(
              'Attendance Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            BlocBuilder<AttendanceBloc, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoaded) {
                  return _buildAttendanceTrends(state.attendances);
                }
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Course Performance
            const Text(
              'Course Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            BlocBuilder<CoursesBloc, CoursesState>(
              builder: (context, state) {
                if (state is CoursesLoaded) {
                  return _buildCoursePerformance(state.courses);
                }
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildOverviewCards(List<Map<String, dynamic>> courses,
      List<Map<String, dynamic>> attendances) {
    final totalCourses = courses.length;

    // Calculate overall stats
    final stats = <String, int>{
      'PRESENT': 0,
      'ABSENT': 0,
      'LATE': 0,
      'EXCUSED': 0,
    };

    for (final attendance in attendances) {
      final status = attendance['status'] as String;
      stats[status] = (stats[status] ?? 0) + 1;
    }

    final totalAttendances = stats.values.fold(0, (sum, count) => sum + count);
    final attendanceRate = totalAttendances > 0
        ? ((stats['PRESENT']! + stats['LATE']!) / totalAttendances * 100)
            .round()
        : 0;

    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            title: 'Total Courses',
            value: totalCourses.toString(),
            icon: Icons.book,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            title: 'Total Classes',
            value: totalAttendances.toString(),
            icon: Icons.event,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            title: 'Attendance Rate',
            value: '$attendanceRate%',
            icon: Icons.trending_up,
            color: attendanceRate >= 75 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTrends(List<Map<String, dynamic>> attendances) {
    // Group attendances by week
    final weeklyData = <String, Map<String, int>>{};

    for (final attendance in attendances) {
      final date = DateTime.parse(attendance['date']);
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekKey = '${weekStart.day}/${weekStart.month}';

      weeklyData[weekKey] ??= {
        'PRESENT': 0,
        'ABSENT': 0,
        'LATE': 0,
        'EXCUSED': 0
      };
      final status = attendance['status'] as String;
      weeklyData[weekKey]![status] = (weeklyData[weekKey]![status] ?? 0) + 1;
    }

    if (weeklyData.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No attendance data yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Weekly Attendance',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weeklyData.length,
                itemBuilder: (context, index) {
                  final entry = weeklyData.entries.elementAt(index);
                  final week = entry.key;
                  final data = entry.value;
                  final total =
                      data.values.fold(0, (sum, count) => sum + count);
                  final presentPercentage =
                      total > 0 ? (data['PRESENT']! / total * 100).round() : 0;

                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (total > 0) ...[
                                  Container(
                                    height: (presentPercentage / 100 * 120),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          week,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '$presentPercentage%',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursePerformance(List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No courses yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Attendance Rates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...courses.map((course) {
              final name = course['name'] as String? ?? 'Unknown Course';
              final attendanceRate = (course['attendanceRate'] as num?)?.toDouble() ?? 0.0;
              final color = Color(
                int.parse(
                        (course['color'] as String? ?? '#2196F3').substring(1),
                        radix: 16) +
                    0xFF000000,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${attendanceRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: attendanceRate >= 75
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: attendanceRate / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
