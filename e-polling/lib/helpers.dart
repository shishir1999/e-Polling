import 'package:flutter/material.dart';
import 'package:jsend/jsend.dart';

import 'models/voting.dart';

class AppManager {
  static late GlobalKey<NavigatorState> navigatorKey;
  static BuildContext? get context => navigatorKey.currentContext;
}

String? errorIn(jsendResponse? r, String fieldName) {
  if (r != null) return r.errorIn(fieldName);
  return null;
}

dynamic customValidator(String? value, jsendResponse? r, String fieldName,
    [bool isRequired = false]) {
  String? validator(String? v) {
    if (isRequired) {
      if (v == null || v.isEmpty) {
        return "$fieldName is required";
      }
    }
    return errorIn(r, fieldName);
  }

  return validator(value);
}

void showSnackBar(String text) {
  ScaffoldMessenger.of(AppManager.navigatorKey.currentContext!)
      .showSnackBar(SnackBar(content: Text(text)));
}

enum OTPPurpose { verification, recovery, voting }

Future<Voting> getVotingById(String votingId) async {
  var resp = await jsendResponse.fromAPIRequest(
    APIRequest(
      path: "/votings/$votingId",
      method: "GET",
    ),
  );
  if (resp.status == 'success') return Voting.fromJson(resp.data);
  throw Exception(resp.message ?? "Error Getting voting by id: $votingId");
}
