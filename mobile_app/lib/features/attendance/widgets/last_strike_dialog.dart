import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/attendance_providers.dart';
import '../../../providers/courses_providers.dart';

class LastStrikeDialog extends ConsumerWidget {
  final String courseId;
  final VoidCallback onDismiss;

  const LastStrikeDialog({
    super.key,
    required this.courseId,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingAbsencesAsync = ref.watch(
      remainingAbsencesProvider(courseId),
    );
    final courseAsync = ref.watch(courseProvider(courseId));

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red, size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Son Uyarı!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          courseAsync.when(
            data: (course) => Column(
              children: [
                Text(
                  course?.name ?? 'Bu ders',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                remainingAbsencesAsync.when(
                  data: (remaining) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          remaining <= 0
                              ? 'Devamsızlık hakkınız kalmadı!'
                              : 'Sadece $remaining devamsızlık hakkınız kaldı!',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remaining <= 0
                              ? 'Bu dersten kaldınız. Akademik danışmanınızla görüşün.'
                              : 'Bir sonraki devamsızlıkta bu dersten kalacaksınız!',
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('Hata: $error'),
                ),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('Ders bilgisi yüklenemedi: $error'),
          ),
          const SizedBox(height: 16),
          Text(
            'Bu uyarı sadece bir kez gösterilir.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss();
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Anladım'),
        ),
      ],
    );
  }
}
