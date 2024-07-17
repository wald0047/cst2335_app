import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class CustomerRepository {
  // initialize to an empty string
  static String firstName = "";
  static String lastName = "";
  static String address = "";
  static String birthdate = "";
  static bool switchValue = true;

  static void loadData() {
    var prefs = EncryptedSharedPreferences();
    prefs.getString("firstName").then((result) {
      print("debug1, result: $result");
      firstName = result;
    });
    prefs.getString("lastName").then((result) {
      print("debug2, result: $result");
      lastName = result;
    });
    prefs.getString("address").then((result) {
      print("debug3, result: $result");
      address = result;
    });
    prefs.getString("birthdate").then((result) {
      print("debug4, result: $result");
      birthdate = result;
    });
  }

  static void loadSwitch() {
    var prefs = EncryptedSharedPreferences();
    prefs.getString("switchValue").then((result) {
      switchValue = result == "true";
    });
  }

  static void saveData() {
    var prefs = EncryptedSharedPreferences();
    prefs.setString("firstName", firstName);
    prefs.setString("lastName", lastName);
    prefs.setString("address", address);
    prefs.setString("birthdate", birthdate);
  }

  static void saveSwitch() {
    var prefs = EncryptedSharedPreferences();
    prefs.setString("switchValue", switchValue.toString());
  }
}
