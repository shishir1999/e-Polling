// ignore_for_file: overridden_fields, annotate_overrides

import 'package:jsend/jsend.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'few_detailed_user.dart';

class User extends FewDetailedUser {
  static final requiredKeysInPayload = [
    '_id',
    'name',
    'role',
    'email',
    'isEmailVerified',
    'phone',
  ];

  String id;
  String name;
  String role;
  String email;
  bool isEmailVerified;
  String authToken;
  String phone;
  List<String> votedCandidates;

//ctor
  User({
    required this.name,
    required this.id,
    required this.phone,
    required this.email,
    required this.authToken,
    required this.isEmailVerified,
    this.votedCandidates = const [],
    required this.role,
  }) : super(id: id, name: name);

  static User fromPayload(Map<String, dynamic> payload, String authToken) {
    bool hasAllRequiredKeys = true;
    for (var key in requiredKeysInPayload) {
      if (!payload.containsKey(key)) hasAllRequiredKeys = false;
    }
    if (!hasAllRequiredKeys) {
      throw Exception(
          "Some of the keys in ${requiredKeysInPayload.join(', ')} are not present in payload.");
    }

    return User(
      name: payload['name'],
      phone: payload['phone'],
      authToken: authToken,
      id: payload['_id'],
      email: payload['email'],
      isEmailVerified: payload['isEmailVerified'],
      role: payload['role'],
    );
  }

  static Future<User> fromToken(String token) async {
    if (token.trim().isEmpty) throw Exception("Empty token found.");
    var jresp = await jsendResponse.fromAPIRequest(
      APIRequest(
        path: "/users/me",
        headers: {"Authorization": "Bearer $token"},
      ),
    );

    if (jresp.status == 'success') {
      return User.fromPayload(jresp.data['user'], token);
    } else {
      throw Exception(
          "User could not be created from Token. ${jresp.message ?? ''}");
    }
  }

//saving autn token locally
  Future<bool> saveLocally() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("u_token", authToken);
      print("saved user session locally");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

// get saved token
  static Future<String?> getSavedToken() async {
    return (await SharedPreferences.getInstance()).getString("u_token");
  }

  // remove saved token
  static Future<bool> removeSavedToken() async {
    return (await SharedPreferences.getInstance()).remove("u_token");
  }

  Future<void> loadVotedCandidates() async {
    if (role == 'admin') return;
    var jresp = await jsendResponse
        .fromAPIRequest(APIRequest(path: "/users/me/votedCandidates"));
    if (jresp.status != 'success') {
      throw Exception(jresp.message ?? "Error loading voted candidates");
    }
    votedCandidates = (jresp.data['votedCandidates'] as List)
        .map((e) => e.toString())
        .toList();
    print("Loaded voted candidates");
  }
}
