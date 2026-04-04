import 'dart:ui';

class I18nService {
  static const supportedLanguageCodes = {'en', 'zh'};

  static Locale resolveLocale({
    required Locale systemLocale,
    required String? overrideCode,
  }) {
    if (overrideCode != null && supportedLanguageCodes.contains(overrideCode)) {
      return Locale(overrideCode);
    }
    if (supportedLanguageCodes.contains(systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }
    return const Locale('en');
  }
}
