// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'progress_screen.dart';
import '../../providers/progress_providers.dart';
import '../../providers/courses_providers.dart';
import '../../utils/test_data.dart';

class ProgressTestPage extends ConsumerWidget {
  const ProgressTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Reset and recreate test data
              final db = ref.read(databaseProvider);

              // Clear existing data
              await db.customStatement('DELETE FROM attendance');
              await db.customStatement('DELETE FROM sessions');
              await db.customStatement('DELETE FROM meetings');
              await db.customStatement('DELETE FROM courses');

              // Recreate test data
              ref.invalidate(testDataProvider);
              await ref.read(testDataProvider.future);

              // Refresh progress data
              refreshProgressDataWidget(ref);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test verisi yenilendi!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Kontrolü',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Test verisi yüklendi mi?'),
                    const Text('• Dashboard görünüyor mu?'),
                    const Text('• Ders kartları doğru mu?'),
                    const Text('• Haftalık trend var mı?'),
                    const Text('• Isı haritası çalışıyor mu?'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Test data'yı yükle
                        ref.read(testDataProvider);
                      },
                      child: const Text('Test Verisi Yükle'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(child: ProgressScreen()),
        ],
      ),
    );
  }
}
