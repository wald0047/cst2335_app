import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// Repository class for managing customer data with encrypted shared preferences.
class CustomerRepository {
  // Initialize variables with default values
  static String firstName = "";
  static String lastName = "";
  static String address = "";
  static String birthdate = "";
  static bool switchValue = true;

  /// Loads customer data from encrypted shared preferences.
  ///
  /// Fetches stored values for `firstName`, `lastName`, `address`, and `birthdate`
  /// and updates the corresponding static variables.
  static void loadData() {
    var prefs = EncryptedSharedPreferences();

    // Retrieve and print the value of 'firstName'
    prefs.getString("firstName").then((result) {
      print("debug1, result: $result");
      firstName = result ?? ""; // Ensure default value if result is null
    });

    // Retrieve and print the value of 'lastName'
    prefs.getString("lastName").then((result) {
      print("debug2, result: $result");
      lastName = result ?? ""; // Ensure default value if result is null
    });

    // Retrieve and print the value of 'address'
    prefs.getString("address").then((result) {
      print("debug3, result: $result");
      address = result ?? ""; // Ensure default value if result is null
    });

    // Retrieve and print the value of 'birthdate'
    prefs.getString("birthdate").then((result) {
      print("debug4, result: $result");
      birthdate = result ?? ""; // Ensure default value if result is null
    });
  }

  /// Loads the switch value from encrypted shared preferences.
  ///
  /// Retrieves the stored value for `switchValue` and updates the static variable.
  static void loadSwitch() {
    var prefs = EncryptedSharedPreferences();

    // Retrieve the value of 'switchValue' and convert it to boolean
    prefs.getString("switchValue").then((result) {
      switchValue = result == "true";
    });
  }

  /// Saves customer data to encrypted shared preferences.
  ///
  /// Stores the current values of `firstName`, `lastName`, `address`, and `birthdate`.
  static void saveData() {
    var prefs = EncryptedSharedPreferences();

    // Store values in shared preferences
    prefs.setString("firstName", firstName);
    prefs.setString("lastName", lastName);
    prefs.setString("address", address);
    prefs.setString("birthdate", birthdate);
  }

  /// Saves the switch value to encrypted shared preferences.
  ///
  /// Converts the boolean `switchValue` to a string and stores it.
  static void saveSwitch() {
    var prefs = EncryptedSharedPreferences();

    // Store the string representation of the boolean switch value
    prefs.setString("switchValue", switchValue.toString());
  }
}
