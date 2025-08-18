import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/data_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final settings = ref.watch(settingsProvider);
    final isMutedToday = ref.watch(isMutedTodayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            _buildUserInfoCard(context, authState),

            const SizedBox(height: 24),

            // Account Section
            _buildAccountSection(context, ref, authState),

            const SizedBox(height: 24),

            // Notification Settings Section
            _buildNotificationSection(context, ref, settings, isMutedToday),

            const SizedBox(height: 24),

            // Quick Actions Section
            _buildQuickActionsSection(context, ref, isMutedToday),

            const SizedBox(height: 24),

            // App Settings Section
            _buildAppSettingsSection(context, ref, settings),

            const SizedBox(height: 24),

            // Data & Backup Section
            _buildDataSection(context, ref),

            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, AuthState authState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (authState is AuthAuthenticated) ...[
              Text(
                authState.user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                authState.user.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (authState.user.phone != null) ...[
                const SizedBox(height: 4),
                Text(
                  authState.user.phone!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ] else ...[
              const Text('Loading...', style: TextStyle(fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    return _buildSection('Hesap', [
      ListTile(
        leading: const Icon(Icons.edit),
        title: const Text('Kullanıcı Adını Düzenle'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showEditUsernameDialog(context, ref, authState),
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('E-posta Doğrulama'),
        subtitle: const Text('Doğrulama mailini yeniden gönder'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _resendVerificationEmail(context, ref),
      ),
      ListTile(
        leading: const Icon(Icons.lock),
        title: const Text('Şifre Değiştir'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showChangePasswordDialog(context, ref),
      ),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
        onTap: () => _showLogoutDialog(context, ref),
      ),
    ]);
  }

  Widget _buildNotificationSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
    bool isMutedToday,
  ) {
    return _buildSection('Bildirim & Zaman', [
      ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Saat Dilimi'),
        subtitle: Text(settings.timezone),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showTimezoneDialog(context, ref, settings),
      ),
      ListTile(
        leading: const Icon(Icons.wb_sunny),
        title: const Text('Sabah Bildirimi'),
        subtitle: Text('${settings.morningHour}:00'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showMorningHourDialog(context, ref, settings),
      ),
      ListTile(
        leading: const Icon(Icons.alarm),
        title: const Text('Dersten Önce Bildirim'),
        subtitle: Text('${settings.minutesBeforeClass} dakika önce'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showMinutesBeforeDialog(context, ref, settings),
      ),
      SwitchListTile(
        secondary: const Icon(Icons.note),
        title: const Text('Ders Notlarını Ekle'),
        subtitle: const Text('Bildirimlere ders notlarını dahil et'),
        value: settings.includeClassNotesInNotifications,
        onChanged: (value) {
          ref
              .read(settingsProvider.notifier)
              .updateIncludeClassNotesInNotifications(value);
        },
      ),
    ]);
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    WidgetRef ref,
    bool isMutedToday,
  ) {
    return _buildSection('Hızlı Eylemler', [
      ListTile(
        leading: Icon(
          isMutedToday ? Icons.volume_off : Icons.volume_up,
          color: isMutedToday ? Colors.orange : null,
        ),
        title: Text(
          isMutedToday ? 'Bugün İçin Sessizde' : 'Bugün İçin Sessize Al',
        ),
        subtitle: isMutedToday
            ? const Text('Gece yarısına kadar sessiz')
            : const Text('Bugün gece yarısına kadar bildirimleri kapat'),
        onTap: () {
          if (isMutedToday) {
            ref.read(settingsProvider.notifier).unmuteToday();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Bildirimler açıldı')));
          } else {
            ref.read(settingsProvider.notifier).muteUntilToday();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bugün için sessize alındı')),
            );
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.email),
        title: const Text('Haftalık Rapor'),
        subtitle: const Text('Raporu hazırla ve paylaş'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _generateWeeklyReport(context, ref),
      ),
    ]);
  }

  Widget _buildAppSettingsSection(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    return _buildSection('Uygulama', [
      ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Dil'),
        subtitle: Text(supportedLanguages[settings.language] ?? 'Türkçe'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _showLanguageDialog(context, ref, settings),
      ),
    ]);
  }

  Widget _buildDataSection(BuildContext context, WidgetRef ref) {
    final dataOperations = ref.watch(dataOperationsProvider);

    return _buildSection('Veri & Yedekleme', [
      ListTile(
        leading: const Icon(Icons.file_download),
        title: const Text('JSON Dışa Aktar'),
        subtitle: const Text('Tüm verileri yedek dosyası olarak indir'),
        trailing: dataOperations.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios),
        onTap: dataOperations.isLoading
            ? null
            : () => _exportData(context, ref),
      ),
      ListTile(
        leading: const Icon(Icons.file_upload),
        title: const Text('JSON İçe Aktar'),
        subtitle: const Text('Yedek dosyasından verileri geri yükle'),
        trailing: dataOperations.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios),
        onTap: dataOperations.isLoading
            ? null
            : () => _importData(context, ref),
      ),
      ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text(
          'Tüm Veriyi Sıfırla',
          style: TextStyle(color: Colors.red),
        ),
        subtitle: const Text('Bu işlem geri alınamaz!'),
        onTap: () => _showResetDataDialog(context, ref),
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  // Dialog methods would be implemented here...
  void _showEditUsernameDialog(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    // TODO: Implement username edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kullanıcı adı düzenleme özelliği yakında!'),
      ),
    );
  }

  void _resendVerificationEmail(BuildContext context, WidgetRef ref) {
    // TODO: Implement resend verification email
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Doğrulama e-postası gönderildi!')),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement change password dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifre değiştirme özelliği yakında!')),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authStateProvider.notifier).logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTimezoneDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saat Dilimi Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: supportedTimezones.length,
            itemBuilder: (context, index) {
              final timezone = supportedTimezones[index];
              return RadioListTile<String>(
                title: Text(timezone),
                value: timezone,
                groupValue: settings.timezone,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).updateTimezone(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMorningHourDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sabah Bildirimi Saati'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 24,
            itemBuilder: (context, index) {
              return RadioListTile<int>(
                title: Text('${index.toString().padLeft(2, '0')}:00'),
                value: index,
                groupValue: settings.morningHour,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateMorningHour(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMinutesBeforeDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    final options = [5, 10, 15, 30, 60];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dersten Kaç Dakika Önce'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map(
                (minutes) => RadioListTile<int>(
                  title: Text('$minutes dakika'),
                  value: minutes,
                  groupValue: settings.minutesBeforeClass,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateMinutesBeforeClass(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLanguages.entries
              .map(
                (entry) => RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: settings.language,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsProvider.notifier).updateLanguage(value);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _generateWeeklyReport(BuildContext context, WidgetRef ref) {
    // TODO: Implement weekly report generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Haftalık rapor özelliği yakında!')),
    );
  }

  void _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final filePath = await ref
          .read(dataOperationsProvider.notifier)
          .exportData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler dışa aktarıldı: $filePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  void _importData(BuildContext context, WidgetRef ref) async {
    // TODO: Implement file picker for import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dosya seçme özelliği yakında!')),
    );
  }

  void _showResetDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Veriyi Sıfırla'),
        content: const Text(
          'Bu işlem tüm verilerinizi kalıcı olarak silecektir. '
          'Bu işlem geri alınamaz!\n\n'
          'Devam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            child: const Text('İptal'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('SIFIRLA', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              _showSecondConfirmDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _showSecondConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Son Onay'),
        content: const Text(
          'TÜM VERİLERİNİZ SİLİNECEK!\n\n'
          'Bu işlemi onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            child: const Text('Hayır, İptal Et'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'EVET, SİL',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(dataOperationsProvider.notifier).resetAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tüm veriler sıfırlandı!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
