import 'package:carita/data/local/preference/preference_helper.dart';

class PreferenceRepository {
  final PreferenceHelper preferenceHelper;

  PreferenceRepository({required this.preferenceHelper});

  Future<String?> getNamePref() async {
    final name = await preferenceHelper.getName;
    return name;
  }

  Future<String?> getAccessTokenPref() async {
    final accessToken = await preferenceHelper.getAccessToken;
    return accessToken;
  }

  Future<bool> getIsLoggedPref() async {
    final isLogged = await preferenceHelper.getIsLogged;
    return isLogged;
  }

  void setName(String value) {
    preferenceHelper.setName(value);
  }

  void setAccessToken(String value) {
    preferenceHelper.setAccessToken(value);
  }

  void setIsLogged(bool value) {
    preferenceHelper.setIsLogged(value);
  }
}
