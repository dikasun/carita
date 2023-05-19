import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  final Future<SharedPreferences> sharedPreferences;

  PreferenceHelper({
    required this.sharedPreferences,
  });

  static const String namePrefs = "NAME";
  static const String accessTokenPrefs = "ACCESS_TOKEN";
  static const String isLoggedPrefs = "IS_LOGGED";

  Future<String?> get getName async {
    final prefs = await sharedPreferences;
    return prefs.getString(namePrefs);
  }

  void setName(String value) async {
    final prefs = await sharedPreferences;
    prefs.setString(namePrefs, value);
  }

  Future<String?> get getAccessToken async {
    final prefs = await sharedPreferences;
    return prefs.getString(accessTokenPrefs);
  }

  void setAccessToken(String value) async {
    final prefs = await sharedPreferences;
    prefs.setString(accessTokenPrefs, value);
  }

  Future<bool> get getIsLogged async {
    final prefs = await sharedPreferences;
    return prefs.getBool(isLoggedPrefs) ?? false;
  }

  void setIsLogged(bool value) async {
    final prefs = await sharedPreferences;
    prefs.setBool(isLoggedPrefs, value);
  }

  void clearPrefs() async {
    final prefs = await sharedPreferences;
    prefs.clear();
  }
}
