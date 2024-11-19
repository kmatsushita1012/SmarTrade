import 'package:shared_preferences/shared_preferences.dart';

class DataSingleton {
  DataSingleton._privateConstructor();
  static final DataSingleton _instance = DataSingleton._privateConstructor();
  factory DataSingleton() {
    return _instance;
  }
  final Map<String, dynamic> _contents = {};

  dynamic get(String key) {
    return _contents[key];
  }

  Future<void> set(
      String key, String path, Future<dynamic> Function(String) loader) async {
    _contents[key] = await loader(path);
  }
}

class SharedPreferencesSingleton {
  SharedPreferencesSingleton._privateConstructor();

  static final SharedPreferencesSingleton _instance =
      SharedPreferencesSingleton._privateConstructor();
  static SharedPreferences? _prefs;

  factory SharedPreferencesSingleton() {
    return _instance;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) {
    if (_prefs == null) {
      throw Exception("SharedPreferences is not initialized");
    }
    return _prefs!.getString(key);
  }

  void setString(String key, String value) async {
    if (_prefs == null) {
      throw Exception("SharedPreferences is not initialized");
    }
    await _prefs!.setString(key, value);
  }

  void removeValue(String key) async {
    if (_prefs == null) {
      throw Exception("SharedPreferences is not initialized");
    }
    await _prefs!.remove(key);
  }
}
