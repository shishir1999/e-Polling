

import 'user.dart';

class FewDetailedUser {
  static const unknownName = "Unknown Name";

  static final List<FewDetailedUser> _all = [];

  static FewDetailedUser? byId(String id) {
    try {
      return _all.firstWhere(
        (user) => user.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  String id;
  String name;

  FewDetailedUser({required this.id, required this.name}) {
    FewDetailedUser? alreadyExisting = byId(id);
    if (alreadyExisting == null) {
      _all.add(this);
    } else {
      // more priority to User class
      if (alreadyExisting is! User || alreadyExisting.name == unknownName) {
        print("Replacing copy of $alreadyExisting with ${toString()}");
        // _all.remove(alreadyExisting);
        // _all.add(this);
        alreadyExisting = this;
      }
    }
  }

// gives best guess for user by id
// returns unknown if user already not found
  static FewDetailedUser bestGuessFor(String userId) {
    return byId(userId) ?? FewDetailedUser(id: userId, name: unknownName);
  }

  static FewDetailedUser parse(Map<String, dynamic> payload) {
    if (!payload.containsKey("_id") || !payload.containsKey("name")) {
      throw Exception("_id or name missing in payload.");
    }
    return FewDetailedUser(id: payload['_id'], name: payload['name']);
  }

  bool equals(FewDetailedUser other) => id == other.id;

  @override
  String toString() {
    return "FewDetailedUser: ($name, $id)";
  }
}
