import 'package:get_storage/get_storage.dart';

class SLocalStorage {
  static final SLocalStorage _instance = SLocalStorage._internal();

  factory SLocalStorage() {
    return _instance;
  }

  SLocalStorage._internal();
  final storage = GetStorage();

// Generic method to save data

  Future<void> saveData<S>(String key, S value) async {
    await storage.write(key, value);
  }

// Generic method to read data

  S? readData<S>(String key) {
    return storage.read<S>(key);
  }

// Generic method to remove data
  Future<void> removeData(String key) async {
    await storage.remove(key);
  }

// Clear all data in storage
  Future<void> clearAll() async {
    await storage.erase();
  }
}
