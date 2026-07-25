import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Non-sensitive key-value preferences backed by GetStorage:
/// theme mode, remembered username and the cached profile of the last
/// signed-in user (so the shell can render instantly on cold start).
class PreferencesService extends GetxService {
  static const _kThemeMode = 'theme_mode';
  static const _kRememberedUsername = 'remembered_username';
  static const _kCachedProfile = 'cached_profile';

  late final GetStorage _box;

  Future<PreferencesService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // --- Theme -------------------------------------------------------------
  ThemeMode get themeMode {
    switch (_box.read<String>(_kThemeMode)) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _box.write(_kThemeMode, mode.name);

  // --- Login form convenience ---------------------------------------------
  String? get rememberedUsername => _box.read<String>(_kRememberedUsername);

  Future<void> setRememberedUsername(String? username) =>
      username == null || username.isEmpty
          ? _box.remove(_kRememberedUsername)
          : _box.write(_kRememberedUsername, username);

  // --- Cached profile -------------------------------------------------------
  Map<String, dynamic>? get cachedProfile =>
      (_box.read(_kCachedProfile) as Map?)?.cast<String, dynamic>();

  Future<void> setCachedProfile(Map<String, dynamic>? json) =>
      json == null ? _box.remove(_kCachedProfile) : _box.write(_kCachedProfile, json);
}
