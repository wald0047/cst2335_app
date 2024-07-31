import 'dart:async';

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class DataRepository{

  static String planeType = "";
  static String planeRange = "";
  static String planePassengers = "";
  static String planeSpeed = "";


  static Future<bool> loadData() async
  {
    var prefs = EncryptedSharedPreferences();
    planeType = await prefs.getString("planeType");
    planeRange = await prefs.getString("planeRange");
    planePassengers = await prefs.getString("planePassengers");
    planeSpeed = await prefs.getString("planeSpeed");
    return true;
  }


  static void saveData()
  {
    var prefs = EncryptedSharedPreferences();

    prefs.setString("planeType", planeType);
    prefs.setString("planeRange", planeRange);
    prefs.setString("planePassengers", planePassengers);
    prefs.setString("planeSpeed", planeSpeed);
  }
}