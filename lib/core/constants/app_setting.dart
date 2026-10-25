import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:school_flutter_frontend/features/profile/model/app_const_setting_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/user_model.dart';
import '../utils/unfocus_on_route_change.dart';
import 'app_constants.dart';

// ------------------------------------------------
late final SharedPreferences prefs;
ValueNotifier<bool> isLogin = ValueNotifier(false);
ValueNotifier<bool> isThemeLight = ValueNotifier(true);
final navigatorKey = GlobalKey<NavigatorState>();
final unfocusObserver = UnfocusOnRouteChange();

// ------------------------------------------------
final String appVersion = '1.0.0';
final String appBuildVersion = '1';
// ------------------------------------------------
UserModel currentUserModel = UserModel();
AppConstSettingModel appConstSetting = const AppConstSettingModel();

// ------------------------------------------------
Future<void> initGlobalSettings() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSharedPreferences();
  await loadUserInformation();
  isThemeLight.value = prefs.getBool(AppConstants.isThemeLight) ?? true;
}

Future<void> initializeSharedPreferences() async {
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Error initializing SharedPreferences: $e');
  }
}

Future<void> loadUserInformation() async {
  final token = prefs.getString(AppConstants.userToken);
  final rawUser = prefs.getString(AppConstants.userDataJson);

  if (token != null &&
      token.isNotEmpty &&
      rawUser != null &&
      rawUser.isNotEmpty) {
    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        currentUserModel = UserModel.fromJson(decoded);
        isLogin.value = true;
        return;
      }
    } catch (e) {
      debugPrint('Failed to parse stored user data: $e');
    }
  }

  currentUserModel = UserModel();
  isLogin.value = false;
}

Future<void> saveUserSession({
  required String accessToken,
  required UserModel user,
}) async {
  await prefs.setString(AppConstants.userToken, accessToken);
  await prefs.setString(AppConstants.userDataJson, jsonEncode(user.toJson()));
  await prefs.setBool(AppConstants.isAppStarted, true);
  currentUserModel = user;
  isLogin.value = true;
}

Future<void> clearUserSession() async {
  await prefs.remove(AppConstants.userToken);
  await prefs.remove(AppConstants.userDataJson);
  currentUserModel = UserModel();
  isLogin.value = false;
}

// ------------------------------------------------
class AppLanguages {
  static const int codeFa = 0;
  static const int codeEn = 1;

  static const Locale fa = Locale('fa');
  static const Locale en = Locale('en');

  static const List<Locale> supportedLocales = [fa, en];

  static Locale localeFromCode(int code) {
    return code == codeFa ? fa : en;
  }
}
