import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfigController with ChangeNotifier {
  bool isLoading = false;
  String? savedUserToken;
  AppConfigController() {
    init();
  }

  void init() async {
    isLoading = true;
    notifyListeners();
    var sp = await SharedPreferences.getInstance();
    // user token
    savedUserToken = sp.getString('u_token');
    if (savedUserToken != null) {
      APIRequest.addDefaultHeaders({"Authorization": "Bearer $savedUserToken"});
      print("Added default bearer token");
    }
    isLoading = false;
    notifyListeners();
    print("App Initialized");
  }
}
