import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/common/local_storage.dart';
import 'package:tic_tac_toe/core/localization/app_language.dart';
import 'package:tic_tac_toe/constants/settings.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_resolveInitialLocale());

  static Locale _resolveInitialLocale() {
    final savedCode = LocalStorage.getLanguageCode();
    if (savedCode != null &&
        AppLanguages.supported.any((language) => language.code == savedCode)) {
      return Locale(savedCode);
    }

    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (AppLanguages.supported.any((language) => language.code == deviceCode)) {
      return Locale(deviceCode);
    }

    return const Locale(AppSettings.defaultLanguageCode);
  }

  Future<void> changeLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;
    await LocalStorage.setLanguageCode(languageCode);
    emit(Locale(languageCode));
  }
}
