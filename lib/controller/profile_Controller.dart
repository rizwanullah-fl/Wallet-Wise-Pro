import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  RxString profileName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load the profile name from SharedPreferences when the controller is initialized
    loadProfileName();
  }

  Future<void> loadProfileName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    profileName.value = prefs.getString('profileName') ?? 'test';
  }

  Future<void> saveProfileName(String name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileName', name);
    profileName.value = name;
  }

  void saveProfile(String name) {
    saveProfileName(name);
  }

  void updateProfile(String newName) {
    saveProfileName(newName);
  }
}
