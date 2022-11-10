import 'package:e_polling/models/candidate.dart';
import 'package:flutter/material.dart';
import 'package:jsend/api_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers.dart';
import '../models/user.dart';
import '../models/voting.dart';

class UserController with ChangeNotifier {
  bool isLoading = false;
  User? _session;
  User? get session {
    return _session;
  }

  bool get sessionExists => _session != null;

  set session(User? value) {
    if (value != null) {
      _session = value;
      onSessionChanged().then((_) {
        notifyListeners();
        print("User Session Successfully set.");
      });
    }
  }

  UserController() {
    tryGettingSession();
  }

  void tryGettingSession() async {
    if (sessionExists) {
      print("Cancelled trying to get session since session already exists.");
      return;
    }
    var savedToken = await User.getSavedToken();
    if (savedToken != null) {
      isLoading = true;
      notifyListeners();
      try {
        notifyListeners();
        var savedSession = await User.fromToken(savedToken);
        session = savedSession;
      } catch (e) {
        print("Error: $e");
      } finally {
        isLoading = false;
        notifyListeners();
      }
    } else {
      session = null;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _session = null;
    notifyListeners();
    showSnackBar("Logged Out");
  }

  // functions to run once user session has been created successfully
  Future<bool> onSessionChanged() async {
    if (session != null) {
      print("Logged in or session changed.");
      APIRequest.addDefaultHeaders(
          {"Authorization": "Bearer ${session!.authToken}"});
      print("Added new bearer token in APIRequest.");
      await session!.loadVotedCandidates();
      await session!.saveLocally();
    } else {
      print("Logged out.");
      APIRequest.addDefaultHeaders({"Authorization": "Bearer null"});
      await User.removeSavedToken();
    }
    return true;
  }

// mark voting done
  void markVotingDone(Voting voting, Candidate candidate) {
    print("Before voting: ");
    print(session!.votedCandidates);

    var candidatesInVoting = voting.candidates.map((e) => e.id).toList();

    session!.votedCandidates = session!.votedCandidates
        .where((element) => !candidatesInVoting.contains(element))
        .toList();

    session!.votedCandidates.add(candidate.id);
    notifyListeners();
    print("Before voting: ");
    print(session!.votedCandidates);
  }
}
