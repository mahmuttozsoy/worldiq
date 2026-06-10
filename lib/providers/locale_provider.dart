import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import 'l10n_extension.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  static const String _prefsKey = 'app_locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(_prefsKey) ?? 'en';
    return Locale(savedCode);
  }

  void setLocale(Locale locale) {
    if (state == locale) return;
    state = locale;
    ref.read(sharedPreferencesProvider).setString(_prefsKey, locale.languageCode);
  }

  void setLocaleFromCode(String langCode) {
    final newLocale = Locale(langCode);
    setLocale(newLocale);
  }
}

/// Global helper for localization with dynamic key support and fallback.
String t(BuildContext context, String key, {Map<String, String>? placeholders}) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return key;

  // Use the generated extension for lookup
  String result = l10n.translate(key);
  
  if (placeholders != null) {
    placeholders.forEach((k, v) {
      result = result.replaceAll('{$k}', v);
    });
  }
  
  return result;
}

