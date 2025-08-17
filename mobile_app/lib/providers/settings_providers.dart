import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';

// Settings model
class AppSettings {
  final String timezone;
  final int morningHour;
  final int minutesBeforeClass;
  final bool includeClassNotesInNotifications;
  final String language;
  final DateTime? muteTodayUntil;

  const AppSettings({
    this.timezone = 'Europe/Istanbul',
    this.morningHour = 8,
    this.minutesBeforeClass = 15,
    this.includeClassNotesInNotifications = true,
    this.language = 'tr',
    this.muteTodayUntil,
  });

  AppSettings copyWith({
    String? timezone,
    int? morningHour,
    int? minutesBeforeClass,
    bool? includeClassNotesInNotifications,
    String? language,
    DateTime? muteTodayUntil,
  }) {
    return AppSettings(
      timezone: timezone ?? this.timezone,
      morningHour: morningHour ?? this.morningHour,
      minutesBeforeClass: minutesBeforeClass ?? this.minutesBeforeClass,
      includeClassNotesInNotifications:
          includeClassNotesInNotifications ??
          this.includeClassNotesInNotifications,
      language: language ?? this.language,
      muteTodayUntil: muteTodayUntil ?? this.muteTodayUntil,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timezone': timezone,
      'morningHour': morningHour,
      'minutesBeforeClass': minutesBeforeClass,
      'includeClassNotesInNotifications': includeClassNotesInNotifications,
      'language': language,
      'muteTodayUntil': muteTodayUntil?.millisecondsSinceEpoch,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      timezone: json['timezone'] ?? 'Europe/Istanbul',
      morningHour: json['morningHour'] ?? 8,
      minutesBeforeClass: json['minutesBeforeClass'] ?? 15,
      includeClassNotesInNotifications:
          json['includeClassNotesInNotifications'] ?? true,
      language: json['language'] ?? 'tr',
      muteTodayUntil: json['muteTodayUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['muteTodayUntil'])
          : null,
    );
  }
}

// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final AppDatabase _database;

  SettingsNotifier(this._database) : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final timezone =
          await _database.getSetting('timezone') ?? 'Europe/Istanbul';
      final morningHour =
          int.tryParse(await _database.getSetting('morningHour') ?? '8') ?? 8;
      final minutesBeforeClass =
          int.tryParse(
            await _database.getSetting('minutesBeforeClass') ?? '15',
          ) ??
          15;
      final includeNotes =
          (await _database.getSetting('includeClassNotesInNotifications') ??
              'true') ==
          'true';
      final language = await _database.getSetting('language') ?? 'tr';
      final muteTodayUntilStr = await _database.getSetting('muteTodayUntil');

      DateTime? muteTodayUntil;
      if (muteTodayUntilStr != null) {
        final timestamp = int.tryParse(muteTodayUntilStr);
        if (timestamp != null) {
          muteTodayUntil = DateTime.fromMillisecondsSinceEpoch(timestamp);
          // Eğer geçmişte ise temizle
          if (muteTodayUntil.isBefore(DateTime.now())) {
            muteTodayUntil = null;
            await _database.setSetting('muteTodayUntil', '');
          }
        }
      }

      state = AppSettings(
        timezone: timezone,
        morningHour: morningHour,
        minutesBeforeClass: minutesBeforeClass,
        includeClassNotesInNotifications: includeNotes,
        language: language,
        muteTodayUntil: muteTodayUntil,
      );
    } catch (e) {
      // Hata durumunda varsayılan ayarları kullan
      state = const AppSettings();
    }
  }

  Future<void> updateTimezone(String timezone) async {
    await _database.setSetting('timezone', timezone);
    state = state.copyWith(timezone: timezone);
  }

  Future<void> updateMorningHour(int hour) async {
    await _database.setSetting('morningHour', hour.toString());
    state = state.copyWith(morningHour: hour);
  }

  Future<void> updateMinutesBeforeClass(int minutes) async {
    await _database.setSetting('minutesBeforeClass', minutes.toString());
    state = state.copyWith(minutesBeforeClass: minutes);
  }

  Future<void> updateIncludeClassNotesInNotifications(bool include) async {
    await _database.setSetting(
      'includeClassNotesInNotifications',
      include.toString(),
    );
    state = state.copyWith(includeClassNotesInNotifications: include);
  }

  Future<void> updateLanguage(String language) async {
    await _database.setSetting('language', language);
    state = state.copyWith(language: language);
  }

  Future<void> muteUntilToday() async {
    final today = DateTime.now();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    await _database.setSetting(
      'muteTodayUntil',
      endOfDay.millisecondsSinceEpoch.toString(),
    );
    state = state.copyWith(muteTodayUntil: endOfDay);
  }

  Future<void> unmuteToday() async {
    await _database.setSetting('muteTodayUntil', '');
    state = state.copyWith(muteTodayUntil: null);
  }

  bool get isMutedToday {
    if (state.muteTodayUntil == null) return false;
    return DateTime.now().isBefore(state.muteTodayUntil!);
  }
}

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((
  ref,
) {
  final database = AppDatabase.instance;
  return SettingsNotifier(database);
});

// Convenience providers
final isMutedTodayProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.muteTodayUntil == null) return false;
  return DateTime.now().isBefore(settings.muteTodayUntil!);
});

// Supported timezones
final supportedTimezones = [
  'Europe/Istanbul',
  'Europe/London',
  'Europe/Berlin',
  'America/New_York',
  'America/Los_Angeles',
  'Asia/Tokyo',
  'Asia/Dubai',
];

// Supported languages
final supportedLanguages = {'tr': 'Türkçe', 'en': 'English'};
