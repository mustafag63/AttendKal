import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/reminder_providers.dart';
import '../data/local/db.dart';
import 'widgets/reminder_card.dart';
import 'widgets/add_reminder_dialog.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatıcılar'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.access_time), text: 'Yaklaşan'),
            Tab(icon: Icon(Icons.schedule), text: 'Gelecek'),
            Tab(icon: Icon(Icons.history), text: 'Geçmiş'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReminderTab(TimeRange.upcoming),
          _buildReminderTab(TimeRange.future),
          _buildReminderTab(TimeRange.past),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReminderTab(TimeRange timeRange) {
    final remindersAsync = ref.watch(remindersByTimeRangeProvider(timeRange));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(remindersByTimeRangeProvider(timeRange));
      },
      child: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return _buildEmptyState(timeRange);
          }

          // Group reminders by date
          final groupedReminders = _groupRemindersByDate(reminders);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedReminders.length,
            itemBuilder: (context, index) {
              final entry = groupedReminders.entries.elementAt(index);
              final date = entry.key;
              final dayReminders = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _formatDateHeader(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  // Reminders for this date
                  ...dayReminders.map(
                    (reminder) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ReminderCard(
                        reminder: reminder,
                        onTap: () => _editReminder(context, reminder),
                        onToggle: (isActive) => ref
                            .read(reminderNotifierProvider.notifier)
                            .toggleReminderActive(reminder.id, isActive),
                        onDelete: () => _deleteReminder(context, reminder),
                      ),
                    ),
                  ),

                  if (index < groupedReminders.length - 1)
                    const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Hatırlatıcılar yüklenirken hata oluştu',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(remindersByTimeRangeProvider(timeRange)),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TimeRange timeRange) {
    String title, subtitle;
    IconData icon;

    switch (timeRange.type) {
      case TimeRangeType.upcoming:
        icon = Icons.access_time;
        title = 'Yaklaşan hatırlatıcı yok';
        subtitle = 'Önümüzdeki 48 saat içinde hatırlatıcınız bulunmuyor';
        break;
      case TimeRangeType.future:
        icon = Icons.schedule;
        title = 'Gelecek hatırlatıcı yok';
        subtitle = 'İleri tarihler için henüz hatırlatıcı eklenmemiş';
        break;
      case TimeRangeType.past:
        icon = Icons.history;
        title = 'Geçmiş hatırlatıcı yok';
        subtitle = 'Daha önce oluşturulan hatırlatıcı bulunmuyor';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (timeRange.type != TimeRangeType.past) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddReminderDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Hatırlatıcı Ekle'),
            ),
          ],
        ],
      ),
    );
  }

  Map<DateTime, List<Reminder>> _groupRemindersByDate(
    List<Reminder> reminders,
  ) {
    final Map<DateTime, List<Reminder>> grouped = {};

    for (final reminder in reminders) {
      final scheduledTime = DateTime.fromMillisecondsSinceEpoch(
        reminder.scheduledTime,
      );
      final date = DateTime(
        scheduledTime.year,
        scheduledTime.month,
        scheduledTime.day,
      );

      grouped[date] ??= [];
      grouped[date]!.add(reminder);
    }

    // Sort reminders within each date by time
    for (final reminders in grouped.values) {
      reminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    }

    // Sort dates
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return 'Bugün';
    } else if (date == tomorrow) {
      return 'Yarın';
    } else {
      final weekdays = [
        '',
        'Pazartesi',
        'Salı',
        'Çarşamba',
        'Perşembe',
        'Cuma',
        'Cumartesi',
        'Pazar',
      ];
      final months = [
        '',
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık',
      ];

      return '${weekdays[date.weekday]}, ${date.day} ${months[date.month]}';
    }
  }

  void _showAddReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddReminderDialog(),
    );
  }

  void _editReminder(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(reminder: reminder),
    );
  }

  void _deleteReminder(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatıcıyı Sil'),
        content: Text(
          '${reminder.title} hatırlatıcısını silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(reminderNotifierProvider.notifier)
                    .deleteReminder(reminder.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hatırlatıcı silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
