import 'candidate.dart';

class Voting {
  String id;
  String? description;
  String title;
  String status;
  String from;
  String to;
  String createdAt;
  String updatedAt;
  List<Candidate> candidates;

  Voting({
    required this.id,
    required this.title,
    required this.status,
    required this.from,
    this.description,
    required this.to,
    required this.createdAt,
    required this.updatedAt,
    required this.candidates,
  });

  static Voting fromJson(Map<String, dynamic> json) {
    return Voting(
      id: json['_id']!,
      title: json['title']!,
      status: json['status']!,
      from: json['from']!,
      description: json['description'],
      to: json['to']!,
      createdAt: json['createdAt']!,
      updatedAt: json['updatedAt']!,
      candidates: (json['candidates']! as List)
          .map((e) => Candidate.fromJson(e))
          .toList(),
    );
  }
}
